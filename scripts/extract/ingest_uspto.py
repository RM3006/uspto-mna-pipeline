import os
import requests
import boto3
from botocore.exceptions import NoCredentialsError, ClientError
from dotenv import load_dotenv
from datetime import datetime
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# 1. Load Config
load_dotenv('.env') 
load_dotenv('.env.generated', override=True)

# 2. Setup Variables
AWS_ACCESS_KEY = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
BUCKET_NAME = os.getenv('AWS_BUCKET_NAME')
USPTO_API_KEY = os.getenv('USPTO_API_KEY')

# Official ODP API Endpoint
# PASYR = Patent Assignment XML (Yearly). Change to 'PASDA' for Daily.
PRODUCT_ID = "PASYR" 
API_URL = f"https://api.uspto.gov/api/v1/datasets/products/{PRODUCT_ID}"

# 3. Dynamic Filter (Last 3 years)
YEARS_TO_PROCESS = 3
current_year = datetime.now().year
TARGET_YEARS = [str(current_year - i) for i in range(YEARS_TO_PROCESS)]

# --- HELPER: Session with Retry Logic ---
def create_session():
    """
    Creates a robust session with Retries and Auth Headers.
    """
    session = requests.Session()
    
    # Add the API Key to headers (Required by USPTO)
    if USPTO_API_KEY:
        session.headers.update({"X-API-KEY": USPTO_API_KEY})
    else:
        # Warning only; allows script to run if key is missing (e.g. testing)
        print("⚠️ WARNING: No USPTO_API_KEY found in .env. Request may fail.")

    retry_strategy = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["HEAD", "GET", "OPTIONS"]
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    return session

def get_zip_links(api_url):
    print(f"🔎 Querying USPTO API: {api_url}...")
    session = create_session()
    
    try:
        response = session.get(api_url, timeout=10)
        response.raise_for_status()
        data = response.json() 
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 401:
            print(f"❌ API Unauthorized. Check your USPTO_API_KEY.")
        elif e.response.status_code == 404:
            print(f"❌ API 404 Error. Check PRODUCT_ID.")
        else:
            print(f"❌ API Error: {e}")
        return []
    except Exception as e:
        print(f"❌ Error parsing API response: {e}")
        return []

    zip_files = []
    
    # ODP API Structure: The files are inside 'productFileBag'
    try:
        files_list = data.get('productFileBag', [])
        print(f"   Found {len(files_list)} total files in dataset.")
        
        for file_info in files_list:
            file_name = file_info.get('fileName', '')
            # The key for the download link is 'fileDownloadURI'
            download_url = file_info.get('fileDownloadURI', '') 
            
            if file_name.endswith('.zip') and download_url:
                zip_files.append(download_url)
                
    except AttributeError:
        print("❌ Unexpected JSON structure received.")
            
    print(f"✅ Found {len(zip_files)} valid zip files.")
    return zip_files

def upload_to_s3(url, bucket):
    file_name = url.split('/')[-1]
    s3_path = f"raw/{file_name}"
    
    # 1. Filter for years
    if TARGET_YEARS:
        if not any(year in file_name for year in TARGET_YEARS):
            return

    # 2. Initialize Clients
    session = create_session()
    s3 = boto3.client(
        's3', 
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_KEY
    )

    # 3. Get Remote File Size
    try:
        response_head = session.head(url, timeout=10)
        remote_size = int(response_head.headers.get('Content-Length', 0))
    except Exception as e:
        print(f"⚠️ Could not get remote size for {file_name}: {e}")
        remote_size = 0

    # 4. Check S3 (Existence + Size)
    try:
        s3_obj = s3.head_object(Bucket=bucket, Key=s3_path)
        s3_size = s3_obj['ContentLength']
        
        if remote_size > 0 and s3_size == remote_size:
            print(f"⏭️  Skipping {file_name} (Already in S3: {s3_size} bytes)")
            return
        else:
            print(f"🔄 File update detected. Re-downloading...")
            
    except:
        print(f"⬇️  New file detected: {file_name}")

    # 5. Stream Download & Upload
    try:
        print(f"⏳ Downloading {file_name}...")
        with session.get(url, stream=True, timeout=60) as r:
            r.raise_for_status()
            s3.upload_fileobj(r.raw, bucket, s3_path)
            print(f"✅ Uploaded to s3://{bucket}/{s3_path}")
            
    except Exception as e:
        print(f"❌ Error processing {file_name}: {e}")

if __name__ == "__main__":
    links = get_zip_links(API_URL)
    
    for link in links:
        upload_to_s3(link, BUCKET_NAME)
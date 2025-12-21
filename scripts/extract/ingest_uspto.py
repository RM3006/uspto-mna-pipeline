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

# We only need the API URL now. The old BASE_URL is dead.
PRODUCT_ID = "PASYR" 
API_URL = f"https://data.uspto.gov/api/v1/dataset/{PRODUCT_ID}/files"

# 3. Dynamic Filter
YEARS_TO_PROCESS = 3
current_year = datetime.now().year
TARGET_YEARS = [str(current_year - i) for i in range(YEARS_TO_PROCESS)]

# --- HELPER: Session with Retry Logic ---
def create_session():
    """
    Creates a robust session that retries on connection failures.
    """
    session = requests.Session()
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
        data = response.json() # Parse JSON response
    except Exception as e:
        print(f"❌ API Error: {e}")
        return []

    zip_files = []
    
    # The API returns a list of file objects
    for file_info in data:
        file_name = file_info.get('fileName', '')
        download_url = file_info.get('downloadUrl', '')
        
        # Filter: Only .zip files
        if file_name.endswith('.zip') and download_url:
            zip_files.append(download_url)
            
    print(f"✅ Found {len(zip_files)} files via API.")
    return zip_files

def upload_to_s3(url, bucket):
    file_name = url.split('/')[-1]
    s3_path = f"raw/{file_name}"
    
    # 1. Filter for years
    if TARGET_YEARS:
        if not any(year in file_name for year in TARGET_YEARS):
            return

    # 2. Initialize Clients (Session + S3)
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
    # CORRECTED: Use API_URL, not BASE_URL
    links = get_zip_links(API_URL)
    
    for link in links:
        upload_to_s3(link, BUCKET_NAME)
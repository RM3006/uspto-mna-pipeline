# Run this from the root: C:\Users\romen\Documents\Data Projects\uspto-mna-pipeline
# Loads the variables from the .env files at root project level (uspto-mna-pipeline)
Get-Content .env | ForEach-Object {
    if ($_ -notmatch '^#|^$') {
        $name, $value = $_.split('=', 2)
        [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}
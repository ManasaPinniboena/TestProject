# Set the download URL and file path for Git
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe"
Write-Host $env:TEMP
$gitInstallerPath = "$env:TEMP\GitInstaller.exe"

# Set the download URL and file path for chef-client
$chefclientUrl = "https://packages.chef.io/files/stable/chef/14.15.6/windows/2019/chef-client-14.15.6-1-x64.msi"
$chefclientPath = "$env:TEMP\chef-client.msi"

#Enable TLS Protocols
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

# Create a WebClient object
$webClient = New-Object System.Net.WebClient

# Download the Git installer
Write-Host "Downloading Git..."
$webClient.DownloadFile($gitUrl, $gitInstallerPath)

#Install Git
Write-Host "Installing git"
Start-Process -FilePath $gitInstallerPath -ArgumentList "/SILENT" -Wait

#Download the chef-client MSI package
Write-Host "Downloading chef-client"
Invoke-WebRequest -Uri $chefclientUrl -OutFile $chefclientPath

#Install chef-client
Write-Host "Installing chef-client"
Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$chefclientPath`" /qn" -Wait

#Setting Environment variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

#Verify Git and chef-client
#$gitVersion = (git --version).Version
#Write-Host "git has been installed successfully"

# Dispose the WebClient object
$webClient.Dispose()

# Set the download URL and file path
$gitCloneUrl = "https://github.com/dev-sec/chef-windows-hardening.git"
$secureCloneUrl = "https://github.com/grdnrio/windows-security-policy.git"

#Set Execution policy
Set-ExecutionPolicy RemoteSigned

# Set the target directory wher the cookbook will be downloaded
$targetDir = "C:\Cookbooks"


# Create target Dir if not exist
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}
Write-Host "Created Target directory $targetDir"

#Clone the cookbook repo
$cloneDir = Join-Path -Path $targetDir -ChildPath "windows-hardening"
Write-Host "Cloning the repos $cloneDir"
git clone $gitCloneUrl $cloneDir


$cloneSecureDir = Join-Path -Path $targetDir -ChildPath "windows-security-policy"
Write-Host "Cloning the dependency repos $cloneSecureDir"
git clone $secureCloneUrl $cloneSecureDir

# Create the attributes.json file to accept the cookbook license
@"
{
  "cookbook_name": {
    "accept_license": true
  }
}
"@ | Set-Content -Path C:\chef\attributes.json

# Run the cookbook locally
$localKeyPath = Join-Path -Path C:\chef -ChildPath "local-mode.pem"

@"
-----BEGIN RSA PRIVATE KEY-----
... (your private key content goes here) ...
-----END RSA PRIVATE KEY-----
"@ | Set-Content -Path $localKeyPath
Write-Host "Configured the chef-client"

Write-Host "Running chef-clinet"
#Start chef-client
chef-client -z -o windows-hardening -NoNewWindow

Write-Host "chef-clinet run completed"

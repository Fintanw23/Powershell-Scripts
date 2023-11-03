# Define the IP address and NFS share path
$IPAddress = "NFS_SHARE_IP"
$SharePath = "/YOUR/SHARE/PATH"

# Prompt for username and password
$Username = Read-Host "Enter NFS Username"
$Password = Read-Host "Enter NFS Password" -AsSecureString

# Ping the IP address to check for a response
if (Test-Connection -ComputerName $IPAddress -Count 1 -Quiet) {
    # Generate a unique drive letter
    $DriveLetter = Get-UnusedDriveLetter

    # Create a persistent NFS share mapping with username and password
    New-PSDrive -Name "NFS" -PSProvider FileSystem -Root "\\$IPAddress\$SharePath" -Persist -PersistScope Global -Credential (New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $Password)

    # Open the mapped drive in File Explorer
    Invoke-Item -Path "$DriveLetter:"

    Write-Host "Connected to NFS share at $IPAddress on drive $DriveLetter"
} else {
    Write-Host "Unable to ping $IPAddress. The host is not responding."
}

# Function to get an unused drive letter
function Get-UnusedDriveLetter {
    $usedDriveLetters = Get-WmiObject -Class Win32_LogicalDisk | Select-Object -ExpandProperty DeviceID
    $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    foreach ($letter in $alphabet.ToCharArray()) {
        if ($usedDriveLetters -notcontains $letter) {
            return $letter
        }
    }

    return $null
}

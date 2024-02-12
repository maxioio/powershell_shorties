$username = "nsx-user"
$pass = Read-Host "Enter password" -AsSecureString
$mgr = "https://my-nsx-manager.com"

$vmarray = @()

FUNCTION get-NSXvmTags(){
    param(
        $username,
        $pass,
        $mgr
    )
    
    $vmarray = @()
    $cursor = $null

    $targeturi = "/api/v1/fabric/virtual-machines"
    
    $uri = $mgr + $targeturi
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
    $userpass  = $username + ":" + $password

    $bytes= [System.Text.Encoding]::UTF8.GetBytes($userpass)
    $encodedlogin=[Convert]::ToBase64String($bytes)
    $authheader = "Basic " + $encodedlogin
    $header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $header.Add("Authorization",$authheader)
    $res = Invoke-RestMethod -Uri $uri -Headers $header -Method 'GET'
    
    $vmarray += $res.results
    $cursor = $res.cursor
    Write-Host($vmarray.count)


    while ($cursor -ne $null) {
        $targeturi = "/api/v1/fabric/virtual-machines"
        
        if ($cursor -ne $null) {
            $targeturi += "?cursor=" + $cursor
        }
    
        $uri = $mgr + $targeturi
    
        $res = Invoke-RestMethod -Uri $uri -Headers $header -Method 'GET'
        
        $vmarray += $res.results
        $cursor = $res.cursor
    }
    
    return $vmarray
}

$vmarray = get-NSXvmTags $username $pass $mgr
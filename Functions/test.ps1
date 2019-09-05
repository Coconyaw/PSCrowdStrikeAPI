# Get-ChildItem $PSScriptRoot -Include "*.ps1" -File -Recurse | ? { -not ($_.Name -match "\.Tests\.") } | %  { & $_.FullName }
. .\Get-CSAccessToken.ps1
. .\Search-CSDevice.ps1

$t = Get-CSAccessToken
# $r = Invoke-CSRestMethod -Method Get -Endpoint "devices/queries/devices/v1?filter=platform_name: 'Linux'" -Token $t
# $r = Invoke-CSRestMethod -Method Get -Endpoint "devices/queries/devices/v1" -Token $t -Body $body
# $d = Invoke-CSRestMethod -Method Get -Endpoint "devices/entities/devices/v1?ids=$($r.resources)" -Token $t
# $r.resources | % { Invoke-CSRestMethod -Method Get -Endpoint "devices/entities/devices/v1?ids=$_" -Token $t }
#
# Search-CSDevice -Token $t -HostName "JNSP181059" -LocalIp "10.200.47.13"
Search-CSDevice -Token $t -LocalIp "1.1.1.1"
# Search-CSDevice -Token $t -PlatForm "Linux"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.','.'
. "$here\$sut"

$ConfigPath = "TestDrive:\csconfig.json"
$ExpectedConfig = '{"client_id":"testid","client_secret":"testsecret"}'

Describe "Set-CSConfig" {
  It "Confirm that a confifile is created." {
    Set-CSConfig -Path $ConfigPath -ClientId testid -ClientSecret testsecret
    Test-Path $ConfigPath | Should be $true
  }
  It "Confirm that a correct config string." {
    Set-CSConfig -Path $ConfigPath -ClientId testid -ClientSecret testsecret
    Test-Path $ConfigPath | Should be $true
    $result = Get-Content $ConfigPath
    $result | Should be $ExpectedConfig
  }
}

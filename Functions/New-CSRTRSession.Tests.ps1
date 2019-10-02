$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. ./Invoke-CSRestMethod.ps1

$at = "Access_Token"
Describe "New-CSRTRSession" {
    It "Give Aid 123abc, expected success" {
		$base = "/real-time-response/entities/sessions/v1"
		$aid = "123abc"
		$reqBody = @{"device_id" = $aid} | ConvertTo-Json
		Mock Invoke-CSRestMethod { return "Success" } `
		-Verifiable `
		-ParameterFileter { $Token -eq $at; $Endpoint -eq $base; $Method -eq "Post"; $Body -eq $reqBody }

		New-CSRTRSession -Token $at -Aid $aid | Should be "Success"
		Assert-VerifiableMocks
    }
}

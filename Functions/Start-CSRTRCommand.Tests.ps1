$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. ./Invoke-CSRestMethod.ps1

$at = "Access_Token"
Describe "Start-CSRTRCommand" {
	$TestCases = @(
		@{BaseCommand = "cat"; CommandString = "cat C:\test.txt"; SessionId = "11112222"; expect = "Success"},
		@{BaseCommand = "ps"; CommandString = "ps"; SessionId = "11112222"; expect = "Success"},
		@{BaseCommand = "mkdir"; CommandString = "mkdir C:\test"; SessionId = "11112222"; expect = "Success"},
		@{BaseCommand = "nonexistcommand"; CommandString = "cat C:\test.txt"; SessionId = "11112222"; expect = "Error"}
	)
    It "Given -BaseCommand '<BaseCommand>', -CommandStrig '<CommandStrig>', -SessionId '<SessionId>', Expect '<Expect>'" -TestCase $TestCases {
		Param ($BaseCommand, $CommandString, $SessionId, $Expect)

		$base = "/real-time-response/entities/active-responder-command/v1"
		$reqbody = @{"base_command" = $BaseCommand; "command_string" = $CommandString; "session_id" = $SessionId; "persist" = $true} | ConvertTo-Json
		Mock Invoke-CSRestMethod { return "Success" } `
		-Verifiable `
		-ParameterFileter { $Token -eq $at; $Endpoint -eq $base; $Method -eq "Post"; $Body -eq $reqBody }

		if ($Expect -eq "Success") {
			Start-CSRTRCommand -Token $at -BaseCommand $BaseCommand -CommandString $CommandString -SessionId $SessionId |
			Should be $Expect
			Assert-VerifiableMocks
		} else {
			{ Start-CSRTRCommand -Token $at -BaseCommand $BaseCommand -CommandString $CommandString -SessionId $SessionId } |
			Should throw
		}
    }
}

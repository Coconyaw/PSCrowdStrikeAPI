$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. .\Invoke-CSRestMethod.ps1

$d = (Get-Date).AddMinutes(30).ToString()

Describe "Search-CSIOCDeviceCount" {
	$base = "/indicators/aggregates/devices-count/v1"
	$TestCases = @(
		@{Type = "domain"; Value = "test.example.com"},
		@{Type = "md5"; Value = "CC578BEF96FEB456B3ABA5F73D04E110"},
		@{Type = "sha256"; Value = "C2E214369F504926F44986BC0B70F335C56E189237E28EDC8E49287A6FF75795"}
	)
    It "Given -Type '<Type>' -Value '<Value>', it expect verifiable mock call." -TestCase $TestCases {
		Param ($Type, $Value)
		$body = @{type = $Type; value = $Value}
		Mock Invoke-CSRestMethod { return @{} } -Verifiable `
		-ParameterFilter {$Endpoint -eq $base; $Method -eq "Get"; $Body -eq $body}
		Search-CSIOCDeviceCount -Type $Type -Value $Value
		Assert-VerifiableMocks
    }
}

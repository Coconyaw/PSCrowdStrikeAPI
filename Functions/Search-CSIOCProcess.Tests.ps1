$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. .\Invoke-CSRestMethod.ps1

$IdRetJson = '
{
  "meta": {
    "query_time": 0.10,
    "pagination": {
      "offset": "1364242733:397800512",
      "limit": 2,
      "next_page": "/indicators/queries/processes/v1?type=sha256&value=6054cbeb9025d77bdee5753431bcbb0a77b0884b5b206f9edaecad473efb4e8c&device_id=804d7f732fb8493c75f658bb01ec5b14&offset=1364242733:397800512&limit=1"
    },
    "trace_id": "a4d3ba63-28e4-473e-9b6f-61dd0b8be4fe",
    "entity": "https://falconapi.crowdstrike.com/processes/entities/processes/v1{?ids*}"
  },
  "resources": [
    "pid:2dd78ec768844f1941a69b56185fb3c2:298186372772",
    "pid:2dd78ec768844f1941a69b56185fb3c2:922186374411"
  ],
  "errors": []
}'

$DetailRetJson = '{
  "meta": {
    "query_time": 0.036953655,
    "trace_id": ""
  },
  "resources": [
    {
      "device_id": "testdevice1",
      "command_line": "\\AppData\\Local\\Temp\\svchost.exe.4406085680331495051.fuzz\"",
      "process_id": "2dd78ec768844f1941a69b56185fb3c2:298186372772",
      "process_id_local": "298186372772",
      "file_name": "\\Users\\seagull\\AppData\\Local\\Temp\\svchost.exe.4406085680331495051.fuzz",
      "start_timestamp": "2016-01-07T08:51:13Z",
      "start_timestamp_raw": "130966302736257500",
      "stop_timestamp": "2016-01-07T08:51:14Z",
      "stop_timestamp_raw": "130966302744226250"
    },
    {
      "device_id": "testdevice2",
      "command_line": "\\AppData\\Local\\Temp\\svchost.exe.4406085680331495051.fuzz\"",
      "process_id": "2dd78ec768844f1941a69b56185fb3c2:298186372772",
      "process_id_local": "298186372772",
      "file_name": "\\Users\\seagull\\AppData\\Local\\Temp\\svchost.exe.4406085680331495051.fuzz",
      "start_timestamp": "2016-01-07T08:51:13Z",
      "start_timestamp_raw": "130966302736257500",
      "stop_timestamp": "2016-01-07T08:51:14Z",
      "stop_timestamp_raw": "130966302744226250"
    }
  ],
  "errors": []
}
'

$IdSampleRes = $IdRetJson | ConvertFrom-Json
$DetailSampleRes = $DetailRetJson | ConvertFrom-Json

Describe "Search-CSIOCProcess" {
	$TestCases = @(
		@{ Type = "domain"; Value = "www.google.com";   DeviceId = "testdevice"; Limit = $null; Expect = "Success" },
		@{ Type = "domain"; Value = "www.google.com";   DeviceId = "testdevice"; Limit = 10;    Expect = "Success" },
		@{ Type = "sha256"; Value = "testsha256value";  DeviceId = "testdevice"; Limit = 10;    Expect = "Success" },
		@{ Type = "md5";    Value = "testmd5value";     DeviceId = "testdevice"; Limit = 10;    Expect = "Success" },
		@{ Type = "domain"; Value = "test.example.com"; DeviceId = "testdevice"; Limit = 0;     Expect = "Success" },
		@{ Type = "domain"; Value = "test.example.com"; DeviceId = "testdevice"; Limit = 100;   Expect = "Success" },
		@{ Type = "domain"; Value = "test.example.com"; DeviceId = "testdevice"; Limit = -1;    Expect = "Error" },
		@{ Type = "domain"; Value = "test.example.com"; DeviceId = "testdevice"; Limit = 101;   Expect = "Error" }
	)

	Context "Search-CSIOCProcessId" {
		It "Given value -Type '<Type>' -Value '<Value>' -DeviceId '<DeviceId>' -Limit '<Limit>', it -Expect '<Expect>'" `
		-TestCases $TestCases {
			Param ( $Type, $Value, $DeviceId, $Limit, $Expect )

			$base = "/processes/entities/processes/v1"
			Mock Invoke-CSRestMethod { return $IdSampleRes } -Verifiable -Scope It


			if ($Limit -eq $null -and $Expect -eq "Success") {
				Search-CSIOCProcessId -Type $Type -Value $Value -DeviceId $DeviceId |
				Should be $IdSampleRes
				Assert-VerifiableMocks
			} elseif ($Limit -ne $null -and $Expect -eq "Success") {
				Search-CSIOCProcessId -Type $Type -Value $Value -DeviceId $DeviceId -Limit $Limit |
				Should be $IdSampleRes
				Assert-VerifiableMocks
			} elseif ($Limit -ne $null -and $Expect -eq "Error") {
				{ Search-CSIOCProcessId -Type $Type -Value $Value -Limit $Limit } | Should throw
			}
		}
	}

	Context "Search-CSIOCProcess" {
		It "Given value -Type '<Type>' -Value '<Value>' -DeviceId '<DeviceId>' -Limit '<Limit>', it -Expect '<Expect>'" `
		-TestCases $TestCases {
			Param ( $Type, $Value, $DeviceId, $Limit, $Expect )
			Mock Invoke-CSRestMethod { return $DetailSampleRes } -Verifiable -Scope It
			Mock Search-CSIOCProcessId { return $IdSampleRes } -Verifiable -Scope It


			if ($Limit -eq $null -and $Expect -eq "Success") {
				Search-CSIOCProcess -Type $Type -Value $Value -DeviceId $DeviceId |
				Should be $DetailSampleRes
				Assert-VerifiableMocks
				Assert-MockCalled -CommandName Invoke-CSRestMethod -Times 2 -Exactly -Scope It
			} elseif ($Limit -ne $null -and $Expect -eq "Success") {
				Search-CSIOCProcess -Type $Type -Value $Value -DeviceId $DeviceId -Limit $Limit |
				Should be $DetailSampleRes
				Assert-VerifiableMocks
				Assert-MockCalled -CommandName Invoke-CSRestMethod -Times 2 -Exactly -Scope It
			} elseif ($Limit -ne $null -and $Expect -eq "Error") {
				{ Search-CSIOCProcess -Type $Type -Value $Value -Limit $Limit } | Should throw
			}
		}
	}
}



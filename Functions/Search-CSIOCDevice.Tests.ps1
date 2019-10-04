$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. .\Invoke-CSRestMethod.ps1
. .\Search-CSDevice.ps1

$RetObj = '{
    "meta":  {
                 "query_time":  0.021829515,
                 "pagination":  {
                                    "offset":  "0:3584193470",
                                    "limit":  10,
                                    "next_page":  "/indicators/queries/devices/v1?type=domain\u0026value=www.google.com\u0026offset=0:3584193470\u0026limit=10"
                                },
                 "trace_id":  "ab4bea15-64ad-4851-9d8c-b5361d3eb43c",
                 "entity":  "/devices/entities/devices/v1{?ids*}"
             },
    "resources":  [
                      "00000000000000000000000000000000",
                      "00043f1d2db54b037cc3a5af81beab75",
                      "001ec300e5b747616bbb1209b354fbbe",
                      "002463e0c8704f22582ea0e4d9785434",
                      "00271980c06a4be04b7aa2342cee0992",
                      "003a387744d24fdf66aa0566ab6c6f59",
                      "003faa6c8a384a027fe04906a98683f2",
                      "0043d053537740a36b3590598c6843b5",
                      "0048ec47f1b842374e2379c61930dca5",
                      "00528c34bd544aad4fc8c6656453bb4e"
                  ],
    "errors":  [

               ]
}
'

$MockReturnObj = $RetObj | ConvertFrom-Json

Describe "Search-CSIOCDevice" {
	$TestCases = @(
		@{ Type = "domain"; Value = "www.google.com"; Limit = $null; Expect = "Success" },
		@{ Type = "domain"; Value = "www.google.com"; Limit = 10; Expect = "Success" },
		@{ Type = "sha256"; Value = "testsha256value"; Limit = 10; Expect = "Success" },
		@{ Type = "md5"; Value = "testmd5value"; Limit = 10; Expect = "Success" },
		@{ Type = "domain"; Value = "test.example.com"; Limit = 0; Expect = "Success" },
		@{ Type = "domain"; Value = "test.example.com"; Limit = 100; Expect = "Success" },
		@{ Type = "domain"; Value = "test.example.com"; Limit = -1; Expect = "Error" },
		@{ Type = "domain"; Value = "test.example.com"; Limit = 101; Expect = "Error" }
	)

    It "Given value -Type '<Type>' -Value '<Value>' -Limit '<Limit>', it -Expect '<Expect>'" -TestCases $TestCases {
		Param ( $Type, $Value, $Limit, $Expect )

		Mock Invoke-CSRestMethod { return $MockReturnObj } -Verifiable -Scope It
		Mock Search-CSDeviceDetail { return "Success" } -Scope It

		if ($Limit -eq $null -and $Expect -eq "Success") {
			Search-CSIOCDevice -Type $Type -Value $Value | Should be $Expect
			Assert-VerifiableMocks
			Assert-MockCalled -CommandName Search-CSDeviceDetail -Times 10 -Exactly -Scope It
		} elseif ($Limit -ne $null -and $Expect -eq "Success") {
			Search-CSIOCDevice -Type $Type -Value $Value -Limit $Limit | Should be $Expect
			Assert-VerifiableMocks
			Assert-MockCalled -CommandName Search-CSDeviceDetail -Times 10 -Exactly -Scope It
		} elseif ($Limit -ne $null -and $Expect -eq "Error") {
			{ Search-CSIOCDevice -Type $Type -Value $Value -Limit $Limit } | Should throw
		}
    }

    It "Aidonly" {
		Mock Search-CSIOCDeviceAid { return $MockReturnObj } -Verifiable -Scope It
		Mock Search-CSDeviceDetail { return "Success" } -Scope It

		Search-CSIOCDevice -Type domain -Value "test.example.com" -AidOnly
		Assert-MockCalled -CommandName Search-CSDeviceDetail -Times 0 -Exactly -Scope It
	}
}

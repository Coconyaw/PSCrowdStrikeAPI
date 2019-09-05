$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-CSRestMethod" {
	$token = @{access_token = "Access_token"; token_type= "bearer"; expires_in = 1799; expiration_time = "2019/09/03 12:00:00"}
	$postv1 = @{
			action_parameters = @(@{ name = "test"; value = "testv"})
			ids = @(12345, 54321)
	}
	$patchv1 = @{
			assigned_to_uuid = "12345678910"
			ids = @(12345, 54321)
			show_in_ui = $true
			status = "new"
	}
	$deletev1 = @{
			assigned_to_uuid = "12345678910"
			ids = @(12345, 54321)
			show_in_ui = $true
			status = "new"
	}

    It "Given value -Method '<HttpMethod>' -Body '<B>', it expect verified mocks call." -TestCases @(
		@{ Token = $token; Endpoint = "devices/queries/devices/v1?filter=local_ip: '1.1.1.1'"; HttpMethod = "Get"; B = $null},
		@{ Token = $token; Endpoint = "devices/entities/devices-actions/v2?action_name=contain"; HttpMethod = "Post"; B = $postv1},
		@{ Token = $token; Endpoint = "detects/entities/detects/v2"; HttpMethod = "Patch"; B = $patchv1},
		@{ Token = $token; Endpoint = "policy/entities/prevention/v1?ids=test"; HttpMethod = "Delete"; B = $null}
	) {
		param ($Token, $Endpoint, $HttpMethod, $B)
		$header = @{
			Accept = "application/json"
			Authorization = "$($Token.token_type) $($Token.access_token)"
		}
		$url = "https://api.crowdstrike.com/" + $Endpoint
		if ($B -eq $null) {
			Mock Invoke-RestMethod { return @{} } -Verifiable -ParameterFilter { $Uri -eq $url; $Method -eq $HttpMethod; $Headers -eq $header }
			Invoke-CSRestMethod -Token $Token -Endpoint $Endpoint -Method $HttpMethod
		} else {
			Mock Invoke-RestMethod { return @{} } -Verifiable -ParameterFilter { $Uri -eq $url; $Method -eq $HttpMethod; $Headers -eq $header; $Body = $B }
			Invoke-CSRestMethod -Token $Token -Endpoint $Endpoint -Method $HttpMethod -Body $B
		}

		Assert-VerifiableMocks
    }
}

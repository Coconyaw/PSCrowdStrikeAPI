$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.','.'
. "$here\$sut"

$token = @{ access_token = "Access_token"; token_type = "bearer"; expires_in = 1799; expiration_time = "2019/09/03 12:00:00" }

Describe "Construct-FilterString" {
  $TestCases = @(
    [ordered]@{},
    [ordered]@{ hostname = "test" },
    [ordered]@{ local_ip = "1.1.1.1"; external_ip = "2.2.2.2" },
    [ordered]@{ hostname = "test04";
      local_ip = "3.3.3.3";
      external_ip = "4.4.4.4";
      os_version = "Windows 7";
      platform_name = "Windows";
      status = "Normal" }
  )

  It "No params" {
    $q = [ordered]@{}
    $expect = ""
    Construct-FilterString $q | Should Be $expect
  }
  It "One params" {
    $q = [ordered]@{ hostname = "test" }
    $expect = "hostname:'$($q.hostname)'"
    Construct-FilterString $q | Should Be $expect
  }
  It "Two params" {
    $q = [ordered]@{ local_ip = "1.1.1.1"; external_ip = "2.2.2.2" }
    $expect = "local_ip:'$($q.local_ip)'+external_ip:'$($q.external_ip)'"
    Construct-FilterString $q | Should Be $expect
  }
  It "all params" {
    $q = [ordered]@{ hostname = "test04";
      local_ip = "3.3.3.3";
      external_ip = "4.4.4.4";
      os_version = "Windows 7";
      platform_name = "Windows";
      status = "Normal"
    }

    $expect = "hostname:'$($q.hostname)'+local_ip:'$($q.local_ip)'+external_ip:'$($q.external_ip)'+os_version:'$($q.os_version)'+platform_name:'$($q.platform_name)'+status:'$($q.status)'"
    Construct-FilterString $q | Should Be $expect
  }
}

Describe "Search-CSDeviceDetail" {

  $RetAids = '{
		"meta": {
			"query_time": 0.038957744,
			"pagination": {
				"offset": 100,
				"limit": 100,
				"total": 9125
			},
			"powered_by": "device-api",
			"trace_id": "915e2945-e4b8-45a5-a717-1ed8852fb2a5"
		},
		"resources": [
			"ea2085de804f4dde7053af48828889cb",
			"01e90d6de67344d544ac1a009b708dc6",
			"f114d3fa9a0b465e42770091b0148c6c",
			"9447cb4a2b694d525ab0da85528fb1b8",
			"a147e79c127247967d8c3e9c3fd66336"
		],
		"errors": []
	}' | ConvertFrom-Json

  It "Search-CSDevice will be called Aids count if AidOnly is OFF. (In this test, Aids count is 5.)" {
    Mock Search-CSDeviceAids { return $RetAids }
    Mock Search-CSDevice { return "Success" }
    Search-CSDeviceDetail -Token $token -HostName "Test" | Should be "Success"
    Assert-MockCalled -CommandName Search-CSDeviceAids -Time 1 -Exactly -Scope It
    Assert-MockCalled -CommandName Search-CSDevice -Time 5 -Exactly -Scope It
  }

  It "Not search-detail if AidOnly is ON." {
    Mock Search-CSDeviceAids { return $RetAids }
    Mock Search-CSDevice { return "Error. Search-CSDevice should not be called if AidOnly is ON." }
    Search-CSDeviceDetail -Token $token -HostName "Test" -AidOnly | Should be $RetAids
    Assert-MockCalled -CommandName Search-CSDeviceAids -Time 1 -Exactly -Scope It
    Assert-MockCalled -CommandName Search-CSDevice -Time 0 -Exactly -Scope It
  }
}


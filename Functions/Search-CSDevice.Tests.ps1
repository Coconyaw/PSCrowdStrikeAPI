$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$token = @{access_token = "Access_token"; token_type= "bearer"; expires_in = 1799; expiration_time = "2019/09/03 12:00:00"}

Describe "Construct-FilterString" {
	$TestCases = @(
		[ordered]@{},
		[ordered]@{hostname = "test"},
		[ordered]@{local_ip = "1.1.1.1"; external_ip = "2.2.2.2"},
		[ordered]@{hostname = "test04";
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
		$q = [ordered]@{hostname = "test"}
		$expect = "filter=hostname: '$($q.hostname)'"
		Construct-FilterString $q | Should Be $expect
	}
	It "Two params" {
		$q = [ordered]@{local_ip = "1.1.1.1"; external_ip = "2.2.2.2"}
		$expect = "filter=local_ip: '$($q.local_ip)'&external_ip: '$($q.external_ip)'"
		Construct-FilterString $q | Should Be $expect
	}
	It "all params" {
		$q = [ordered]@{hostname = "test04";
						local_ip = "3.3.3.3";
						external_ip = "4.4.4.4";
						os_version = "Windows 7";
						platform_name = "Windows";
						status = "Normal"
						}

		$expect = "filter=hostname: '$($q.hostname)'&local_ip: '$($q.local_ip)'&external_ip: '$($q.external_ip)'&os_version: '$($q.os_version)'&platform_name: '$($q.platform_name)'&status: '$($q.status)'"
		Construct-FilterString $q | Should Be $expect
	}
}

Describe "Construct-Query" {
	It "No params" {
		$q = @{offset = $null; limit = $null; filters = @{}}
		$expect = ""
		Construct-Query $q | Should Be $expect
	}

	It "Only offset 100" {
		$q = @{offset = 100; limit = $null; filters = @{}}
		$expect = "?offset=100"
		Construct-Query $q | Should Be $expect
	}

	It "Only limit 1000" {
		$q = @{offset = $null; limit = 1000; filters = @{}}
		$expect = "?limit=1000"
		Construct-Query $q | Should Be $expect
	}

	It "Only filters" {
		$q = @{offset = $null; limit = $null; filters = [ordered]@{hostname = "test"; local_ip = "1.1.1.1"}}
		$expect = "?filter=hostname: '$($q.filters.hostname)'&local_ip: '$($q.filters.local_ip)'"
		Construct-Query $q | Should Be $expect
	}

	It "offset 100 and limit 1000" {
		$q = @{offset = 100; limit = 1000; filters = @{}}
		$expect = "?offset=100&limit=1000"
		Construct-Query $q | Should Be $expect
	}

	It "offset 100 and limit 1000 and filters" {
		$q = @{offset = 100; limit = 1000; filters = [ordered]@{hostname = "test"; local_ip = "1.1.1.1"}}
		$expect = "?offset=100&limit=1000&filter=hostname: '$($q.filters.hostname)'&local_ip: '$($q.filters.local_ip)'"
		Construct-Query $q | Should Be $expect
	}
}

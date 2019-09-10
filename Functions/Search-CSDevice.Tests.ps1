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
		$expect = "hostname:'$($q.hostname)'"
		Construct-FilterString $q | Should Be $expect
	}
	It "Two params" {
		$q = [ordered]@{local_ip = "1.1.1.1"; external_ip = "2.2.2.2"}
		$expect = "local_ip:'$($q.local_ip)'+external_ip:'$($q.external_ip)'"
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

		$expect = "hostname:'$($q.hostname)'+local_ip:'$($q.local_ip)'+external_ip:'$($q.external_ip)'+os_version:'$($q.os_version)'+platform_name:'$($q.platform_name)'+status:'$($q.status)'"
		Construct-FilterString $q | Should Be $expect
	}
}

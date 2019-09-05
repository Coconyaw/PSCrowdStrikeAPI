$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$token = @{access_token = "Access_token"; token_type= "bearer"; expires_in = 1799; expiration_time = "2019/09/03 12:00:00"}

Describe "Search-CSDeviceAids" {
	$base = "/devices/queries/devices/v1"

	It "Only HostName" {
		$qs = @("hostname")
		$vs = @("Test01")

		$query = Construct-Query $qs $vs
		$endpoint = $base + "?filter=hostname: '$($vs[0])'"

		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $endpoint; }
		Search-CSDeviceAids -Token $Token -Endpoint $endpoint
		Assert-VerifiableMocks
    }

	It "Only LocalIP" {
		$qs = @("local_ip")
		$vs = @("1.1.1.1")

		$query = Construct-Query $qs $vs
		$endpoint = $base + "?filter=local_ip: '$($vs[0])'"

		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $endpoint; }
		Search-CSDeviceAids -Token $Token -Endpoint $endpoint
		Assert-VerifiableMocks
    }

	It "Use all params" {
		$qs = @("hostname", "local_ip", "external_ip", "os_version", "platform_name", "status")
		$vs = @("Test03", "3.3.3.3", "33.33.33.33", "Windows 7", "Windows", "Normal")

		$query = Construct-Query $qs $vs
		$endpoint = $base + "?filter=hostname: '$($vs[0])'"
		$endpoint += "&local_ip: '$($vs[1])'"
		$endpoint += "&external_ip: '$($vs[2])'"
		$endpoint += "&os_version: '$($vs[3])'"
		$endpoint += "&platform_name: '$($vs[4])'"
		$endpoint += "&status: '$($vs[5])'"

		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $endpoint; }
		Search-CSDeviceAids -Token $Token -Endpoint $endpoint
		Assert-VerifiableMocks
    }
	It "No params" {
		$endpoint = $base

		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $endpoint; }
		Search-CSDeviceAids -Token $Token -Endpoint $endpoint
		Assert-VerifiableMocks
    }
}

Describe "Search-CSDevice" {
	$aidRet = @{meta = @{}; resources = "1234567890"; errors = @{}}
	$base = "/devices/entities/devices/v1"
	It "Only HostName" {
		$qs = @("hostname")
		$vs = @("Test01")

		$aidQuery = "?filter=hostname: '$($vs[0])'"
		$detailQuery = $base + "?ids=$($aidRet.resources)"

		Mock Search-CSDeviceAids { return $aidRet } -Verifiable -ParameterFilter { $Token -eq $Token; $Endpoint -eq $aidQuery; }
		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $detailQuery; }
		Search-CSDevice -Token $Token -HostName $vs[0]
		Assert-VerifiableMocks
    }

	It "Only LocalIP" {
		$qs = @("local_ip")
		$vs = @("1.1.1.1")

		$aidQuery = "?filter=local_ip: '$($vs[0])'"
		$detailQuery = $base + "?ids=$($aidRet.resources)"

		Mock Search-CSDeviceAids { return $aidRet } -Verifiable -ParameterFilter { $Token -eq $Token; $Endpoint -eq $aidQuery; }
		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $detailQuery; }
		Search-CSDevice -Token $Token -LocalIp $vs[0]
		Assert-VerifiableMocks
    }

	It "Use all params" {
		$qs = @("hostname", "local_ip", "external_ip", "os_version", "platform_name", "status")
		$vs = @("Test03", "3.3.3.3", "33.33.33.33", "Windows 7", "Windows", "Normal")

		$aidQuery = $base + "?filter=hostname: '$($vs[0])'"
		$aidQuery += "&local_ip: '$($vs[1])'"
		$aidQuery += "&external_ip: '$($vs[2])'"
		$aidQuery += "&os_version: '$($vs[3])'"
		$aidQuery += "&platform_name: '$($vs[4])'"
		$aidQuery += "&status: '$($vs[5])'"

		$detailQuery = $base + "?ids=$($aidRet.resources)"

		Mock Search-CSDeviceAids { return $aidRet } -Verifiable -ParameterFilter { $Token -eq $Token; $Endpoint -eq $aidQuery; }
		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $detailQuery; }
		Search-CSDevice -Token $Token -HostName $vs[0] -LocalIp $vs[1] -ExternalIp $vs[2] -OSVersion $vs[3] -PlatForm $vs[4] -Status $vs[5]
		Assert-VerifiableMocks
    }
	It "No params" {
		$aidQuery = ""
		$detailQuery = $base + "?ids=$($aidRet.resources)"

		Mock Search-CSDeviceAids { return $aidRet } -Verifiable -ParameterFilter { $Token -eq $Token; $Endpoint -eq $endpoint; }
		Mock Invoke-CSRestMethod { return @{} } -Verifiable -ParameterFilter { $Token -eq $Token; $Method -eq "Get"; $Endpoint -eq $detailQuery; }
		Search-CSDevice -Token $Token
		Assert-VerifiableMocks
    }
}

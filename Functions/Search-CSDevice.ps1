. .\Invoke-CSRestMethod.ps1

Function Search-CSDevice {
	<#
	.SYNOPSIS
	 Search-CSDeviceAids: Wrpper of CSApi '/devices/queries/devices/v1'
	.DESCRIPTION
	 与えられたフィルタパラメータを使用してDeviceAPIに接続し、検索結果を返す
	.PARAMETER <Token>
	 Accesstoken of crowdstrike api
	.PARAMETER <HostName>
	.PARAMETER <LocalIp>
	.PARAMETER <ExternalIp>
	.PARAMETER <OSVersion>
	.PARAMETER <PlatForm>
	.PARAMETER <Status>
	.PARAMETER <Offset>
	.PARAMETER <Limit>
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	  CSAPI Result
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/02
	  Purpose/Change: Initial script development
	  
	.EXAMPLE
	 Search-CSDevice -Token $token -PlatForm Windows -Offset 100 -Limit 1000
	#>
	Param (
		[Parameter(Mandatory=$true)]
		$Token,

		[string]
		$HostName,

		[String]
		$LocalIp,

		[string]
		$ExternalIp,

		[ValidateSet("Windows 7", "Windows 10", "Windows Server 2012 R2", "Windows Server 2008 R2", "Windows Server 2016", "RHEL7.4", "CentOS 7", "Mojave")]
		[string]
		$OSVersion,

		[ValidateSet("Windows", "Mac", "Linux")]
		[string]
		$PlatForm,

		[ValidateSet("Normal", "containment_pending", "contained", "lift_containment_pending")]
		[string]
		$Status,

		[ValidateRange(1, 5000)]
		[int]
		$Offset,

		[ValidateRange(1, 5000)]
		[int]
		$Limit
	)
	
	begin {
		$base = "/devices/entities/devices/v1"
		$qparams = [ordered]@{ offset = $null; limit = $null; filters = [ordered]@{}}
	}
	
	process {
		if ($PSBoundParameters.ContainsKey("Offset")) {
			$qparams.offset = $Offset
		}

		if ($PSBoundParameters.ContainsKey("Limit")) {
			$qparams.limit = $Limit
		}

		if ($PSBoundParameters.ContainsKey("HostName")) {
			$qparams.filters.add("hostname", $HostName)
		}
		if ($PSBoundParameters.ContainsKey("LocalIp")) {
			$qparams.filters.add("local_ip", $LocalIp)
		}
		if ($PSBoundParameters.ContainsKey("ExternalIp")) {
			$qparams.filters.add("external_ip", $ExternalIp)
		}
		if ($PSBoundParameters.ContainsKey("OSVersion")) {
			$qparams.filters.add("os_version", $OSVersion)
		}
		if ($PSBoundParameters.ContainsKey("PlatForm")) {
			$qparams.filters.add("platform_name", $PlatForm)
		}
		if ($PSBoundParameters.ContainsKey("Status")) {
			$qparams.filters.add("status", $Status)
		}

		$endpoint = Construct-Query $qparams
		$aids = (Search-CSDeviceAids $Token $endpoint).resources

		if ($aids.Count -eq 0) {
			Write-Error "No aid Found: $endpoint"
		}

		foreach ($aid in $aids) {
			$query = $base + "?ids=$aid"
			Invoke-CSRestMethod -Token $Token -Method "Get" -Endpoint $query
		}
	}
	
	end {
		
	}

}

function Search-CSDeviceAids($Token, $Endpoint) {
	$base = "/devices/queries/devices/v1"
	$query = $base + $Endpoint
	Invoke-CSRestMethod -Token $Token -Endpoint $query -Method "Get"
}

function Construct-Query($qparams) {
	if ($qparams.offset -eq $null -and $qparams.limit -eq $null -and $qparams.filters.Count -eq 0) {
		return ""
	}

	$qCount = 0
	$q = "?"

	if ($qparams.offset -ne $null) {
		if ($qCount -ne 0) {
			$q += "&"
		}
		$qCount++
		$q += "offset=$($qparams.offset)"
	}

	if ($qparams.limit -ne $null) {
		if ($qCount -ne 0) {
			$q += "&"
		}
		$qCount++
		$q += "limit=$($qparams.limit)"
	}

	if ($qparams.filters.Count -gt 0) {
		if ($qCount -ne 0) {
			$q += "&"
		}
		$qCount++
		$q += Construct-FilterString $qparams.filters
	}

	return $q
}

function Construct-FilterString($fparams) {
	if ($fparams.Count -eq 0) {
		return ""
	}

	$q = "filter="
	$count = 0
	foreach ($item in $fparams.GetEnumerator()) {
		if ($count -ne 0) {
			$q += "&"
		}
		$q += "$($item.Key): '$($item.Value)'"
		$count++
	}
	return $q
}


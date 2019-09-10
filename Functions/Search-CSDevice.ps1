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
		$params = [ordered]@{}
		$filters = @{}
	}
	
	process {
		if ($PSBoundParameters.ContainsKey("Offset")) {
			$params.Add('offset', $Offset)
		}

		if ($PSBoundParameters.ContainsKey("Limit")) {
			$params.Add('limit', $Limit)
		}

		if ($PSBoundParameters.ContainsKey("HostName")) {
			$filters.add("hostname", $HostName)
		}
		if ($PSBoundParameters.ContainsKey("LocalIp")) {
			$filters.add("local_ip", $LocalIp)
		}
		if ($PSBoundParameters.ContainsKey("ExternalIp")) {
			$filters.add("external_ip", $ExternalIp)
		}
		if ($PSBoundParameters.ContainsKey("OSVersion")) {
			$filters.add("os_version", $OSVersion)
		}
		if ($PSBoundParameters.ContainsKey("PlatForm")) {
			$filters.add("platform_name", $PlatForm)
		}
		if ($PSBoundParameters.ContainsKey("Status")) {
			$filters.add("status", $Status)
		}

		if ($filters.Count -gt 0) {
			$fs = Construct-FilterString $filters
			$params.Add('filter', $fs)
		}

		$aids = (Search-CSDeviceAids $Token $Params).resources

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

function Search-CSDeviceAids($Token, $Params) {
	$endpoint = "/devices/queries/devices/v1"
	Invoke-CSRestMethod -Token $Token -Endpoint $endpoint -Method "Get" -Body $Params
}

function Construct-FilterString($fparams) {
	if ($fparams.Count -eq 0) {
		return ""
	}

	$count = 0
	foreach ($item in $fparams.GetEnumerator()) {
		if ($count -ne 0) {
			$q += "+"
		}
		$q += "$($item.Key):'$($item.Value)'"
		$count++
	}
	return $q
}


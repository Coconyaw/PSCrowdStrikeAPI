Function Search-CSDevice {
	<#
	.SYNOPSIS
	 Search-CSDevice: Get Device information from CrowdStrike
	.DESCRIPTION
	 与えられたフィルタパラメータを使用してDeviceAPIに接続し、検索結果を返す
	.PARAMETER <HostName>
	.PARAMETER <LocalIp>
	.PARAMETER <ExternalIp>
	.PARAMETER <OSVersion>
	.PARAMETER <PlatForm>
	.PARAMETER <ProductType>
	.PARAMETER <Status>
	.PARAMETER <Offset>
	.PARAMETER <Limit>
	.PARAMETER <AidOnly>
	Return device aid only.
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	  CSAPI Result
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/02
	  Purpose/Change: Delete argument of Token
	  
	.EXAMPLE
	 Search-CSDevice -PlatForm Windows -Offset 100 -Limit 1000
	 Search-CSDevice -LocalIp 10.0.0.1
	 Search-CSDevice -HostName "Test*" -Status Normal
	 Search-CSDevice -PlatForm "CentOS 7" -AidOnly
	#>
	[CmdletBinding()]
	Param (
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

		[ValidateSet("Workstation", "Server", "Domain Controller")]
		[string]
		$ProductType,

		[ValidateSet("Normal", "containment_pending", "contained", "lift_containment_pending")]
		[string]
		$Status,

		[ValidateRange(1, 5000)]
		[int]
		$Offset,

		[ValidateRange(1, 5000)]
		[int]
		$Limit,

		[Switch]
		$AidOnly
	)
	
	begin {
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
		if ($PSBoundParameters.ContainsKey("ProductType")) {
			$filters.add("product_type_desc", $ProductType)
		}
		if ($PSBoundParameters.ContainsKey("Status")) {
			$filters.add("status", $Status)
		}

		if ($filters.Count -gt 0) {
			$fs = Construct-FilterString $filters
			$params.Add('filter', $fs)
		}

		# AidOnlyフラグがOnなら、Aidだけ取得して返す
		if ($AidOnly) {
			Write-Verbose "AidOnly: Return only aids from '/devices/queries/devices/v1'"
			Search-CSDeviceAids $Params
			return
		}

		Write-Verbose "Search detail of devices from '/devices/entities/devices/v1'"
		$aids = Search-CSDeviceAids $Params

		if ($aids.Count -eq 0) {
			Write-Error "No aid Found: $endpoint"
		}

		foreach ($aid in $aids) {
			Search-CSDeviceDetail $Aid
		}
	}
	
	end {
		
	}
}

function Search-CSDeviceDetail  {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]
		$Aid
	)

	$base = "/devices/entities/devices/v1"
	$body = @{ids = $Aid}
	Invoke-CSRestMethod -Method "Get" -Endpoint $base -Body $body
}

function Search-CSDeviceAids($Params) {
	$endpoint = "/devices/queries/devices/v1"
	Invoke-CSRestMethod -Endpoint $endpoint -Method "Get" -Body $Params
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


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
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	  Success Sample:
	  @{access_token = "sample-token"; token_type = "barrer"; in_expire = 1799; expiration_time = "2019/09/03 12:00:00"}
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/02
	  Purpose/Change: Initial script development
	  
	.EXAMPLE
	  Get-CSAccessToken
	  Get-CSAccessToken -ClientId exampleId01 -ClientSecret s3cr3tkey
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
		$Status
	)
	
	begin {
		$base = "/devices/entities/devices/v1"
	}
	
	process {
		$qs = @() # query param name
		$vs = @() # query param value
		if ($PSBoundParameters.ContainsKey("HostName")) {
			$qs += "hostname"
			$vs += $HostName
		}
		if ($PSBoundParameters.ContainsKey("LocalIp")) {
			$qs += "local_ip"
			$vs += $LocalIp
		}
		if ($PSBoundParameters.ContainsKey("ExternalIp")) {
			$qs += "external_ip"
			$vs += $ExternalIp
		}
		if ($PSBoundParameters.ContainsKey("OSVersion")) {
			$qs += "os_version"
			$vs += $OSVersion
		}
		if ($PSBoundParameters.ContainsKey("PlatForm")) {
			$qs += "platform_name"
			$vs += $PlatForm
		}
		if ($PSBoundParameters.ContainsKey("Status")) {
			$qs += "status"
			$vs += $Status
		}

		$endpoint = Construct-Query $qs $vs
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

function Construct-Query([string[]] $qs, [string[]] $vs) {
	$query = "?filter="
	for ($i = 0; $i -lt $qs.Count; $i++) {
		if ($i -ne 0) {
				$query += "&"
		}
		$query += "$($qs[$i]): '$($vs[$i])'"
	}
	return $query
}

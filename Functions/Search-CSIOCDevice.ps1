function Search-CSIOCDevice {
	<#
	.SYNOPSIS
	Search the device deteil info which access spesified IoC.
	.DESCRIPTION
	.PARAMETER <Type>
		The type of indicator from the list of supported indicator types.
		Supported type: domain, md5, sha256
	.PARAMETER <Value>
		The actual string representation of your indicator.
	.PARAMETER <Limit>
		Result limit
	.PARAMETER <AidOnly>
		Get only aid
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/24
	  Purpose/Change: Delete argument of Token
	.EXAMPLE
	  Search-CSIOCDevice -Type domain -Value www.example.com -Limit 10
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateSet("domain", "md5", "sha256")]
		[string]
		$Type,

		[Parameter(Mandatory=$true)]
		$Value,

		# TODO: implements offset
		# [ValidatePattern()]
		# [string]
		# $Offset,

		[ValidateRange(0, 100)]
		[int]
		$Limit,

		[Switch]
		$AidOnly
	)
	
	process {
		if ($PSBoundParameters.ContainsKey('Limit')) {
			$ret = Search-CSIOCDeviceAid -Type $Type -Value $Value -Limit $Limit
		} else {
			$ret = Search-CSIOCDeviceAid -Type $Type -Value $Value
		}

		# AidOnlyフラグがOnなら、Aidだけ取得して返す
		if ($AidOnly) {
			Write-Verbose "AidOnly: Return only aids from '/indicators/queries/devices/v1'"
			return $ret
		}

		$aids = $ret

		foreach ($aid in $aids) {
			Search-CSDeviceDetail -Aid $aid
		}
	}
}

function Search-CSIOCDeviceAid {
	<#
	.SYNOPSIS
	Get detailed information of the device.
	.PARAMETER <Type>
		The type of indicator from the list of supported indicator types.
		Supported type: domain, md5, sha256
	.PARAMETER <Value>
		The actual string representation of your indicator.
	.PARAMETER <Limit>
		Result limit
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/24
	  Purpose/Change: Delete Argument of Token
	.EXAMPLE
	  Search-CSIOCDeviceAid -Type domain -Value www.example.com -Limit 10
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateSet("domain", "md5", "sha256")]
		[string]
		$Type,

		[Parameter(Mandatory=$true)]
		$Value,

		# TODO: implements offset
		# [ValidatePattern()]
		# [string]
		# $Offset,

		[ValidateRange(0, 100)]
		[int]
		$Limit
	)
	
	begin {
		$base = "/indicators/queries/devices/v1"
		$body = @{type = $Type; value = $Value}
		if ($PSBoundParameters.ContainsKey('Limit')) {
			$body.Add('limit', $Limit)
		}
	}
	
	process {
		$method = "Get"
		Invoke-CSRestMethod -Method $method -Endpoint $base -Body $body
	}
}

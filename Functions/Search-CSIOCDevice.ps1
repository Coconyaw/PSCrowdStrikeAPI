function Search-CSIOCDevice {
	<#
	.SYNOPSIS
	Invoke Search-CSIOCDeviceAid, then invoke Search-CSDeviceDetail to get detail of the machine.
	.DESCRIPTION
	
	.PARAMETER <Token>
	    Token: Access token of CrowdStike oauth2. Get from Get-CSAccessToken cmdlet.
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
	  Purpose/Change: Initial script development
	.EXAMPLE
	  Search-CSIOCDeviceDetail -Token $Token -Type domain -Value www.example.com -Limit 10
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Token,

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
			$ret = Search-CSIOCDeviceAid -Token $Token -Type $Type -Value $Value -Limit $Limit
		} else {
			$ret = Search-CSIOCDeviceAid -Token $Token -Type $Type -Value $Value
		}

		# AidOnlyフラグがOnなら、Aidだけ取得して返す
		if ($AidOnly) {
			Write-Verbose "AidOnly: Return only aids from '/indicators/queries/devices/v1'"
			return $ret
		}

		$aids = $ret.resources

		foreach ($aid in $aids) {
			Search-CSDeviceDetail -Token $Token -Aid $aid
		}
	}
}

function Search-CSIOCDeviceAid {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
	.PARAMETER <Token>
	    Token: Access token of CrowdStike oauth2. Get from Get-CSAccessToken cmdlet.
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
	  Purpose/Change: Initial script development
	.EXAMPLE
	  Search-CSIOCDeviceAid -Token $Token -Type domain -Value www.example.com -Limit 10
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Token,

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
		Invoke-CSRestMethod -Token $Token -Method $method -Endpoint $base -Body $body
	}
}

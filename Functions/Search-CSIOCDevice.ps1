function Search-CSIOCDevice {
	<#
	.SYNOPSIS
	 Invoke-CSRestMethod: Wrraper of Invoke-RestMethod for CrowdStrike API
	.DESCRIPTION
	 与えられたToken,EndpointUrl,Method,BodyからRequestを作成し、API呼び出しを行い結果を返す
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
	  Creation Date:  2019/09/06
	  Purpose/Change: Initial script development
	.EXAMPLE
	  Search-CSIOCDevice -Token $Token -Type domain -Value www.example.com -Limit 10
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

		[ValidateRange(1, 5000)]
		[int]
		$Limit
	)
	
	begin {
		$base = "/indicators/queries/devices/v1"
		$body = @{type = $Type; value = $Value}
		if ($PSBoundParameters.ContainsKey('Limit')) {
			$body.Add('limit', $Limit)
		}
		$header = @{
			Accept = "application/json"
			Authorization = "$($Token.token_type) $($Token.access_token)"
		}
	}
	
	process {
		$method = "Get"
		$aids = (Invoke-CSRestMethod -Token $Token -Method $method -Endpoint $base -Body $body).resources
		foreach ($aid in $aids) {
			Search-CSDevice -Token $Token -Aid $aid
		}
	}
	
	end {
		
	}
}

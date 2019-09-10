function Search-CSIOCDeviceCount {
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
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	  Success Sample object.:
		meta      : @{query_time=0.008894851; trace_id=2ca74af5-81be-49da-950e-b08b3ae72387}
		resources : {@{id=domain:www.sample.com; type=domain; value=www.sample.com; device_count=3}}
		errors    : {}
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/06
	  Purpose/Change: Initial script development
	  
	.EXAMPLE
	  Search-CSIOCDeviceCount -Token $Token -Type domain -Value www.example.com
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
		$Value
	)
	
	begin {
		$base = "/indicators/aggregates/devices-count/v1"
		$body = @{type = $Type; value = $Value}
		$header = @{
			Accept = "application/json"
			Authorization = "$($Token.token_type) $($Token.access_token)"
		}
	}
	
	process {
		$method = "Get"
		Invoke-CSRestMethod -Token $Token -Method $method -Endpoint $base -Body $body
	}
	
	end {
		
	}
}

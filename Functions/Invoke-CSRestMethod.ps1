function Invoke-CSRestMethod {
	<#
	.SYNOPSIS
	 Invoke-CSRestMethod: Wrraper of Invoke-RestMethod for CrowdStrike API
	.DESCRIPTION
	 与えられたEndpointUrl,Method,BodyからRequestを作成し、API呼び出しを行い結果を返す
	.PARAMETER <Endpoint>
		Endpoint: request api endpoint from crowdstrike
	.PARAMETER <Method>
		Method: HTTP Method of REST API.
	.PARAMETER <Body>
		Body: Body of REST API
	.INPUTS
	.OUTPUTS
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/03
	  Purpose/Change: Delete argument of Token.
	.EXAMPLE
	  Invoke-CSRestMethod -Endpoint "device/entities/queries/v1?filter=limit: 10" -Method Get
	  Invoke-CSRestMethod -Endpoint "device/entities/queries/v1?filter=limit: 10" -Method Post -Body $body
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[string]
		$Endpoint,

		[Parameter(Mandatory=$true)]
		[ValidateSet("Get", "Post", "Patch", "Delete")]
		[string]
		$Method,

		[Parameter(Mandatory=$false)]
		$Body
	)
	
	begin {
		$Token = Get-CSAccessToken
		Write-Verbose "Got Token. Expired time: $($Token.expiration_time)"

		$baseUrl = "https://api.crowdstrike.com"
		$url = $baseUrl + $Endpoint
		Write-Verbose "Method:$Method, URL:$url"

		$header = @{
			Accept = "application/json"
			Authorization = "$($Token.token_type) $($Token.access_token)"
		}
	}
	
	process {
		if ($PSBoundParameters.ContainsKey('Body')) {
			# $b = $Body | ConvertTo-Json
			$header.Add("Content-Type", "application/json")
			Invoke-RestMethod -Uri $url -Method $Method -Headers $header -Body $Body
		} else {
			Invoke-RestMethod -Uri $url -Method $Method -Headers $header
		}
	}
	
	end {
		
	}
}

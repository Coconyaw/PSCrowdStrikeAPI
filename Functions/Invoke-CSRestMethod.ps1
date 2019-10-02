function Invoke-CSRestMethod {
	<#
	.SYNOPSIS
	 Invoke-CSRestMethod: Wrraper of Invoke-RestMethod for CrowdStrike API
	.DESCRIPTION
	 与えられたToken,EndpointUrl,Method,BodyからRequestを作成し、API呼び出しを行い結果を返す
	.PARAMETER <Token>
	    Token: Access token of CrowdStike oauth2. Get from Get-CSAccessToken cmdlet.
	.PARAMETER <Endpoint>
		Endpoint: request api endpoint from crowdstrike
	.PARAMETER <Method>
		Method: HTTP Method of REST API.
	.PARAMETER <Body>
		Body: Body of REST API
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	  Success Sample:
	  @{access_token = "sample-token"; token_type = "barrer"; in_expire = 1799; expiration_time = "2019/09/03 12:00:00"}
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/03
	  Purpose/Change: Initial script development
	  
	.EXAMPLE
	  Invoke-CSRestMethod -Token $token -Endpoint "device/entities/queries/v1?filter=limit: 10" -Method Get
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		$Token,

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
		if ($PSBoundParameters.ContainsKey('Token')) {
			$Token = Get-CSAccessToken
		}
		$baseUrl = "https://api.crowdstrike.com"
		$url = $baseUrl + $Endpoint
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

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
		In case GET method, you can pass the body type [PSCustomObject].
		In case POST method, you must pas the body that was converted to json.
	.INPUTS
	.OUTPUTS
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/12/02
	  Purpose/Change: Add examle for reqeust with body parameter.
	.EXAMPLE
	  # Get Request without body
	  Invoke-CSRestMethod -Endpoint "device/entities/queries/v1?filter=limit: 10" -Method Get
	.EXAMPLE
	  # Get Request with body
	  $body = [ordered]@{q = "SampleHost}
	  Invoke-CSRestMethod -Endpoint "device/entities/queries/v1?filter=limit: 10" -Method Post -Body $body
	.EXAMPLE
	  # Post Request
	  $BodyObject = [ordered]@{q = "SampleHost}
	  $body = $BodyObject | ConvertTo-Json
	  Invoke-CSRestMethod -Endpoint "detects/entities/summaries/GET/v1" -Method Post -Body $body
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
			Write-Verbose "Body:"
			Write-Verbose $Body

			$header.Add("Content-Type", "application/json")
			(Invoke-RestMethod -Uri $url -Method $Method -Headers $header -Body $Body).resources
		} else {
			(Invoke-RestMethod -Uri $url -Method $Method -Headers $header).resources
		}
	}
	
	end {
		
	}
}

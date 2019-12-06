function Search-CSDetection {
	<#
	.SYNOPSIS
	 Search-CSDetetion: Get detection information from CrowdStrike
	.DESCRIPTION
	 This function allows you to vie detection detail.
	.PARAMETER <q>
	 Full text search across all metadata fields.
	 Reference: https://assets.falcon.crowdstrike.com/support/api/swagger.html#/detects/QueryDetects
	.INPUTS
	 Query string.
	.OUTPUTS
	 CSAPI Result
	.NOTES
	 Version:        1.0
	 Author:         Coconyaw
	 Creation Date:  2019/12/06
	 Purpose/Change: None
	  
	.EXAMPLE
	 Search-CSDetection -q "username"
	#>
	[CmdletBinding()]
	Param (
		# q :query string
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$q
	)

	Process {
		$ids = Search-CSDetectionIds -q $q
		if ($null -eq $ids) {
			Throw "Search-CSDetection: No detection id"
		}

		Search-CSDetectionDetail $ids
	}
}

function Search-CSDetectionIds {
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$q
	)

	$base = "/detects/queries/detects/v1"
	$body = @{ q = $q }
	return Invoke-CSRestMethod -Endpoint $base -Method "Get" -Body $body
}

function Search-CSDetectionDetail {
	param (
		[string[]] $ids
	)

	$base = "/detects/entities/summaries/GET/v1"
	$body = @{ ids = $ids } | ConvertTo-Json
	return Invoke-CSRestMethod -Endpoint $base -Method "Post" -Body $body
}

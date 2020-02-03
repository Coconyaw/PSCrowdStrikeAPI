class Config{
  [string]$client_id
  [string]$client_secret
}

function Set-CSConfig {
<#
	.SYNOPSIS
	 Create configfile.
	.DESCRIPTION
	 Create Configfile for api client.
	 Set ClientID and ClientSecret with json format to configfile.
	 Default path of configfile: $home\.config\PSCrowdStrikeApi\csconfig.json
	.PARAMETER <Path>
	 Path of configfile to be created.
	 default:.$home\.config\PSCrowdStrikeApi\csconfig.json
	 Get-CSAccessToken cmdlet refer default configfile path.
	.PARAMETER <ClientId>
	 Client ID
	 If you not specified, input interactively.
	.PARAMETER <ClientSecret>
	 Client Secret
	 If you not specified, input interactively.
	.EXAMPLE
	 Set-CSConfig
	.EXAMPLE
	 Set-CSConfig -Path .\csconfig.json -ClientId idstring -ClientSecret secretstring
	.NOTES
	#>

  [CmdletBinding()]
  param(
    [string]
    $Path,

    [string]
    $ClientId,

    [string]
    $ClientSecret
  )

  process {
    if (!$PSBoundParameters.ContainsKey("Path")) {
      $Path = "$home\.config\PSCrowdStrikeApi\csconfig.json"
    }
    if (!$PSBoundParameters.ContainsKey("ClientId")) {
      $ClientId = Read-Host "Enter your client id"
    }
    if (!$PSBoundParameters.ContainsKey("ClientSecret")) {
      $ClientSecret = Read-Host "Enter your client secret"
    }

    $conf = New-Object -TypeName Config
    $conf.client_id = $ClientId
    $conf.client_secret = $ClientSecret

    $conf | ConvertTo-Json -Compress | Out-File -LiteralPath $Path
  }
}

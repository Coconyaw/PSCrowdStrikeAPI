function Get-CSAccessToken {
	<#
	.SYNOPSIS
	 Get-CSAccessToken: Get CrowdStrike oauth API accesstoken with REST API
	.DESCRIPTION
	 与えられたClientIDとClientSecretを使用して、CrowdStrikeのAPIアクセストークン取得用REST APIを発行し、アクセストークンを取得する
	 取得したアクセストークンはキャッシュファイルに保存し、有効期限内であればキャッシュから値を返却する。
	 ClientIdとClientSecretはコンフィグファイルに保存した値を使用することもできる。
	.PARAMETER <ClientId>
	    ClientId: client_id of crowdstrike rest api
	.PARAMETER <ClientSecret>
	    ClientSecret: client_secret of crowdstrike rest api
	.PARAMETER <Config>
	    Config: Path to configuration file.
		Format: json
		Default: $home\.config\PSCrowdStrikeApi\csconfig.json
		sample: { "client_id": "sample_id_123abc", "client_secret": "sample_secret_password"}
	.PARAMETER <cache>
	    Config: Path to cache file.
		Format: json
		Default: $home\.config\PSCrowdStrikeApi\cscache.json
		Sample: { 'access_token':  'Cached_Token', 'token_type':  'bearer', 'expires_in':  1799, 'expiration_time':  '2019/09/03 12:00:00' }
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

	[CmdletBinding()]
	param (
		[string]
		$ClientId,

		[string]
		$ClientSecret,

		[string]
		$Config,

		[string]
		$Cache
	)

	begin {
		# Initialize Credential
		$ConfigBasePath = Join-Path -Path $home -ChildPath ".config" | Join-Path -ChildPath "PSCrowdStrikeApi"
		if ($ClientId -eq "" -or $SecretKey -eq "") {
			if ($Config -eq "") { $Config = Join-Path -Path $ConfigBasePath -ChildPath "csconfig.json" } # Use default config path.
			Write-Verbose "[+] Use config credential."

			if (!(Test-Path $Config)) { throw "ConfigFileNotFoundError" }

			$cred = Get-Content $Config | ConvertFrom-Json
			$ClientId = $cred.client_id
			$ClientSecret = $cred.client_secret
		}

		# Initialize cache file path
		if ($Cache -eq "") { $Cache = Join-Path -Path $ConfigBasePath -ChildPath "cscache.json" }

		# Load cache
		$cacheValue = $null
		if (Test-Path $Cache) {
			$cacheValue = Get-Content $Cache | ConvertFrom-Json
		}
	}

	process {

		# キャッシュがあったらtokenの有効期限をチェックし、期限内ならキャッシュから値を返す
		if ($cacheValue -ne $null) {
			$expiresTime = Get-Date $cacheValue.expiration_time
			$now = Get-Date
			if ($now.CompareTo($expiresTime) -eq -1) {
				$ret = Get-Content $Cache | ConvertFrom-Json
				return $ret
			}
		}

		try {
			$params = Construct-RestParams $ClientID $ClientSecret
			$ret = Invoke-RestMethod @params
		}
		catch {
			$err = $_ | ConvertFrom-Json
			throw $err
		}

		# キャッシュを作成
		Create-Cache $Cache $ret

		# Reurn Output
		$ret
	}
}

function Create-Cache($path, $cache) {
		$expiresTime = (Get-Date).AddSeconds($cache.expires_in).ToString()
		$cache | Add-Member -MemberType NoteProperty -Name "expiration_time" -Value $expiresTime -Force
		$json = $ret | ConvertTo-Json
		Set-Content $path -Value $json
}

function Construct-RestParams($ClientID, $ClientSecret) {
	$p = @{
		Uri = "https://api.crowdstrike.com/oauth2/token"
		Method = "Post"
		Headers = @{
			"Accept" = "application/json"
			"Content-Type" = "application/x-www-form-urlencoded"
		}
		Body = "client_id=$ClientID&client_secret=$ClientSecret"
	}
	return $p
}

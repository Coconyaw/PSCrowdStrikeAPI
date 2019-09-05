$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

function Remove-CacheAndConfig() {
	if (Test-Path $cachePath) {
		Remove-Item $cachePath
	}
	if (Test-Path $configPath) {
		Remove-Item $configPath
	}
}

Describe "Get-CSAccessToken" {

	$token = @{access_token = "Test_Token"; token_type = "bearer"; expires_in =1799}
	$oauthUri = "https://api.crowdstrike.com/oauth2/token"
	$ctype = "application/x-www-form-urlencoded"
	$ClientId = "1c98b7be5a764ed39936c77a7b54f216"
	$SecretKey = "J2509xF3m7l8Ggua4VD6APnIOCLHtUMzWcqYf1pK"
	$body = "client_id=$ClientId&client_secret=$SecretKey"
	$configPath = "TestDrive:\.csconfig.json"
	$config = '{ "client_id": "1c98b7be5a764ed39936c77a7b54f216", "client_secret": "J2509xF3m7l8Ggua4VD6APnIOCLHtUMzWcqYf1pK"}'
	$expire = (Get-Date).AddMinutes(1).ToString()
	$cachePath = "TestDrive:\.cscache.json"
	$cache = "{ 'access_token':  'Cached_Token', 'token_type':  'bearer', 'expires_in':  1799, 'expiration_time':  '$expire' }"
	$p = @{
		Uri = "https://api.crowdstrike.com/oauth2/token"
		Method = "Post"
		Headers = @{
			"Accept" = "application/json"
			"Content-Type" = "application/x-www-form-urlencoded"
		}
		Body = "client_id=$ClientID&client_secret=$ClientSecret"
	}

	# ClientIdとSecKeyを渡したら、そのIDパスを使用してOauthAPIにアクセスし、AccessTokenを取得すること
	Context "Use ClientId and ClientSecret Param" {
		It "Valid Credential" {
			Remove-CacheAndConfig
			Mock Invoke-RestMethod  { return $token } -Verifiable
			$result = Get-CSAccessToken -ClientId $ClientID -ClientSecret $SecretKey -Cache $cachePath
			Assert-VerifiableMocks
			$result.access_token | Should be $token.access_token
		}
	}
	

	# 事前設定のコンフィグファイルを使用
	Context "Use config file" {
		It "Exist config and valid config." {
			Remove-CacheAndConfig
			# デフォルトのAPIkeyが格納されたファイルを用意
			Set-Content $configPath -Value $config

			Mock Invoke-RestMethod  { return $token } -Verifiable
			$result = Get-CSAccessToken -Config $configPath -Cache $cachePath
			Assert-VerifiableMocks
			$result.access_token | Should be $token.access_token
		}
		
		It "No config file" {
			Remove-CacheAndConfig
			{ Get-CSAccessToken -Config $configPath -Cache $cachePath } | Should throw "ConfigFileNotFoundError"
		}
	}
	

	# ClientIdかSeckeyが間違っていてエラーになった場合はErrorを返す
	Context "Miss ClientID or ClientSecret" {
		$errRes = '{ "meta": { "query_time": 0.16625877, "powered_by": "csam", "trace_id": "61f599a5-c3e5-4d75-93f3-dadeaa1736e5" }, "errors": [ { "code": 403, "message": "Failed to issue access token - Not Authorized" } ] }'
		It "Miss ClientID" {
			Remove-CacheAndConfig
			Mock Invoke-RestMethod  { throw $errRes }
			$expectedErr = $errRes | ConvertFrom-Json
			{ Get-CSAccessToken -ClientId "test" -ClientSecret "J2509xF3m7l8Ggua4VD6APnIOCLHtUMzWcqYf1pK" -Cache $cachePath } | Should throw $expectedErr
		}
		It "Miss ClientSecret" {
			Remove-CacheAndConfig
			Mock Invoke-RestMethod  { throw $errRes }
			$expectedErr = $errRes | ConvertFrom-Json
			{ Get-CSAccessToken -ClientId "1c98b7be5a764ed39936c77a7b54f216" -ClientSecret "test" -Cache $cachePath} | Should throw $expectedErr
		}
		It "Miss both ClientID and ClientSecret" {
			Remove-CacheAndConfig
			Mock Invoke-RestMethod  { throw $errRes }
			$expectedErr = $errRes | ConvertFrom-Json
			{ Get-CSAccessToken -ClientId "test" -ClientSecret "test" -Cache $cachePath} | Should throw $expectedErr
		}
	}

	Context "Cache Test" {
		$cachedToken = $cache | ConvertFrom-Json

		It "Not expired then return from cache." {
			Remove-CacheAndConfig
			Set-Content $cachePath -Value $cache

			# このMockが呼ばれているということはCacheから値を返していないということなのでテストは失敗
			Mock Invoke-RestMethod  { return $token }

			$result = Get-CSAccessToken -ClientId $ClientID -ClientSecret $SecretKey -Cache $cachePath
			$result.access_token | Should be $cachedToken.access_token
		}

		It "Expired then return from cs oauth api." {
			Remove-CacheAndConfig
			Set-Content $cachePath -Value $cache

			Mock Invoke-RestMethod  { return $token }

			$result = Get-CSAccessToken -ClientId $ClientID -ClientSecret $SecretKey -Cache $cachePath
			$result.access_token | Should be $cachedToken.access_token
		}
	}
}

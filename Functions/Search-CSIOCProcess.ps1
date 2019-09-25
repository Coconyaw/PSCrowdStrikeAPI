function Search-CSIOCProcess {
	<#
	.SYNOPSIS
	 Search-CSIOCProcess: Find the process which related to IoC.
	.DESCRIPTION
	 IoCとDeviceIDに合致するプロセスIDを検索し、プロセスIDから、プロセスの詳細を取得する
	.PARAMETER <Token>
	    Token: Access token of CrowdStike oauth2. Get from Get-CSAccessToken cmdlet.
	.PARAMETER <Type>
		The type of indicator from the list of supported indicator types.
		Supported type: domain, md5, sha256
	.PARAMETER <Value>
		The actual string representation of your indicator.
	.PARAMETER <DeviceId>
		The device ID you want to specifically check against.
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
	  Search-CSIOCProcess -Token $Token -Type domain -Value www.example.com -DeviceId "123abc" -Limit 10
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		$Token,

		[Parameter(Mandatory=$true)]
		[ValidateSet("domain", "md5", "sha256")]
		[string]
		$Type,

		[Parameter(Mandatory=$true)]
		[string]
		$Value,

		[Parameter(Mandatory=$true)]
		[string]
		$DeviceId,

		[ValidateRange(0, 100)]
		[int]
		$Limit
	)

	Begin {
		$base = "/processes/entities/processes/v1"
	}

	Process {
		if ($PSBoundParameters.ContainsKey('Limit')) {
			$pids = (Search-CSIOCProcessId -Token $Token -Type $Type -Value $Value -DeviceId $DeviceId -Limit $Limit).resources
		} else {
			$pids = (Search-CSIOCProcessId -Token $Token -Type $Type -Value $Value -DeviceId $DeviceId).resources
		}

		foreach ($id in $pids) {
			$body = @{ids = $id}
			Invoke-CSRestMethod -Token $Token -Method "Get" -Endpoint $base -Body $body
		}
	}
}

function Search-CSIOCProcessId {
	<#
	.SYNOPSIS
	 Search-CSIOCProcess: Find the process ID of an indicator that ran on a device recently. Provide the type and value of an IOC and a device ID.
	.DESCRIPTION
	 IoCとDeviceIDに合致するプロセスIDを検索する
	.PARAMETER <Token>
	    Token: Access token of CrowdStike oauth2. Get from Get-CSAccessToken cmdlet.
	.PARAMETER <Type>
		The type of indicator from the list of supported indicator types.
		Supported type: domain, md5, sha256
	.PARAMETER <Value>
		The actual string representation of your indicator.
	.PARAMETER <DeviceId>
		The device ID you want to specifically check against.
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
	  Search-CSIOCProcess -Token $Token -Type domain -Value www.example.com -DeviceId "123abc" -Limit 10
	#>

	Param (
		[Parameter(Mandatory=$true)]
		$Token,

		[Parameter(Mandatory=$true)]
		[ValidateSet("domain", "md5", "sha256")]
		[string]
		$Type,

		[Parameter(Mandatory=$true)]
		[string]
		$Value,

		[Parameter(Mandatory=$true)]
		[string]
		$DeviceId,

		[ValidateRange(0, 100)]
		[int]
		$Limit
	)

	Begin {
		$base = "/indicators/queries/processes/v1"
		$body = @{type = $Type; value = $Value; device_id = $DeviceId;}
		if ($PSBoundParameters.ContainsKey('Limit')) {
			$body.Add('Limit', $Limit)
		}
	}

	Process {
		Invoke-CSRestMethod -Token $Token -Method "Get" -Endpoint $base -Body $body
	}
}

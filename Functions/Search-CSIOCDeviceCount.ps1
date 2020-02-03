function Search-CSIOCDeviceCount {
<#
	.SYNOPSIS
	 Get the count of devices accessed specified IoC.
	.PARAMETER <Type>
		The type of indicator from the list of supported indicator types.
		Supported type: domain, md5, sha256
	.PARAMETER <Value>
		The actual string representation of your indicator.
	.INPUTS
	  <Inputs if any, otherwise state None>
	.OUTPUTS
	  Success Sample object.:
		@{id=domain:www.sample.com; type=domain; value=www.sample.com; device_count=3}
	.NOTES
	  Version:        1.0
	  Author:         Kazuma Takahashi
	  Creation Date:  2019/09/06
	  Purpose/Change: Delete argument of Token.
	  
	.EXAMPLE
	  Search-CSIOCDeviceCount -Type domain -Value www.example.com
	#>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("domain","md5","sha256")]
    [string]
    $Type,

    [Parameter(Mandatory = $true)]
    $Value
  )

  begin {
    $base = "/indicators/aggregates/devices-count/v1"
    $body = @{ type = $Type; value = $Value }
  }

  process {
    $method = "Get"
    Invoke-CSRestMethod -Method $method -Endpoint $base -Body $body
  }

  end {

  }
}

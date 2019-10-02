function New-CSRTRSession {
	<#
	.SYNOPSIS
	Initialize a new session with the RTR cloud.
	.DESCRIPTION
	.EXAMPLE
	New-CSRTRSession -Token Get-CSAccessToken -Aid 123abc
	.INPUTS
	None
	.PARAMETER Aid
	The Aid you want to connect
	.OUTPUTS
	.NOTES
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Token,

		[Parameter(Mandatory = $true)]
		[string]
		$Aid
	)

	begin {
		$base = "/real-time-response/entities/sessions/v1"
		$body = @{"device_id" = $Aid} | ConvertTo-Json
	}

	process {
		Invoke-CSRestMethod -Token $Token -Endpoint $base -Method "POST" -Body $body
	}

	end {

	}
}

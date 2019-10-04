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
	.Sample
	New-CSRTRSession -Aid 123abc
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Aid
	)

	begin {
		$base = "/real-time-response/entities/sessions/v1"
		$body = @{"device_id" = $Aid} | ConvertTo-Json
	}

	process {
		Invoke-CSRestMethod -Endpoint $base -Method "POST" -Body $body
	}

	end {

	}
}

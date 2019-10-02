function Start-CSRTRCommand {
	<#
	.SYNOPSIS
	Execute a command on a single host.
	.DESCRIPTION
	.EXAMPLE
	 Start-CSRTRCommand -Token Get-CSAccessToken -Aid 123abc
	.INPUTS
	None
	.PARAMETER Aid
	The Aid you want to connect
	.OUTPUTS
	.NOTES
	#>

	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		$Token,

		[Parameter(Mandatory=$true)]
		[ValidateSet("cat", "cd", "clear", "cp", "encrypt", "env", "eventlog", "filehash", "get", "getsid", "help", "history", "ipconfig", "kill", "ls", "map", "memdump", "mkdir", "mount", "mv", "netstat", "ps", "reg, query", "reg, set", "reg, delete", "reg, load", "reg, unload", "restart", "rm", "runscript", "shutdown", "unmap", "xmemdump", "zip")]
		[String]
		$BaseCommand,

		[Parameter(Mandatory=$true)]
		[String]
		$CommandString,

		[Parameter(Mandatory=$true)]
		[String]
		$SessionId
	)

	Begin {
		$base = "/real-time-response/entities/active-responder-command/v1"
		$body = @{"base_command" = $BaseCommand; "command_string" = $CommandString; "session_id" = $SessionId; "persist" = $true} | ConvertTo-Json
	}

	Process {
		Invoke-CSRestMethod -Token $Token -Endpoint $base -Method "Post" -Body $body
	}

	End {

	}
}

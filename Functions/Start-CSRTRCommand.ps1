function Start-CSRTRCommand {
<#
	.SYNOPSIS
	 Execute a command on a single host.
	.PARAMETER <BaseCommand>
	.PARAMETER <CommandString>
	.PARAMETER <SessionId>
	.EXAMPLE
	 Start-CSRTRCommand -BaseCommand cat -CommandString "cat C:\sample.txt" -SessionId abc123
	.INPUTS
	.OUTPUTS
	.NOTES
	#>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("cat","cd","clear","cp","encrypt","env","eventlog","filehash","get","getsid","help","history","ipconfig","kill","ls","map","memdump","mkdir","mount","mv","netstat","ps","reg, query","reg, set","reg, delete","reg, load","reg, unload","restart","rm","runscript","shutdown","unmap","xmemdump","zip")]
    [string]
    $BaseCommand,

    [Parameter(Mandatory = $true)]
    [string]
    $CommandString,

    [Parameter(Mandatory = $true)]
    [string]
    $SessionId
  )

  begin {
    $base = "/real-time-response/entities/active-responder-command/v1"
    $body = @{ "base_command" = $BaseCommand; "command_string" = $CommandString; "session_id" = $SessionId; "persist" = $true } | ConvertTo-Json
  }

  process {
    Invoke-CSRestMethod -Endpoint $base -Method "Post" -Body $body
  }

  end {

  }
}

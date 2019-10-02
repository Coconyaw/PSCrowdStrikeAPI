$src = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions/*.ps1') -Recurse -ErrorAction Stop)

Foreach ($s in $src) {
	if ($s.Name -Match ".Test.") {
		continue
	}

	if ($s.Name -Match "test") {
		continue
	}

	try {
		. $s.FullName
	}
	catch {
		throw "Load Error [$($s.FullName)]"
	}
}

$FunctionsToExport = 'Get-CSAccessToken', 'Search-CSDevice', 'Search-CSDeviceDetail', 'Search-CSIOCDeviceCount', `
					 'Search-CSIOCDevice', 'Search-CSIOCProcess', 'New-CSRTRSession', 'Start-CSRTRCommand'

Export-ModuleMember -Function $FunctionsToExport

Function Show-IisLogFile {
	Param(
		[string[]]$logfile
	)
	if (Test-Path $logfile) {
		Get-Content $logfile | ? {$_ -notmatch "^#"} | ConvertFrom-CSV -Delimiter " " -Header @("Date","Time","ServerIP","Method","URIStem","Query","Port","Username","ClientIP","User-Agent","SC-Status","SC-Substatus","SC-Win32-Status","Time-Taken") | Out-Gridview -Title "IIS Logfile Content - $($logfile)"
	} else {
		return "Invalid filepath specified!"
	}
}
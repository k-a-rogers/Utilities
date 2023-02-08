Function Check-HostsFile {
	[System.Collections.ArrayList]$hostentries=@()
	$hostsfile=get-content $("$env:windir\system32\drivers\etc\hosts") |?{$_ -notmatch "^#" -and $_.Length -gt 0}
	
	if ($hostsfile) {
		foreach ($line in $hostsfile) {
			if ($line -match "`t") {
				$line=$line -replace "`t"," "
			}
			while ($line -match "  ") {
				$line=$line -replace "  "," "
			}
			if ($line -match "^ ") {
				$line=$line.TrimStart(" ")
			}
			$hash= @{
				hostname = ($line -split " ")[1]
				IP = ($line -split " ")[0]
			}
			$obj = New-Object -TypeName PSObject -Property $hash
			$hostentries.Add($Obj) | Out-Null
			Remove-variable -name hash,obj
		}
			
		# Compare arraylist entries against local DNS values
		[System.Collections.ArrayList]$conflicts=@()

		foreach ($entry in $hostentries) {
			try {
				$DNS = Resolve-DNSName $entry.hostname -DNSOnly -ErrorAction Stop
			} catch {
				$DNS = $Null
			}
			if ($DNS -and ($DNS | ? {$_.Type -eq "A"}).IPAddress -ne $entry.IP) {
				$hash= @{
					hostname = $entry.hostname
					HostsIP = $entry.IP
					DNSIP = ($DNS | ? {$_.Type -eq "A"}).IPAddress
				}
				$obj = New-Object -TypeName PSObject -Property $hash
				$conflicts.Add($Obj) | Out-Null
				Remove-variable -name hash,obj
			}
		}
		
		if ($conflicts) {
			return $conflicts
		} else {
			return "No conflicts found between DNS and hosts file."
		}
	} else {
		return "No entries found in hosts file."
	}
}
Check-HostsFile
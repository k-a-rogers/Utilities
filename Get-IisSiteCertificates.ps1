Function Get-IisSiteCertificate {
	param (
		[parameter()]
		[string]$URI
	)
	if ($URI) {
		$sites=Get-Website -Name $URI
	} else {
		$sites=Get-Website
	}
	[System.Collections.ArrayList]$sitelist=@()
	foreach ($site in $sites) {
		foreach ($binding in $site.Bindings.collection | ? {$_.Protocol -eq "https"}) {
			if ($binding.CertificateHash -ne $null) {
				$hash= [ordered]@{
					Site = $site.Name
					CertName = $((Get-ChildItem -Path Cert: -Recurse | ? {$_.Thumbprint -eq $binding.CertificateHash}).FriendlyName)
					CertThumb = $binding.CertificateHash
				}
				$obj = New-Object -TypeName PSObject -Property $hash
				$sitelist.Add($obj) | Out-Null
				Remove-variable -name hash,obj -Force -ErrorAction SilentlyContinue
			}
		}
	}
	return $sitelist
}
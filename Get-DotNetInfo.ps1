# A .NET version checker
# Ref https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed and https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-net-framework-updates-are-installed
Function Get-DotNetVersion {
	$release=(get-itemproperty -path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name Release).Release
	switch -regex ($release) {
		{$release -match "378389"} {
			return [string]".NET 4.5"
		}
		{$release -match "378675|378758"} {
			return ".NET 4.5.1"			
		}
		{$release -match "379893"} {
			return ".NET 4.5.2"
		}
		{$release -match "393295|393297"} {
			return ".NET 4.6"
		}
		{$release -match "394254|394271"} {
			return ".NET 4.6.1"
		}
		{$release -match "394802|394806"} {
			return ".NET 4.6.2"
		}
		{$release -match "460798|460805"} {
			return ".NET 4.7"
		}
		{$release -match "461308|461310"} {
			return ".NET 4.7.1"
		}
		{$release -match "461808|461814"} {
			return ".NET 4.7.2"
		}
		{$release -match "528040|528372|528049"} {
			return ".NET 4.8"
		}
	}
}

# Get updates
Function Get-DotNetUpdates {
	$Updatelist=New-Object -TypeName "System.Collections.ArrayList"
	$DotNetVersions = Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Microsoft\Updates | Where-Object {$_.name -like "*.NET Framework*"}
	ForEach($Version in $DotNetVersions){
		$Updates = Get-ChildItem $Version.PSPath
		ForEach ($Update in $Updates){
			if (!($Updatelist | ? {$_ -eq $Update.PSChildName})) {
				$Updatelist.Add([string]"$($Update.PSChildName)") | Out-Null
			}
		}
	}
	return $Updatelist
}

Write-Output "Checking for .NET 4.5 or later installations:"
Get-DotNetVersion

Write-Output "Checking for .NET updates:"
Get-DotNetUpdates
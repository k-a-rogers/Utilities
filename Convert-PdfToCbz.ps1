Function Convert-PdfToCbz {
<#
.Synopsis
A function for converting PDF files to CBZ files using GhostScript

.Description
This function takes an input specifying the location of a PDF file and invokes GhostScript to convert it to a CBZ file. This is done by printing each page as an image file, before combining them into a zip file and renaming the file extension to cbz.

.Inputs

System.String[infile] This is the full path to the PDF file to be converted.
System.String[mode] This selects the conversion mode. "BW" selects grayscale PNG output. "Col" selects 16M colour PNG output. "JPEG" selects jpeg output.
Int[res] This specifies the resolution of the output images. Default value is 150.
System.String[tool] This can be used to specify the location of the GhostScript executable on the local system. The default value is "C:\Program Files\gs\gs9.52\bin\gswin64c.exe".

.Outputs

System.String. Convert-PdfToCbz returns a string with the full path to the CBZ file.

.Example
PS> Convert-PdfToCbz -infile C:\Temp\File.Pdf
This will invoke GhostScript, generate a 150dpi colour PNG file with a 16m colour profile for each page, then combine them into a zip file. After the zip file is created it is renamed to File.cbz and the intermediate PNG files are deleted.

.Notes
AUTHOR:	Kyle Rogers

.Link
http://powershellshocked.wordpress.com
#>
    param(
        [string]$infile,
		[string]$mode,
		[int]$res,
        [string]$tool
    )
	# Verify presence of GhostScript executable
	if (!$tool) {
		# $tool = "C:\Program Files\gs\gs9.52\bin\gswin64c.exe"
		if (Test-Path "$PSScriptRoot\gswin64c.exe") {
			$tool=$PSScriptRoot+"\gswin64c.exe"
		} elseif ((Get-CimInstance -ClassName CIM_OperatingSystem).OSArchitecture -eq "64-bit") {
			$PF=gci ${env:ProgramFiles(x86)} -Recurse -Filter "*gswin32c.exe" -ErrorAction silentlyContinue
			if ($PF) {
				$tool=$PF.FullName
			}
		} else {
			$PF=gci $env:programfiles -Recurse -Filter "*gswin*c.exe" -ErrorAction silentlyContinue
			if ($PF) {
				$tool=$PF.Fullname
			}
		}
	}
	
	switch ($mode) {
		"BW" {
			$dev="pnggray";
			$ext="png"
			break
		}
		"Col" {
			$dev="png16m";
			$ext="png"
			break
		}
		"JPEG" {
			$dev="jpeg";
			$ext="jpg"
			break
		}
		default {
			$dev="png16m";
			$ext="png"
			break
		}
	}
	
	if (!$res) {
		[int]$res=150
	}
	
	If (Test-Path $tool) {
		# Define variables, convert each page to PNG
		$outfile="`""+($infile -replace "`.pdf","")+"_p%02d.$($ext)`""
		$outdir=(get-item $infile).Directory.FullName
		Push-Location
		Set-location $outdir
		$cmd="`"$($tool)`" -sDEVICE=$dev -dUseCropBox -o $outfile -r$($res) `"$infile`""
		cmd /c $cmd

		# Create archive file
		$outarch=$infile -replace "`.pdf","`.zip"
		Compress-Archive -Path "$outdir\*.$($ext)" -DestinationPath $outarch
		Rename-Item -Path $outarch -newname $($outarch -replace "`.zip","`.cbz")

		# Clean up intermediate files
		Remove-Item -Path "$outdir\*.$($ext)"
		Pop-Location
		return $($outarch -replace "`.zip","`.cbz")
	} else {
		Write-Error "GhostScript executable could not be found!"
	}
}
<# :
  @setlocal disabledelayedexpansion enableextensions
  @echo off
  powershell -nol -noni -nop -ex bypass -c "&{[ScriptBlock]::Create((cat '%~f0') -join [Char[]]10).Invoke(@(&{$args}%*))}"
  exit /b
#>

$script:validGames = @("cstrike","czero","dmc","dod","gearbox","ricochet","tfc","valve")

function Download-File($url, $outfile) {
	try {
		Write-Host "Downloading ${outfile} ..."
		$wc = New-Object System.Net.WebClient
		$wc.DownloadFile($url, $outfile)
	} catch {
		Write-Host "rehldsupdatetool: Download failed: $_"
		return $false
	}
	if (-not (Test-Path $outfile) -or (Get-Item $outfile).Length -eq 0) {
		Write-Host "rehldsupdatetool: Download failed"
		return $false
	}
	return $true
}

function Extract-Zip($zip, $dir) {
	try {
		Write-Host "Extracting $zip ..."
		Add-Type -AssemblyName System.IO.Compression.FileSystem
		$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
		foreach ($entry in $archive.Entries) {
			$targetPath = Join-Path $dir $entry.FullName
			$targetDir = Split-Path $targetPath
			if (-not (Test-Path $targetDir)) {
				New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
			}
			if ([string]::IsNullOrEmpty($entry.Name)) {
				continue
			}
			[System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $targetPath, $true)
		}
		$archive.Dispose()
	}
	catch {
		Write-Host "rehldsupdatetool: Extraction failed: $_"
		return $false
	}
	return $true
}

function main($game, $directory) {
	$ProgressPreference = 'SilentlyContinue'

	if ($script:validGames -notcontains $game) {
		Write-Host "rehldsupdatetool: Invalid game: ${game}"
		Write-Host "Valid games are: $($script:validGames -join ', ')"
		exit 1
	}

	$mod = $false
	if ($game -notin @("cstrike","valve")) {
		$mod = $true
	}

	$HLDS_DIR = [System.IO.Path]::GetFullPath($directory)
	if (-not $HLDS_DIR) {
		Write-Host "rehldsupdatetool: Invalid directory: ${directory}"
		exit 1
	}

	try {
		New-Item -ItemType Directory -Force -Path $HLDS_DIR | Out-Null
	} catch {
		Write-Host "rehldsupdatetool: Could not create directory: ${HLDS_DIR}"
		exit 1
	}

	Write-Host "Installing to: ${HLDS_DIR}"

	if (-not (Test-Path "hlds_windows_8684.zip")) {
		if (-not (Download-File "http://ftp.taco.cab/rehlds/hlds_windows_8684.zip" "hlds_windows_8684.zip")) { exit 1 }
	}
	if (-not (Download-File "http://ftp.taco.cab/rehlds/rehlds_windows.zip" "rehlds_windows.zip")) { exit 1 }
	if (-not (Download-File "http://ftp.taco.cab/rehlds/versioninfo.txt" "versioninfo.txt")) { exit 1 }
	if ($mod) {
		if (-not (Download-File "http://ftp.taco.cab/rehlds/mod_${game}.zip" "mod_${game}.zip")) { exit 1 }
	}

	if (-not (Extract-Zip "hlds_windows_8684.zip" $HLDS_DIR)) { exit 1 }
	if (-not (Extract-Zip "rehlds_windows.zip" $HLDS_DIR)) { exit 1 }
	if ($mod) {
		if (-not (Extract-Zip "mod_${game}.zip" $HLDS_DIR)) { exit 1 }
	}

	Write-Host "Done"
	Write-Host ""
	Write-Host "Version Info:"
	Write-Host ""
	Write-Host (Get-Content -Raw "versioninfo.txt")
	Write-Host "Installation complete. Run hlds-$game.bat to start the server."
}

Write-Host "rehldsupdatetool v0.0.2"

if ($args.count -gt 1) {
	main $args[0] $args[1]
	exit 0
} else {
	Write-Host "Usage: rehldsupdatetool.cmd <game> <directory>"
	Write-Host "Games: $($script:validGames -join ', ')"
	exit 1
}

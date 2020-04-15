<#	.Description
	Some code to help automate the updating of the ModuleManifest file (will create it if it does not yet exist, too)
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
	## Module Version to use
	[parameter(Mandatory=$true)][System.Version]$ModuleVersion,
	## Recreate the manifest (overwrite with full, fresh copy instead of update?)
	[Switch]$Recreate
)
begin {
	$strProductShortname = "Morpheus"
	$strModuleName = "${strProductShortname}.PShell"
	$strModuleFolderFilespec = "$PSScriptRoot\$strModuleName"
	$strFilespecForPsd1 = Join-Path $strModuleFolderFilespec "${strModuleName}.psd1"

	## parameters for use by both New-ModuleManifest and Update-ModuleManifest
	$hshManifestParams = @{
		# Confirm = $true
		Path = $strFilespecForPsd1
		ModuleVersion = $ModuleVersion
		Author = "Chris Bunge, Matt Boren"
		CompanyName = 'Morpheus Data'
		Copyright = "Apache 2.0 License"
		Description = "Module for API interaction with a Morpheus environment"
		# AliasesToExport = @()
		FileList = Write-Output "${strModuleName}.psd1" "en-US\about_${strModuleName}.help.txt" "${strModuleName}.format.ps1xml" "${strProductShortname}.Connect.psm1" "${strProductShortname}.Get.psm1" "${strProductShortname}.Remove.psm1" #"${strModuleName}_RegisterArgCompleter.ps1"
		FormatsToProcess = "${strModuleName}.format.ps1xml"
		FunctionsToExport = Write-Output Connect-Morpheus
		# IconUri = "http://someurl/pic.gif"
		LicenseUri = "https://uri.of.somwhere/apache-license-2.0.md"
		## scripts (.ps1) that are listed in the NestedModules key are run in the module's session state, not in the caller's session state. To run a script in the caller's session state, list the script file name in the value of the ScriptsToProcess key in the manifest
		NestedModules = Write-Output "${strProductShortname}.Connect.psm1" "${strProductShortname}.Get.psm1" "${strProductShortname}.Remove.psm1" # "${strModuleName}_SupportingFunctions.ps1" "${strModuleName}_RegisterArgCompleter.ps1"
		PowerShellVersion = [System.Version]"4.0"
		ProjectUri = "https://github.com/someUriHere"
		ReleaseNotes = "See ReadMe and other docs at ProjectUri"
		# RequiredModules = ""
		# RootModule = "${strModuleName}_ModRoot.psm1"
		# ScriptsToProcess = "${strModuleName}_init.ps1"
		Tags = Write-Output Morpheus MorpheusData
		VariablesToExport = Write-Output URL Header
		# Verbose = $true
	} ## end hashtable
} ## end begin

process {
	$bManifestFileAlreadyExists = Test-Path $strFilespecForPsd1
	## check that the FileList property holds the names of all of the files in the module directory, relative to the module directory
	## the relative names of the files in the module directory (just filename for those in module directory, "subdir\filename.txt" for a file in a subdir, etc.)
	$arrRelativeNameOfFilesInModuleDirectory = Get-ChildItem $strModuleFolderFilespec -Recurse | Where-Object {-not $_.PSIsContainer} | ForEach-Object {$_.FullName.Replace($strModuleFolderFilespec, "").TrimStart("\")}
	if ($arrDiffResults = (Compare-Object -ReferenceObject $hshManifestParams.FileList -DifferenceObject $arrRelativeNameOfFilesInModuleDirectory)) {Write-Error "Uh-oh -- FileList property value for making/updating module manifest and actual files present in module directory do not match. Better check that. The variance:`n$($arrDiffResults | Out-String)"} else {Write-Verbose -Verbose "Hurray, all of the files in the module directory are named in the FileList property to use for the module manifest"}
	$strMsgForShouldProcess = "{0} module manifest" -f $(if ((-not $bManifestFileAlreadyExists) -or $Recreate) {"Create"} else {"Update"})
	if ($PsCmdlet.ShouldProcess($strFilespecForPsd1, $strMsgForShouldProcess)) {
		## do the actual module manifest creation/update
		if ((-not $bManifestFileAlreadyExists) -or $Recreate) {Microsoft.PowerShell.Core\New-ModuleManifest @hshManifestParams}
		else {PowerShellGet\Update-ModuleManifest @hshManifestParams}
		## replace the comment in the resulting module manifest that includes "PSGet_" prefixed to the actual module name with a line without "PSGet_" in it
		(Get-Content -Path $strFilespecForPsd1 -Raw).Replace("# Module manifest for module 'PSGet_$strModuleName'", "# Module manifest for module '$strModuleName'") | Set-Content -Path $strFilespecForPsd1
	} ## end if
} ## end process

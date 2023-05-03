Get-ChildItem -Path $PSScriptRoot -Include *.ps1 -Recurse | ForEach-Object {. $_.FullName}
$ExportedFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\" | ForEach-Object {$_.Name -replace ".ps1"}
Export-ModuleMember -Function $ExportedFunctions
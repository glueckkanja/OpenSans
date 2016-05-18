$package = 'OpenSans'

$scriptRoot = (Split-Path -parent $MyInvocation.MyCommand.Definition)
$fontHelpersPath = (Join-Path $scriptRoot 'FontHelpers.ps1')
. $fontHelpersPath

$shell = New-Object -ComObject Shell.Application
$fontsFolder = $shell.Namespace(0x14)

$fontFiles = Get-ChildItem (Join-Path $scriptRoot '..\fonts') -Recurse -Filter *.ttf

# unfortunately the font install process totally ignores shell flags :(
# http://social.technet.microsoft.com/Forums/en-IE/winserverpowershell/thread/fcc98ba5-6ce4-466b-a927-bb2cc3851b59
# so resort to a nasty hack of compiling some C#, and running as admin instead of just using CopyHere(file, options)
$commands = $fontFiles |
% { Join-Path $fontsFolder.Self.Path $_.Name } |
? { Test-Path $_ } |
% { "Remove-SingleFont '$_' -Force;" }

# http://blogs.technet.com/b/deploymentguys/archive/2010/12/04/adding-and-removing-fonts-with-windows-powershell.aspx
$fontFiles |
% { $commands += "Add-SingleFont '$($_.FullName)';" }

$toExecute = ". $fontHelpersPath;" + ($commands -join ';')
Start-ChocolateyProcessAsAdmin $toExecute

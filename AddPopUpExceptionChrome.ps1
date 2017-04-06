##################################################
#
#Created by: salvador madrid
#Last update: 06/04/2017
#
#Description: Add website to allow exception popup
#             on Chrome
#	
##################################################


[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

$web = [Microsoft.VisualBasic.Interaction]::InputBox("Enter website name", "Add website to allow exception popup", "")
#$web = 'https://www.google.es'


$find = '"popups":{'
$replace = '"popups":{"'+$web+',*":{"setting":1},'
$path = 'Google\Chrome\User Data\Default\Preferences'

(Get-Content $env:LOCALAPPDATA'\'$path).Replace($find,$replace) | Set-Content $env:LOCALAPPDATA'\'$path


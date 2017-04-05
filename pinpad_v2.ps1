﻿##################################################
#
#Created by: salvador madrid
#Last update: 05/04/2017
#
#Description: Change COM port automatically.
#	Just put the name of the device and his port
#	in $DeviceName and $ComPort variables
#	
##################################################

$DeviceName = "Sagem Telium Comm Port"
$ComPort = "COM5"


function Switcher {

	Param ($Name,$NewPort)

	#Queries WMI for Device
	$WMIQuery = 'Select * from Win32_PnPEntity where Description = "' + $Name + '"'
	$Device = Get-WmiObject -Query $WMIQuery

	#Execute only if device is present
	if ($Device) {
		
		#Get current device info
		$DeviceKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\" + $Device.DeviceID
		$PortKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\" + $Device.DeviceID + "\Device Parameters"
		$Port = get-itemproperty -path $PortKey -Name PortName
		$OldPort = [convert]::ToInt32(($Port.PortName).Replace("COM",""))
		
		#Set new port and update Friendly Name
		$FriendlyName = $Name + " (" + $NewPort + ")"
		New-ItemProperty -Path $PortKey -Name "PortName" -PropertyType String -Value $NewPort -Force
		New-ItemProperty -Path $DeviceKey -Name "FriendlyName" -PropertyType String -Value $FriendlyName -Force

		#Release Previous Com Port from ComDB
		$Byte = ($OldPort - ($OldPort % 8))/8
		$Bit = 8 - ($OldPort % 8)
		if ($Bit -eq 8) { 
			$Bit = 0 
			$Byte = $Byte - 1
		}
		$ComDB = get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB
		$ComBinaryArray = ([convert]::ToString($ComDB.ComDB[$Byte],2)).ToCharArray()
		while ($ComBinaryArray.Length -ne 8) {
			$ComBinaryArray = ,"0" + $ComBinaryArray
		}
		$ComBinaryArray[$Bit] = "0"
		$ComBinary = [string]::Join("",$ComBinaryArray)
		$ComDB.ComDB[$Byte] = [convert]::ToInt32($ComBinary,2)
		Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB -Value ([byte[]]$ComDB.ComDB)
		
	}
}

Switcher $DeviceName $ComPort
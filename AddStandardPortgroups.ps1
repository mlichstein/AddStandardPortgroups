# Add the VI-Snapin if it isn't loaded already
if ( (Get-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue) -eq $null ) {
	Add-PSSnapin -Name "VMware.VimAutomation.Core"
	Add-PSSnapin -Name "VMware.VimAutomation.Vds"
}

$Vcenter = Read-Host "Enter the vCenter name: "
$Cluster = Read-Host "Enter the cluster name: "

#Grab CSV
$InputFile = "C:\Users\mlichstein\Desktop\scripts\vlans.csv"
$VLANFile = Import-Csv $InputFile

Connect-VIServer -Server $Vcenter

#Create new standard switch on all hypervisors
ForEach ($VMHost in $VMHosts) {
	New-VirtualSwitch -VMHost $VMHost -Name vSwitch1
}

#Parse input, create portgroups
ForEach ($VLAN in $VLANFile) {
	$VLAN_name = $VLAN.VLANname
	$VLAN_number = $VLAN.VLANid
	
	$VMHosts = Get-Cluster $Cluster | Get-VMHost | sort Name | % {$_.Name}

	ForEach ($VMHost in $VMHosts) {
		Get-VirtualSwitch -VMHost $VMHost -Name "vSwitch1" | New-VirtualPortGroup -Name $VLAN_name -VLANid $VLAN_number
	}
}

Disconnect-VIServer -server $Vcenter -Confirm:$false

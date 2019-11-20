
New-LabDefinition -Name SqlCLient -DefaultVirtualizationEngine HyperV

Add-LabVirtualNetworkDefinition -Name Lab0
Add-LabVirtualNetworkDefinition -Name 'Default Switch' -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'WiFi' }

Add-LabIsoImageDefinition -Name SQLServer2017 -Path $labSources\ISOs\SW_DVD9_NTRL_SQL_Svr_Standard_Edtn_2017_64Bit_English_OEM_VL_X21-56945.iso

$labDomainName = "example.local"

$netAdapter = @()

$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch Lab0

$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp



$PSDefaultParameterValues = @{

#    'Add-LabMachineDefinition:DomainName' = $labDomainName

    'Add-LabMachineDefinition:Memory' = 1GB

    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Standard Evaluation (Desktop Experience)'

}



Add-LabMachineDefinition -Name dc1 -Network Lab0 -DomainName $labDomainName -Roles RootDC

#Add-LabMachineDefinition -Name rt1 -Roles Routing -NetworkAdapter $netAdapter -DomainName $labDomainName

Add-LabMachineDefinition -Name ca1 -Network Lab0 #-Roles CaRoot

Add-LabMachineDefinition -Name sca1 -Network Lab0 -DomainName $labDomainName  #-Roles CaSubordinate

$sqlRole = Get-LabMachineRoleDefinition -Role SQLServer2017 -Properties @{
    Features = 'SQL,Tools'
    SQLSvcAccount = 'example\svc-sql'
    SQLSvcPassword = 'Somepass1'
    AgtSvcStartupType = 'Automatic'
}

Add-LabMachineDefinition -Name sql1 -Memory 2GB -Network Lab0 -DomainName $labDomainName -Roles $sqlRole

Install-Lab

#Enable-LabCertificateAutoenrollment -Computer -User -CodeSigning

Show-LabDeploymentSummary -Detailed
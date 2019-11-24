####################################
####### Creating the forest and installing utils on DC1
#### Based on https://github.com/ghostinthewires/Terraform-Templates/blob/master/Azure/2-tier-iis-sql-vm/modules/active-directory/3-provision-domain.tf
####################################
locals {
  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${var.password} -AsPlainText -Force"
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  install_dns_command  = "Install-WindowsFeature DNS -IncludeManagementTools"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.domain_name} -DomainNetbiosName ${var.netbios_domain_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command     = "shutdown -r -t 10"
# Exit code hack is needed to prevent the terraform deployer from thinking the command failed
  exit_code_hack       = "exit 0"
  win7_set_dns         = "netsh interface ip set dns 'Local Area Connection' static 192.167.1.10"
  powershell_command   = "${local.ps_exec_policy}; ${local.choco_install}; ${local.choco_pks}; ${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.install_dns_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
  fileserver_install   = "Install-WindowsFeature -Name FS-FileServer -IncludeAllSubFeature -IncludeManagementTools"
  webserver_install    = "Install-WindowsFeature -name Web-Server -IncludeManagementTools"
  mkdir_temp           = "mkdir C:/Temp" 
  fileserver_share     = "New-SmbShare -Name fileshare -Path C:/Temp -FullAccess Everyone"
}

resource "azurerm_virtual_machine_extension" "dc1primary_commands" {
  name                 = "dc1primary_commands"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.dc1primary.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\" "
    }
SETTINGS
  depends_on = ["azurerm_virtual_machine.dc1primary"]
}

####################################
####### Joining DC2 to the domain & promoting it to DC and installing utils
#### Based on https://github.com/ghostinthewires/Terraform-Templates/blob/master/Azure/2-tier-iis-sql-vm/modules/dc2-vm/3-join-domain.tf
####################################
resource "azurerm_virtual_machine_extension" "join-domain_dc2" {
  name                 = "join-domain_dc2"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.dc2sub.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  
  # NOTE: the `OUPath` field is intentionally blank, to put it in the Computers OU
  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "",
        "User": "${var.domain_name}\\${var.username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.password}"
    }
SETTINGS
  depends_on = ["azurerm_virtual_machine_extension.dc1primary_commands"]
}

locals {
  dc2import_command       = "Import-Module ADDSDeployment"
  dc2user_command         = "$dc2user = ${var.username}" 
  dc2password_command     = "$password = ConvertTo-SecureString ${var.password} -AsPlainText -Force"
  dc2creds_command        = "$mycreds = New-Object System.Management.Automation.PSCredential -ArgumentList $dc2user, $password"
  dc2join_domain          = "Add-Computer –DomainName ${var.domain_name} -Credential $mycreds"
  dc2install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  dc2configure_ad_command = "Install-ADDSDomainController -Credential $mycreds -CreateDnsDelegation:$false -DomainName ${var.domain_name} -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  dc2shutdown_command     = "shutdown -r -t 10"
  dc2exit_code_hack       = "exit 0"
  ps_exec_policy          = "Set-ExecutionPolicy Bypass -Force"
  choco_install           = "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"
  choco_pks               = "powershell.exe -Command choco install ${var.chrome} ${var.notepad} ${var.s7z} ${var.git} ${var.sysint} ${var.py3} ${var.py2} -y"
  # Clients sometimes needs to refresh the DNS server address or they won't be able to find the DC ¯\_(ツ)_/¯
  set_dns                 = "Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('192.167.1.10', '1.1.1.1')"
  dc2powershell_command   = "${local.ps_exec_policy}; ${local.set_dns}; ${local.choco_install}; ${local.choco_pks}; ${local.dc2import_command}; ${local.dc2user_command}; ${local.dc2password_command}; ${local.dc2creds_command}; ${local.dc2install_ad_command}; ${local.dc2configure_ad_command}; ${local.dc2shutdown_command}; ${local.dc2exit_code_hack}"
}

###################################
###### Joining fileserver to the domain and installing utils
### Based on https://github.com/ghostinthewires/Terraform-Templates/blob/master/Azure/2-tier-iis-sql-vm/modules/dc2-vm/3-join-domain.tf
###################################
resource "azurerm_virtual_machine_extension" "join-domain_fileserver" {
  name                 = "join-domain_domain_fileserver"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.fileserver.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # NOTE: the `OUPath` field is intentionally blank, to put it in the Computers OU
  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "",
        "User": "${var.domain_name}\\${var.username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.password}"
    }
SETTINGS
  depends_on = ["azurerm_virtual_machine_extension.dc1primary_commands"]
}

resource "azurerm_virtual_machine_extension" "fileserver_commands" {
  name                 = "fileserver_commands"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.fileserver.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.ps_exec_policy}; ${local.set_dns}; ${local.choco_install}; ${local.choco_pks}; ${local.mkdir_temp}; ${local.fileserver_install}; ${local.fileserver_share}; ${local.webserver_install}; ${local.shutdown_command}; ${local.exit_code_hack}\" "
    }
SETTINGS

  depends_on = ["azurerm_virtual_machine.fileserver"]
}

####################################
####### Joining client10 to the domain and installing utils
#### Based on https://github.com/ghostinthewires/Terraform-Templates/blob/master/Azure/2-tier-iis-sql-vm/modules/dc2-vm/3-join-domain.tf
####################################
resource "azurerm_virtual_machine_extension" "join-domain_client10" {
  name                 = "join-domain_client10"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.client10.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # NOTE: the `OUPath` field is intentionally blank, to put it in the Computers OU
  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "",
        "User": "${var.domain_name}\\${var.username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.password}"
    }
SETTINGS
  depends_on = ["azurerm_virtual_machine_extension.dc1primary_commands"]
}

resource "azurerm_virtual_machine_extension" "client10_commands" {
  name                 = "client10_commands"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.client10.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.ps_exec_policy}; ${local.set_dns}; ${local.choco_install}; ${local.choco_pks}; ${local.shutdown_command}; ${local.exit_code_hack}\" "
    }
SETTINGS

  depends_on = ["azurerm_virtual_machine.client10"]
}

####################################
####### Joining client7 to the domain and installing utils
#### Based on https://github.com/ghostinthewires/Terraform-Templates/blob/master/Azure/2-tier-iis-sql-vm/modules/dc2-vm/3-join-domain.tf
####################################
resource "azurerm_virtual_machine_extension" "join-domain_client7" {
  name                 = "join-domain_client7"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.client7.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # NOTE: the `OUPath` field is intentionally blank, to put it in the Computers OU
  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "",
        "User": "${var.domain_name}\\${var.username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.password}"
    }
SETTINGS
  depends_on = ["azurerm_virtual_machine_extension.dc1primary_commands"]
}

resource "azurerm_virtual_machine_extension" "client7_commands" {
  name                 = "client7_commands"
  location             = "${var.location}"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.client7.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.ps_exec_policy}; ${local.win7_set_dns}; ${local.choco_install}; ${local.choco_pks}; ${local.shutdown_command}; ${local.exit_code_hack}\" "
    }
SETTINGS
  depends_on = ["azurerm_virtual_machine.client7"]
}
#
#This is the function toolbox =)
#
#--------------------------------------------------------------------------------
#Global variable
$global:parameters = Get-Content -Raw -Path "cloner.json" | ConvertFrom-Json
#--------------------------------------------------------------------------------
# This function checks for connection to server, and creates one if needed
function con {
    $con = Get-VMHost
    cls
    if ($con) {
        Write-Host "You're already connected to the server" -ForegroundColor Green
    } else {
        Write-Host "Connect to the server first" -ForegroundColor Yellow
        Connect-VIServer -Server $global:parameters.vcenter_server
    }
}
#--------------------------------------------------------------------------------
# This function allows for the easy creation a new virtual switch
# syntax: createSwitch -switchName "String" -esxiHostname "super4.cyber.local"
function createSwitch {
    param(
        $switchName,
        $esxiHostname
    )
    $esxi_host = Get-VMHost -Name $esxiHostname
    $vswitch = New-VirtualSwitch -VMHost $esxi_host -Name $switchName -ErrorAction Ignore
    New-VirtualPortGroup -VirtualSwitch $vswitch -Name $switchName
}
#--------------------------------------------------------------------------------
# This function creates parameters to fill which allow for speedy network adapter changes
# syntax: setNetwork -vmName "fw-blue4" -numInterface 1 -preferredNetwork "Blue4-LAN"
function setNetwork {
    param(
        $vmName,
        $numInterface,
        $preferredNetwork
    )
    $vm = Get-VM -Name $vmName
    $interfaces = $vm | Get-NetworkAdapter
    $interfaces[$numInterface-1] | Set-NetworkAdapter -NetworkName $preferredNetwork -Confirm:$false
}   

#--------------------------------------------------------------------------------
# This function will print the IP of the VM being run against
function getIp {
    param(
        $vmName
    )
    $vm = Get-VM -Name $vmName
    $ip = $vm.Guest.IPAddress[0]
    Write-Host $ip hostname=$vm   
}

#--------------------------------------------------------------------------------
#This function will dynamically print the IP of powered on VM's if there are multiple being queried against
# eg. dynamicIp -vmName *
function dynamicIp {
    param(
        $vmName
    )
    $vmArray = Get-VM -Name $vmName
    foreach ($vm in $vmArray) {
        if ($vm.PowerState -eq "PoweredOn") {
            getIp($vm)
        }
    }
}   

#--------------------------------------------------------------------------------
function deployVM {
    param(
        $cloneType,
        $sourceVM,
        $VMname
    )
    $baseVM = Get-VM -name $sourceVM
    $snapshot = $global:parameters.base_snapshot
    $dstore = $global:parameters.preferred_datastore
    $vmhost = $global:parameters.esxi_server
    $folder = $global:parameters.target_folder
    $vnet = $global:parameters.preferred_network
    
    if ($cloneType -eq "L") {
        
        $newvm = New-VM -Name $VMname -VM $basevm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore -DiskStorageFormat Thin -Location $folder
    
    } elseif ($cloneType -eq "F") {

        $newvm = New-VM -Name $VMname -VM $basevm -VMHost $vmhost -Datastore $dstore -DiskStorageFormat Thin -Location $folder

    } else {

        Write-Host "Chose either a [L]inked or [F]ull clone"
    }
    setNetwork -vmName $VMName -preferredNetwork $vnet 
    Write-host "Network Set"
    $go = Start-VM -vm $VMname
    
    Write-Host "Powering on VM" -ForegroundColor Green

}

#--------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
#function getIps {
#    foreach ($vm in Get-VM) {
#        if ($vm.PowerState -eq "PoweredOn"){
#            getIp($vm.name)
#        }
#    }
#}









#-----------------------------------------------------------------------------
# hit enter function
#function hit_enter {
#    Write-Host "Hit [Enter] to continue" -ForegroundColor Yellow
#    $enter = Read-Host
#    #Read-Host -prompt "Press [Enter] to continue"
#} # close hit enter function
#
#-----------------------------------------------------------------------------
#check connection function
#function check_con {
#    
#    $con = $null
#    #Check if user is connected to a server
#    $con = Get-VMHost | Select Name, ConnectionState
#    #Decide if connected or not
#    if ($con -eq $null) {
#        #No connection - connect to one
#        cls
#        Write-Host -BackgroundColor Black -ForegroundColor Red "No connection to VIServer - To connect do the following" 
#        hit_enter
#        if ($global:parameters.vcenter_server) {
#            Connect-VIServer -Server $global:parameters.vcenter_server
#            util_mode 
#        } else {
#        $global:viserver = Read-Host -prompt "Type in the name or address of the VI server you wish to connect to (eg. vcenter.domain.local)"
#        sleep 1
#        Connect-VIServer -Server $global:viserver
#        hit_enter
#        util_mode
#        }
#    } else {
#        if ($global:parameters.vcenter_server) {
#            Write-Host "You're already connected to the VI server" $global:parameters.vcenter_server -ForegroundColor Green
#            hit_enter
#            util_mode
#        } else {
#            #Display the connection and launch main menu
#            Write-Host "You're already connected to a VI server" -ForegroundColor Green
#            hit_enter
#            util_mode
#        }        
#    }
#}
#-----------------------------------------------------------------------------
# Function which checks if the configuration file exits / if it is a .json  in correct format.
#function config_file {
#   Write-Host "To use this utility script, a configuration file must be specified?. Contine with y/n" -ForegroundColor Green
#    $decision = Read-Host   
#    #yes or no
#    if ($decision -eq "y") {
#        cls
#        Write-Host "Ok. If the file stored in the same directory as this script, type its name. (eg. config.json)" -ForegroundColor Green 
#        Write-Host "Otherwise, type the full file path. (eg. /path/to/file/config.json)" -ForegroundColor Green 
#        #gather config file name
#        $global:config_file_or_path = Read-Host -Prompt "What'll it be?"
#        #does this file exist?
#        if (Test-Path $global:config_file_or_path) {
#            cls
#            Write-Host "This file exists" -ForegroundColor Green
#            Write-Host "Ensuring .json filetype" -ForegroundColor Cyan
#            #test if it is a json
#            if(Get-Content -Raw -Path $global:config_file_or_path | Test-Json) {
#                Write-Host "File checks out - loading parameters" -ForegroundColor Green
#                $global:parameters = Get-Content -Raw -Path $global:config_file_or_path | ConvertFrom-Json
#                check_con #launch function using saved parameters
#            } else { #if file exists but is not json
#                cls
#                Write-Host "File is not a .json or has incorrect JSON format - Restarting function" -ForegroundColor Red
#                sleep 1
#                config_file
#            } #end of testing whether it is json
#        } else { 
#            cls
#            Write-Host "The file you entered cannot be found. You've either spelled incorrectly, didn't specify the location if needed, or it does not exist." -ForegroundColor Red
#            Write-Host "Figure it out - Restarting function" -ForegroundColor Red
#            sleep 1
#            config_file
#        } #end of testing file exists
#    } elseif ($decision -eq "n") {
#        Write-Host "Exiting utility script" -ForegroundColor Red
#        sleep 1 #let them read it
#        exit
#    } else {
#        Write-Host "Use y/n" -ForegroundColor Red
#        config_file
#    }       
#}
#
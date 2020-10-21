#-----------------------------------------------------------------------------
#This will be an automation script for deploying images of boxes on vSphere.
#-----------------------------------------------------------------------------
. .\utility.ps1
#Create global variables
$global:parameters = $null
$global:config_file_or_path = $null
$global:basevm = $null
$global:snapshot = $null
$global:vmhost = $null
$global:dstore = $null
$global:folder = $null
$global:viserver = $null
$global:newvm = $null
$global:temp = $null
$global:selection = $null
$global:gather = $null
$global:utility = $null
$global:vnet = $null
#-----------------------------------------------------------------------------
#Clear screen function
function cls_sleep {

    #Clear screen
    cls
    #Wait 1 second
    sleep 1

    } #Close function

#-----------------------------------------------------------------------------
# This function is used when a user entry is being interpreted to ensure it is a number.
function num_check($stats) {
    $math = [int][char]$stats
    if(48 -lt $math -and $math -lt 58) {
        return $false
    } else {
        return $true
    }
} #close num_check

#-----------------------------------------------------------------------------
# This function is used to print all items in an array.
function list_array($array){
    for($i=0; $i -lt $array.length; $i++){
        write-host ($i+1)": "$array[$i]
    }
} #close list_array function

#-----------------------------------------------------------------------------
# hit enter function
function hit_enter {
    Write-Host "Hit [Enter] to continue" -ForegroundColor Yellow
    $enter = Read-Host
    #Read-Host -prompt "Press [Enter] to continue"
} # close hit enter function

#-----------------------------------------------------------------------------
#dynamic Error handling
function user_error {

    #checking that number is not 0
    if (num_check($global:selection[0])) {
        write-host "Invalid input" -ForegroundColor Red
        $global:selection = $null
        server_details #restarting function
    } elseif ([int]$global:selection -gt [int]$global:gather.length) {
        write-host "Invalid input" -ForegroundColor Red
        $global:selection = $null
        server_details #restarting function
    } else {
        $global:temp = $global:gather[$global:selection-1]
    }
}

#-----------------------------------------------------------------------------
# Function which checks if the configuration file exits / if it is a .json  in correct format.
function config_file {

    $decision = Read-Host -Prompt "Do you have a configuration file you would like to load? (y/n)"
        
    #yes or no
    if ($decision -eq "y") {
        Write-Host "Ok. If the file stored in the same directory as this script, type its name. (eg. config.json)" -ForegroundColor Green 
        Write-Host "Otherwise, type the full file path. (eg. /path/to/file/config.json)" -ForegroundColor Green
            
        #gather config file name
        $global:config_file_or_path = Read-Host -Prompt "What'll it be?"

        #does this file exist?
        if (Test-Path $global:config_file_or_path) {

            Write-Host "This file exists" -ForegroundColor Green
            Write-Host "Ensuring .json filetype" -ForegroundColor Cyan

            #test if it is a json
            if(Get-Content -Raw -Path $global:config_file_or_path | Test-Json) {

                Write-Host "File checks out - loading parameters" -ForegroundColor Green
                $global:parameters = Get-Content -Raw -Path $global:config_file_or_path | ConvertFrom-Json
                check_con #launch function using saved parameters

            } else { #if file exists but is not json
                cls
                Write-Host "File is not a .json or has incorrect JSON format - Restarting function" -ForegroundColor Red
                sleep 1
                config_file

            } #end of testing whether it is json

        } else { 
            cls
            Write-Host "The file you entered cannot be found. You've either spelled incorrectly, didn't specify the location if needed, or it does not exist." -ForegroundColor Red
            Write-Host "Figure it out - Restarting function" -ForegroundColor Red
            sleep 1
            config_file

        } #end of testing file exists

    } elseif ($decision -eq "n") {
        Write-Host "Running script in interactive mode" -ForegroundColor Cyan
        sleep 1 #let them read it
        check_con #run check_con

    } else {
        Write-Host "Use y/n" -ForegroundColor Red
        config_file
    }
        
}

#---------------------------------------------------
#Check connection with the VI server
function check_con {
    
    $con = $null
    #Check if user is connected to a server
    $con = Get-VMHost | Select Name, ConnectionState

    #Decide if connected or not
    if ($con -eq $null) {

        #No connection - connect to one
        cls
        Write-Host -BackgroundColor Black -ForegroundColor Red "No connection to VIServer - To connect do the following" 
        hit_enter

        if ($global:parameters.vcenter_server) {
            Connect-VIServer -Server $global:parameters.vcenter_server
            saved_mode   

        } else {
        $global:viserver = Read-Host -prompt "Type in the name or address of the VI server you wish to connect to (eg. vcenter.domain.local)"
        sleep 1
        Connect-VIServer -Server $global:viserver
        hit_enter
        main_menu
        }

    } else {

        if ($global:parameters.vcenter_server) {
            Write-Host "You're already connected to the VI server" $global:parameters.vcenter_server -ForegroundColor Green
            hit_enter
            saved_mode
        } else {
            #Display the connection and launch main menu
            Write-Host "You're already connected to a VI server" -ForegroundColor Green
            hit_enter
            main_menu
        }        
    }
}

#-----------------------------------------------------------------------------
#Define the main menu function
function main_menu {

    #populate global gather variable with the first bit of information then run the clear screen function
    $global:gather = Get-VMHost
    cls_sleep

    #Create Menu
    Write-Host -ForegroundColor Cyan "---------------------------------------"
    Write-Host -BackgroundColor Black -ForegroundColor White "Choose an option"
    Write-Host -ForegroundColor Cyan "---------------------------------------"
    Write-Host "[1] Define Variables"
    Write-Host "[2] Deploy Clone"
    Write-Host "[E] Exit"
    
    # Prompt the user
    Write-Host "---------------------------------------" -ForegroundColor Cyan 
    $user_option = Read-Host -Prompt "Please select one of the above options"

    # Process the selection
    if ($user_option -eq 1) {

        # Call define_variables function
        define_variables

    } elseif ($user_option -eq 2) {

        # Call clone or not
        clone_or_not

    } elseif ($user_option -eq "E") {
    
        # Exit the program
        Write-Host ""
        Write-Host "If you're not first, you're last" -BackgroundColor Black -ForegroundColor Cyan
        exit
        
    } else {
    
        Write-Host -BackgroundColor Black -ForegroundColor Red "Invalid menu option."
        # Wait a second
        sleep 1
        #Rerun the function
        main_menu
        
    } #Close processing of user selection           
} #Close main_menu function

#-----------------------------------------------------------------------------
#Define Variables
function define_variables {
    
    #Clear screen
    cls_sleep

    #Print menu
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Which variable(s) would you like to define?" -BackgroundColor Black -ForegroundColor Yellow
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "[1] The Parent Virtual Machine details (Base-VM and Snapshot)"
    Write-Host "[2] vSphere Server and clone-to location details(Host, Datastore, and Folder)" 
    Write-Host "[R] Return to the main menu"
    Write-Host "[E] Exit"

     # Prompt the user
    Write-Host "---------------------------------------" -ForegroundColor Cyan 
    $user_option = Read-Host -Prompt "Please select one of the above options"

    # Process the selection
    if ($user_option -eq 1) {
        #Call deploy_box function
        vm_parent
    } elseif ($user_option -eq 2) {
        #Call vm_snap
        server_details
    } elseif ($user_option -eq "R") {
        #Return to the main menu
        main_menu
    } elseif ($user_option -eq "E") {
        # Exit the program
        Write-Host ""
        Write-Host "If you're not first, you're last" -BackgroundColor Black -ForegroundColor Cyan
        exit
    } else {
        Write-Host -BackgroundColor Black -ForegroundColor Red "Invalid menu option."
        # Wait a second
        sleep 1
        #Rerun the function
        define_variables
    }  
} #close define_variables function

#-----------------------------------------------------------------------------
#Deploy box
function deploy_box {
    
    if ($global:parameters.domain) {

        #global:basevm.name # this is set interactively based off the type of VM the user wants to deploy
        $global:snapshot = $global:parameters.base_snapshot
        $global:dstore = $global:parameters.preferred_datastore
        $global:vmhost = $global:parameters.esxi_server
        $global:folder = $global:parameters.target_folder
        $global:vnet = $global:parameters.preferred_network
        Write-Host " "
        Write-Host "Settings From .JSON Successfully Imported" -ForegroundColor Green
        Write-Host "Parent VM: $global:basevm"
        Write-Host "Snapshot: $global:snapshot"
        Write-Host "VMware ESXi Host Server: $global:vmhost"
        Write-Host "Target Datastore: $global:dstore"
        Write-Host "Target Folder: $global:folder"
        Write-Host "Preferred Network: $global:vnet"
        hit_enter
        
    } else {

        #Clear screen
        cls_sleep

        #Print all variables
        Write-Host "Parent VM: $global:basevm"
        Write-Host "Snapshot: $global:snapshot"
        Write-Host "VMware ESXi Host Server: $global:vmhost"
        Write-Host "Target Datastore: $global:dstore"
        Write-Host "Target Folder: $global:folder"
        
        #yes or no
        $decision = Read-Host -Prompt "Do you want to proceed using these selections"
        if ($decision -eq "y") {
            Write-Host "Ok" -ForegroundColor Green #continue
        } elseif ($decision -eq "n") {
            Write-Host "Returning to main menu" -ForegroundColor Cyan
            sleep 1 #let them read it
            main_menu #run main menu function
        } else {
            Write-Host "Error: answer with (Y/y) or (N/n)" -ForegroundColor Red
            sleep 2 #let them read it
            deploy_box #rerun function
        }
    }
    # Prompt the user
    $nameit = Read-Host -Prompt "Name the clone and deployment will begin"
    #Deploy the clone
    $global:newvm = New-VM -Name $nameit -VM $global:basevm -LinkedClone -ReferenceSnapshot $global:snapshot -VMHost $global:vmhost -Datastore $global:dstore -DiskStorageFormat Thin -Location $global:folder
    
    $counter = 0
    $vm = Get-VM -Name $nameit
    $int = $vm | Get-NetworkAdapter
    while($int.count -gt $counter) {
        setNetwork -vmName $nameit -numInterface $counter -preferredNetwork $global:parameters.preferred_network
        $counter+=1
    }  

    Write-Host "Clone deployed" -ForegroundColor Green
    exit
    
}

#------------------------------------------------------------------------------
#vm_parent function
function vm_parent {

    #Defining $basevm variable
    $global:gather = Get-VM -Name "*.base.f20"
    cls_sleep #clean sleep function

    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "BASE-VM" -ForegroundColor Yellow
    list_array($global:gather)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:selection = Read-Host -Prompt "Which BASE-VM would you like to clone from?"
    user_error # this runs the error handleing and variable holding function
    $global:basevm = $global:temp #assign the verified user option to global variable
    # Define $snapshot variable
    $global:gather = Get-VM -Name "$global:basevm" | Get-Snapshot
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Snapshot" -ForegroundColor Yellow
    list_array($global:gather)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:selection = Read-Host -Prompt "Which snapshot do you want to use?"
    user_error
    $global:snapshot = $global:temp
    # Return to define_variables
    define_variables
}

#------------------------------------------------------------------------------
#vSphere server details function
function server_details {

    #clear screen
    cls_sleep

    #Define the $vmhost
    $global:gather = Get-VMHost
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Server Name" -ForegroundColor Yellow
    list_array($global:gather)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:selection = Read-Host -Prompt "Select the number for the VMware server"
    user_error #call the error handling function
    $global:vmhost = $global:temp

    #Define the $dstore
    $global:gather = Get-Datastore #| Select Name
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Datastore Name" -ForegroundColor Yellow
    list_array($global:gather)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:selection = Read-Host -Prompt "Select the number for the corresponding datastore"
    user_error #call the error handling function
    $global:dstore = $global:temp

    # Define the $folder
    $global:gather = Get-Folder -type VM
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Folder Name" -ForegroundColor Yellow
    list_array($global:gather)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:selection = Read-Host -Prompt "Select the number for the corresponding folder"
    user_error #call the error handling function
    $global:folder = $global:temp

    #Confirmation
    Write-Host "Variables set!" -ForegroundColor Green
    hit_enter

    # Return to define_variables
    main_menu
}

#-----------------------------------------------------------------------------
# This will deploy regular clone
function deploy_reg {
    
    if ($global:parameters.domain) {

        #global:basevm.name # this is set interactively based off the type of VM the user wants to deploy
        $global:dstore = $global:parameters.preferred_datastore
        $global:vmhost = $global:parameters.esxi_server
        $global:folder = $global:parameters.target_folder
        $global:vnet = $global:parameters.preferred_network
        Write-Host " "
        Write-Host "Settings From .JSON Successfully Imported" -ForegroundColor Green
        Write-Host "Parent VM: $global:basevm"
        Write-Host "VMware ESXi Host Server: $global:vmhost"
        Write-Host "Target Datastore: $global:dstore"
        Write-Host "Target Folder: $global:folder"
        Write-Host "Preferred Network $global:vnet"
        hit_enter

    } else {
        #Clear screen
        cls_sleep

        #Print all variables
        Write-Host "Parent VM: $global:basevm"
        Write-Host "VMware ESXi Host Server: $global:vmhost"
        Write-Host "Target Datastore: $global:dstore"
        Write-Host "Target Folder: $global:folder"
        
        #yes or no
        $decision = Read-Host -Prompt "Do you want to proceed using these selections"
        if ($decision -eq "y") {
            Write-Host "Ok" -ForegroundColor Green #continue

        } elseif ($decision -eq "n") {
            Write-Host "Returning to main menu" -ForegroundColor Cyan
            sleep 1 #let them read it
            main_menu #run main menu function
        } else {
            Write-Host "Error: answer with (Y/y) or (N/n)" -ForegroundColor Red
            sleep 2 #let them read it
            deploy_reg #rerun function
        }

    }
    # Prompt the user
    $nameit = Read-Host -Prompt "Name the clone and deployment will begin"
    #Deploy the clone
    $global:newvm = New-VM -Name $nameit -VM $global:basevm -VMHost $global:vmhost -Datastore $global:dstore -DiskStorageFormat Thin -Location $global:folder
    
    $counter = 0
    $vm = Get-VM -Name $nameit
    $int = $vm | Get-NetworkAdapter
    while($int.count -gt $counter) {
        setNetwork -vmName $nameit -numInterface $counter -preferredNetwork $global:parameters.preferred_network
        $counter+=1
    } 
    Write-Host "Clone deployed" -ForegroundColor Green
    exit

}
#-----------------------------------------------------------------------------
# Function that runs when config file is loaded
function saved_mode {

    cls
    #Defining $basevm variable
    $global:gather = Get-VM -Name "*.base.f20"
    cls_sleep #clean sleep function

    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "BASE-VM" -ForegroundColor Yellow
    list_array($global:gather)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:selection = Read-Host -Prompt "Which BASE-VM would you like to clone from?"
    user_error # this runs the error handleing and variable holding function
    $global:basevm = $global:temp #assign the verified user option to global variable

    Write-Host "You picked $global:basevm" -ForegroundColor Green
    hit_enter 
    clone_or_not
  
    #confirm settings
    Write-Host "Parent VM: $global:basevm"
    Write-Host "Snapshot: $global:snapshot"
    Write-Host "VMware ESXi Host Server: $global:vmhost"
    Write-Host "Target Datastore: $global:dstore"
    Write-Host "Target Folder: $global:folder"
    #pick if regular clone, full clone, or linked clone

    #pick the name

    #Deploy
}

#-----------------------------------------------------------------------------
# This will decide whether linked or not
function clone_or_not {
    $choice = Read-Host -Prompt "Would you like this clone to be [L]inked or [R]egular"
    if ($choice -eq "L") {
        Write-Host "Linked Clone - Gotcha" -ForegroundColor Green
        sleep 1
        deploy_box

    } elseif ($choice -eq "R") {
        Write-Host "Regular Clone - Gotcha" -ForegroundColor Blue
        sleep 1
        deploy_reg

    } else {
        Write-Host "Not an option" -ForegroundColor Red
        sleep 1
        clone_or_not
    }
}

config_file
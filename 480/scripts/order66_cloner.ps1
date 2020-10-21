#-----------------------------------------------------------------------------
#This will be an automation script for deploying images of boxes on vSphere.
#-----------------------------------------------------------------------------

#Create global variables
$global:basevm = $null
$global:snapshot = $null
$global:vmhost = $null
$global:dstore = $null
$global:folder = $null
$global:viserver = $null
$global:newvm = $null
#-----------------------------------------------------------------------------
function list_array($array){
    for($i=0; $i -lt $array.length; $i++){
        write-host ($i+1)": "$array[$i]
    }
} #close list_array function

#-----------------------------------------------------------------------------
#Define the main menu function
function main_menu {

    $gather1 = Get-VMHost
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
#Clear screen function
function cls_sleep {

    #Clear screen
    cls
    #Wait 1 second
    sleep 1

    } #Close function

#------------------------------------------------------------------------------
#Deploy box
function deploy_box {
    
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

    # Prompt the user
    $nameit = Read-Host -Prompt "Name the clone and deployment will begin"
    #Deploy the clone
    $newvm = New-VM -Name $nameit -VM $global:basevm -LinkedClone -ReferenceSnapshot $global:snapshot -VMHost $global:vmhost -Datastore $global:dstore -DiskStorageFormat Thin -Location $global:folder
    
    Write-Host "Clone deployed" -ForegroundColor Green
    exit
    }

#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
#vm_parent function
function vm_parent {
    
    #variable population
    $collect1 = Get-VM -Name "*.base.f20"
    
    #clean it up
    cls_sleep
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "BASE-VM" -ForegroundColor Yellow

    list_array($collect1)
    # Define the $basevm variable
    Write-Host "---------------------------------------" -ForegroundColor Cyan

    # user input error handling
    $selection = Read-Host -Prompt "Which BASE-VM would you like to clone from?"
    if (num_check($selection[0])) {
        write-host "Invalid input" -ForegroundColor Red
        $selection = $null
        vm_parent
    } elseif ([int]$selection -gt [int]$collect1.length) {
        write-host "Invalid input" -ForegroundColor Red
        $selection = $null
        vm_parent
    } else {
        $global:basevm = $collect1[$selection-1]
    }
    # Define $snapshot variable
    $collect2 = Get-VM -Name "$global:basevm" | Get-Snapshot
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Snapshot" -ForegroundColor Yellow
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    list_array($collect2)

    $selection2 = Read-Host -Prompt "Which snapshot do you want to use?"
    if (num_check($selection2[0])) {
        write-host "Invalid input" -ForegroundColor Red
        $selection2 = $null
        vm_parent
    } elseif ([int]$selection2 -gt [int]$collect2.length) {
        write-host "Invalid input" -ForegroundColor Red
        $selection2 = $null
        vm_parent
    } else {
        $global:snapshot = $collect2[$selection2-1]
    }
    # Return to define_variables
    define_variables
}

#------------------------------------------------------------------------------
#vSphere server details function
function server_details {
    $gather1 = Get-VMHost
    $gather2 = Get-Datastore #| Select Name
    $gather3 = Get-Folder -type VM
    #clear screen
    cls_sleep

    #Define the $vmhost
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Server Name" -ForegroundColor Yellow
    list_array($gather1)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $selection3 = Read-Host -Prompt "Select the number for the VMware server"
    if (num_check($selection3[0])) {
        write-host "Invalid input" -ForegroundColor Red
        $selection3 = $null
        server_details
    } elseif ([int]$selection3 -gt [int]$gather1.length) {
        write-host "Invalid input" -ForegroundColor Red
        $selection3 = $null
        server_details
    } else {
        $global:vmhost = $gather1[$selection3-1]
    }

    #Define the $dstore
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Datastore Name" -ForegroundColor Yellow
    list_array($gather2)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $selection4 = Read-Host -Prompt "Select the number for the corresponding datastore"
    if (num_check($selection4[0])) {
        write-host "Invalid input" -ForegroundColor Red
        $selection4 = $null
        server_details
    } elseif ([int]$selection4 -gt [int]$gather2.length) {
        write-host "Invalid input" -ForegroundColor Red
        $selection4 = $null
        server_details
    } else {
        $global:dstore = $gather2[$selection4-1]
    }
    
    # Define the $folder
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Folder Name" -ForegroundColor Yellow
    list_array($gather3)
    $selection5 = Read-Host -Prompt "Select the number for the corresponding folder"
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    if (num_check($selection5[0])) {
        write-host "Invalid input" -ForegroundColor Red
        $selection5 = $null
        server_details
    } elseif ([int]$selection5 -gt [int]$gather3.length) {
        write-host "Invalid input" -ForegroundColor Red
        $selection5 = $null
        server_details
    } else {
        $global:folder = $gather3[$selection5-1]
    }

    #Confirmation
    Write-Host "Variables set!" -ForegroundColor Green
    hit_enter

    # Return to define_variables
    main_menu
}

#---------------------------------------------------
# hit enter function
function hit_enter {
    Read-Host -prompt "Press [Enter] to continue"
}

#---------------------------------------------------
#Check connection
function check_con {
    
    $con = $null
    #Check if user is connected to a server
    $con = Get-VMHost | Select Name, ConnectionState

    #Decide if connected or not
    if ($con -eq $null) {

        #No connection - connect to one
        cls
        Write-Host -BackgroundColor Black -ForegroundColor Red "No connection to VIServer - To connect to a VI server do the following" 
        hit_enter

        # Create the connection
        $global:viserver = Read-Host -prompt "Type in the name or address of the VI server you wish to connect to (eg. vcenter.domain.local)"
        sleep 1
        Connect-VIServer -Server $global:viserver
        hit_enter
        main_menu

    } else {

        #Display the connection and launch main menu
        Write-Host "You're already connected to a VI server" -ForegroundColor Green
        hit_enter
        main_menu
    }

}

#-----------------------------------------------------------------------------
# This will decide whether linked or not
function clone_or_not {
    $choice = Read-Host -Prompt "Would you like this clone to be [L]inked or [R]egular"
    if ($choice -eq "L") {
        Write-Host "Linked Clone - Gotcha"
        deploy_box

    } elseif ($choice -eq "R") {
        Write-Host "Regular Clone - Gotcha"
        deploy_reg

    } else {
        Write-Host "Not an option" -ForegroundColor Red
        sleep 1
        clone_or_not
    }
}

#-----------------------------------------------------------------------------
# This will deploy full clone
function deploy_reg {
    

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

    # Prompt the user
    $nameit = Read-Host -Prompt "Name the clone and deployment will begin"
    #Deploy the clone
    $newvm = New-VM -Name $nameit -VM $global:basevm -VMHost $global:vmhost -Datastore $global:dstore -DiskStorageFormat Thin -Location $global:folder
    
    Write-Host "Clone deployed" -ForegroundColor Green
    exit
    }

#-----------------------------------------------------------------------------
# Number check
function num_check($stats) {
    $math = [int][char]$stats
    if(48 -lt $math -and $math -lt 58) {
        return $false
    } else {
        return $true
    }
}

#run the script
check_con
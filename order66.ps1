#-----------------------------------------------------------------------------
#This will be an automation script for deploying images of boxes on vSphere.
#-----------------------------------------------------------------------------

#Create global variables
$global:basevm = $null
$global:snapshot = $null
$global:vmhost = $null
$global:dstore = $null
$global:folder = $null

#Define the main menu function
function main_menu {

    cls_sleep

    #Create Menu
    option_statement
    Write-Host "[1] Deploy Box"
    Write-Host "[2] Define Variables"
    Write-Host "[E] Exit"
    
    # Prompt the user
    Write-Host "---------------------------------------" -ForegroundColor Cyan 
    $user_option = Read-Host -Prompt "Please select one of the above options"

    # Process the selection
    if ($user_option -eq 1) {

        # Call deploy_box function
        deploy_box

    } elseif ($user_option -eq 2) {

        # Call define_variables function
        define_variables
        
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
#Choose an option
function option_statement {

    #Display the command
    Write-Host -ForegroundColor Cyan "----------------"
    Write-Host -BackgroundColor Black -ForegroundColor White "Choose an option"
    Write-Host -ForegroundColor Cyan "----------------"

    } #Close function

#------------------------------------------------------------------------------
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
    Write-Host $global:basevm
    Write-Host $global:snapshot
    Write-Host $global:vmhost
    Write-Host $global:dstore
    Write-Host $global:folder

    }

#------------------------------------------------------------------------------
#Define Variables
function define_variables {
    
    #Clear screen
    cls_sleep

    #Print menu
    Write-Host "-------------------" -ForegroundColor Cyan
    Write-Host "Which variable(s) would you like to define?" -BackgroundColor Black -ForegroundColor Yellow
    Write-Host "-------------------" -ForegroundColor Cyan
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
        Write-Host "Chose a valid option" -BackgroundColor Black -ForegroundColor Cyan
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

    #Clear screen
    cls_sleep

    # Define the $basevm and $snapshot variables
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Get-VM -Location "BASE-VMS" | Get-Snapshot | select VM, Name
    $global:basevm = Read-Host -Prompt "Which BASE-VM would you like to clone from?"
    $global:snapshot = Read-Host -Prompt "Type the name of the base snapshot printed above"

    # Return to define_variables
    define_variables
}

#------------------------------------------------------------------------------
#vSphere server details function
function server_details {

    #clear screen
    cls_sleep

    #Define the $vmhost, $dstore, and $folder
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    
    Get-VMHost #print the VMHost
    $global:vmhost = Read-Host -Prompt "Confirm the address of the vSphere server this clone will be deployed on."
    
    Get-Datastore #print the datastore option(s)
    $global:dstore = Read-Host -Prompt "Which datastore do you want the clone stored on?"
    
    Get-Folder -type VM | select Name
    $global:folder = Read-Host -Prompt "Which folder should contain this clone?"

    #Confirmation
    Write-Host "Variables set!"
    sleep 1

    # Return to define_variables
    define_variables
}

main_menu
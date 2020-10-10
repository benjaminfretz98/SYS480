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
#Define the main menu function
function main_menu {

    cls_sleep

    #Create Menu
    option_statement
    Write-Host "[1] Deploy Clone"
    Write-Host "[2] Set Clone Variables"
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

    $nameit = Read-Host -Prompt "What would you like to name this clone?"
    #Test Deploy
    $newvm = New-VM -Name $nameit -VM $global:basevm -LinkedClone -ReferenceSnapshot $global:snapshot -VMHost $global:vmhost -Datastore $global:dstore -DiskStorageFormat Thin -Location $global:folder
    
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
    
    $counter = 0 #used to keep track through printing collect1 array
    #variable population
    $collect1 = Get-VM -Name "*.base.f20"
    
    #clean it up
    cls_sleep
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "BASE-VM" -ForegroundColor Yellow
    foreach ($name in $collect1) {
        write-host $collect1[$counter]
        $counter+=1
    }

    # Define the $basevm variable
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:basevm = Read-Host -Prompt "Which BASE-VM would you like to clone from?"
    
    # Define $snapshot variable
    $collect2 = Get-VM -Name "$global:basevm" | Get-Snapshot
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Snapshot" -ForegroundColor Yellow
    $collect2
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:snapshot = Read-Host -Prompt "Type the name of the base snapshot printed above"

    # Return to define_variables
    define_variables
}

#------------------------------------------------------------------------------
#vSphere server details function
function server_details {

    $gather1 = Get-VMHost
    $gather2 = Get-Datastore | Select Name
    $gather3 = Get-Folder -type VM | Select Name
    #clear screen
    cls_sleep

    #Define the $vmhost, $dstore, and $folder
    #Get-VMHost #print the VMHost
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Server Name" -ForegroundColor Yellow
    $gather1
    sleep 1 #load time
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:vmhost = Read-Host -Prompt "Type the 'Name' of the VMware server"
    
    #Get-Datastore | Select Name #print the datastore option(s)
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Datastore Name" -ForegroundColor Yellow
    $gather2
    sleep 1 #load time
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:dstore = Read-Host -Prompt "Type the 'Name' of the intended datastore"
    
    #Get-Folder -type VM | select Name
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    Write-Host "Folder Name" -ForegroundColor Yellow
    $gather3
    sleep 1 #load time
    Write-Host "---------------------------------------" -ForegroundColor Cyan
    $global:folder = Read-Host -Prompt "Which folder should contain this clone?"

    #Confirmation
    Write-Host "Variables set!" -ForegroundColor Green
    hit_enter

    # Return to define_variables
    define_variables
}

#---------------------------------------------------
# hit enter function
function hit_enter {

    Read-Host -prompt "Press [Enter] to continue..."
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
        $global:viserver = Read-Host -prompt "Type in the name or address of the VI server you wish to connect to"
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
#main_menu
check_con
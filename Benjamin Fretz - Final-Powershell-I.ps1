# This script will have two main features: A System Admin feature and a Security Admin feature
# The System Admin feature will produce a submenu allowing the user to display, save, and search through all running processes, services, installed packages, available hardware space, and event logs.
# The Security Admin feature produce a submenu allowing the user to display, save, and search through recent security vulnerabilitues identified by the NVD project.

#-------------------------------------------------------------------------------------------------------------------------

#define main menu function
function main_menu {

    #clear the screen
    cls
    #wait 1 second
    sleep 1

    #Create menu
    Write-Host -ForegroundColor Cyan "----------------"
    Write-Host -BackgroundColor Black -ForegroundColor White "Choose an option."
    Write-Host -ForegroundColor Cyan "----------------"
    Write-Host "(1) System Admin Tasks"
    Write-Host "(2) Security Admin Tasks" 
    Write-Host "(E) Exit"

    #Prompt user to chose an option
    Write-Host -ForegroundColor Cyan "---------------------------------------"
    $user_selection = Read-Host -Prompt "Please select one of the above options"

    #Process the user selection
    if ($user_selection -eq 1) {
        
        sys_admin

    } elseif ($user_selection -eq 2) {

        sec_admin

    } elseif ($user_selection -eq "E") {

        #Exit the program
        Write-Host ""
        Write-Host "Thanks for using this program!" -BackgroundColor Black -ForegroundColor Cyan
        exit

    } else {

        Write-Host -ForegroundColor Red -BackgroundColor Black "Invalid menu option."
        #Wait 1 second
        sleep 1
        #Reprint main menu options
        main_menu

    } #close if statement

} #ends main menu function

#-------------------------------------------------------------------------------------------------------------------------

#define the system admin menu option
function sys_admin {

    #clear screen
    cls
    #wait 1 second
    sleep 1
    #Create Menu
    Write-Host "-----------------" -ForegroundColor Cyan
    Write-Host "System Admin Menu" -BackgroundColor Black -ForegroundColor Gray
    Write-Host "-----------------" -ForegroundColor Cyan
    Write-Host "(1) List all running processes."
    Write-Host "(2) List all running services."
    Write-Host "(3) List all installed packages."
    Write-Host "(4) List the processor, amount of RAM, mounted disks, available disk space, and used disk space."
    Write-Host "(5) List available Windows Event Logs"
    Write-Host "(R) Return to the Main Menu."
    Write-Host "(E) Exit the program."

    #prompt the user
    Write-Host -ForegroundColor Cyan "---------------------------------------"
    $system_admin_task = Read-Host -Prompt "Please select one of the above options"

    #process the user selection
    if ($system_admin_task -eq 1) {

        #call save_or_print_processes function
        save_or_print_processes

    } elseif ($system_admin_task -eq 2) {

        #call save_or_print_services function
        save_or_print_services

    } elseif ($system_admin_task -eq 3) {

        #Call save_or_print_packages function
        save_or_print_packages

    } elseif ($system_admin_task -eq 4) {

        #call hardware statistics function
        hardware_statistics

    } elseif ($system_admin_task -eq 5) {

        #Call event log function
        event_logs

    } elseif ($system_admin_task -eq "R") {

        #Return to the Main Menu
        Write-Host "Returning to Main Menu" -ForegroundColor Gray -BackgroundColor Black
        #wait 1 second
        sleep 1
        #clear screen
        cls
        #run main menu function
        main_menu

    } elseif ($system_admin_task -eq "E") {

        #Exit the program
        Write-Host ""
        Write-Host "Thanks for using this program!" -BackgroundColor Black -ForegroundColor Cyan
        exit

    } else {

        Write-Host -ForegroundColor Red -BackgroundColor Black "Invalid menu option."
        #wait 1 second
        sleep 1
        #reprint System Admin menu
        sys_admin

    } #close if statement

} #end system admin menu option

#-------------------------------------------------------------------------------------------------------------------------

#define the security admin menu option
function sec_admin {

    #clear the screen
    cls
    #wait 1 second
    sleep 1

    #Create Menu
    Write-Host "-------------------" -ForegroundColor Cyan
    Write-Host "Security Admin Menu" -BackgroundColor Black -ForegroundColor Yellow
    Write-Host "-------------------" -ForegroundColor Cyan
    Write-Host "(1) List all Running Processes, Services, Installed Packages, System Hardware, or Event Logs by calling System Admin Menu"
    Write-Host "(2) Search for security vulnerabilities"
    Write-Host "(R) Return to the Main Menu."
    Write-Host "(E) Exit the program."

    #prompt the user
    Write-Host "---------------------------------------" -ForegroundColor Cyan 
    $security_admin_task = Read-Host -Prompt "Please select one of the above options"
    
    #process the user selection
    if ($security_admin_task -eq 1) {

        #Call sys admin menu
        sys_admin

    } elseif ($security_admin_task -eq 2) {

        #Call option 2
        security_vulnerabiities

    } elseif ($security_admin_task -eq "R") {

        #return to Main Menu
        Write-Host "Returning to Main Menu" -ForegroundColor Yellow -BackgroundColor Black
        #wait 2 seconds
        sleep 2
        #clear screen
        cls
        #run Main Menu function
        main_menu

    } elseif ($security_admin_task -eq "E") {

        #Exit the program
        Write-Host ""
        Write-Host "Thanks for using this program!" -BackgroundColor Black -ForegroundColor Cyan
        exit

    } else {

        Write-Host -BackgroundColor Black -ForegroundColor Red "Invalid menu option."
        #wait 1 second
        sleep 1
        #reprint Security Admin menu
        sec_admin

    } #close if statement

} #End security admin function

#-------------------------------------------------------------------------------------------------------------------------

#define function to prompt user to hit [Enter] when they are done reviewing results, then take them back to main menu
function hit_enter {

    Read-Host -prompt "Press [Enter] when done"

    } #end hit_enter function

#-------------------------------------------------------------------------------------------------------------------------

#define function printing out options submenu regarding saving or printing within system admin tasks
function sys_admin_options {

    Write-Host ""
    Write-Host "----------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Would you like to save the results of this search to a CSV file?" -BackgroundColor Black -ForegroundColor Gray
    Write-Host "----------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "(Y) Save results to CSV"
    Write-Host "(N) Prints results to the screen"

    } #end sys_admin_options function

#-------------------------------------------------------------------------------------------------------------------------

function file_path_request {

    Write-Host -BackgroundColor Black -ForegroundColor White "Ensure you type the complete filepath or it will save to the current directory"
    Write-Host -BackgroundColor Black -ForegroundColor Green "Example: C:\Users\Ben Fretz\Desktop\FileToSave.csv"
    Write-Host -BackgroundColor Black -ForegroundColor Yellow "There is no need for quotations... don't worry about color changing file paths, it still works properly."

    } #end filepath request function

#-------------------------------------------------------------------------------------------------------------------------

function cls_sleep {

    #clear screen
    cls
    #wait 1 second
    sleep 1

    } #close cls_sleep function

#-------------------------------------------------------------------------------------------------------------------------

function save_or_print_processes {
    #clear the screen
    cls

    #prompt user for decision for listing specific or all processes.
    $Search_Specific_or_Display_All = Read-Host -Prompt "If you would like to search for a specific process, type the name now. Otherwise hit [Enter] to list all running processes"

    #create variable containing process information
    $ProcessList = Get-Process -Name *$Search_Specific_or_Display_All* | select ID, ProcessName

    #clear screen and sleep
    cls_sleep

    #build options menu using function
    sys_admin_options

    #prompt user if they want to save to output file or print to screen
    Write-Host ""
    $User_Save_or_Print_Processes = Read-Host -Prompt "Choose one of the above options"

    #process the user selection
    if ($User_Save_or_Print_Processes -eq "Y") {

        #clear screen and sleep
        cls_sleep

        #Ask to provide filename and location using function
        file_path_request

        #Create variable with user request file path
        $save_path = Read-Host -Prompt "Type the full file path location where you would like to save the results"

        #Ensure $save_path has a value
        While ($save_path -eq "") {
            Write-Host "Please enter in a valid file path" -BackgroundColor Black -ForegroundColor Red
            $save_path = Read-Host -Prompt " "

            } #end While loop

        #Save file to chosen location
        $ProcessList | Export-Csv -NoTypeInformation -Path $save_path

        #Wait 1 second
        sleep 1

        #Evaluate whether path was created successfully.
        if (Test-Path $save_path) {

            #inform user that file was created successfully
            Write-Host "File successfully created" -BackgroundColor Black -ForegroundColor Green
            Write-Host "Saved Location is:"$save_path -BackgroundColor Black -ForegroundColor Green

            #run hit enter function before returning user to Sys_admin menu
            hit_enter

            #Notify user they will return to sys admin menu
            Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

            #wait 1 second
            sleep 1

            #Return to sys admin menu
            sys_admin

        } else {

            #inform user that file creation failed
            Write-Host "Error: File creation was unsuccessful." -BackgroundColor Black -ForegroundColor Red

            #run hit enter function before returning to previous menu
            hit_enter

            #Notify user they will return to sys admin menu
            Write-Host "Returning to previous menu" -BackgroundColor Black -ForegroundColor Gray

            #run function for previous menu
            save_or_print_processes

        }  #End inner IF statement 

    } elseif ($User_Save_or_Print_Processes -eq "N") {

        #print the list to the screen
        $ProcessList | Out-Host

        #go back to system Admin menu using "enter"
        hit_enter

        #Notify user they will return to sys admin menu
        Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

        #wait 1 second
        sleep 1

        #run function returning to sys admin menu
        sys_admin

    } else {

        Write-Host -ForegroundColor Red -BackgroundColor Black "Invalid menu option."
        #wait 1 second
        sleep 1
        #reprint menu"
        save_or_print_processes

    } #end outer IF statement

} # End save or print processes function

#-------------------------------------------------------------------------------------------------------------------------

function save_or_print_services {

    #clear the screen
    cls

    #prompt user for decision for listing specific service or all services
    $services_user_decision = Read-Host -Prompt "If you would like to search for a specific service, type the name now, otherwise hit [Enter] to list all running services"
    
    #create variable containing services information
    $ServiceList = Get-Service -Name *$services_user_decision* | where {$_.Status -eq "Running"} | select Name, Status, ServiceType

    #clear screen and sleep
    cls_sleep

    #build options menu using function
    sys_admin_options

    #prompt user if they want to save to output file or print to screen
    Write-Host ""
    $User_Save_or_Print_Services = Read-Host -Prompt "Choose one of the above options"

    #process the user selection
    if ($User_Save_or_Print_Services -eq "Y") {

        #clear screen and sleep
        cls_sleep

        #Ask to provide filename and location
        file_path_request
        
        #Create a variable with user request file path
        $service_path = Read-Host -Prompt "Type the full file path location where you would like to save the results"

        #Ensure $service_path has a value
        While ($service_path -eq "") {
            Write-Host "Please enter in a valid file path" -BackgroundColor Black -ForegroundColor Red
            $service_path = Read-Host -Prompt " "
            } #end while loop

        #Save file to chosen location
        $ServiceList | Export-Csv -NoTypeInformation -Path $service_path

        #Wait 1 second
        sleep 1

        #Evaluate whether path was created successfully.
        if (Test-Path $service_path) {

            #inform user that file was created successfully
            Write-Host "File successfully created" -BackgroundColor Black -ForegroundColor Green
            Write-Host "Saved Location is:"$service_path -BackgroundColor Black -ForegroundColor Green

            #run hit enter function before returning user to Sys_admin menu
            hit_enter

            #Notify user they will return to sys admin menu
            Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

            #wait 1 second
            sleep 1

            #Return to sys admin menu
            sys_admin

        } else {

            #inform user that file creation failed
            Write-Host "Error: File creation was unsuccessful." -BackgroundColor Black -ForegroundColor Red

            #run hit enter function before returning to previous menu
            hit_enter

            #Notify user they will return to sys admin menu
            Write-Host "Returning to previous menu" -BackgroundColor Black -ForegroundColor Gray

            #wait 1 second
            sleep 1

            #run function to return to previous menu
            save_or_print_processes

            } #end inner if statement

    } elseif ($User_Save_or_Print_Services -eq "N") {

        #clear screen and sleep
        cls_sleep

        #notify user results are printing
        Write-Host "Printing Results" -BackgroundColor Black -ForegroundColor Gray

        #wait 1 second
        sleep 1

        #print results
        $ServiceList | Out-Host
        #return to sys admin menu using [Enter]
        hit_enter

        #tell user they are returning to system admin menu
        Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

        #wait 1 second
        sleep 1

        #run return function
        sys_admin

    } else {

        Write-Host -ForegroundColor Red -BackgroundColor Black "Invalid menu option."
        #wait 1 second
        sleep 1
        #reprint menu"
        save_or_print_services

    } #end outer if statement

} # End save or print services function

#-------------------------------------------------------------------------------------------------------------------------

function save_or_print_packages {

    #clear the screen
    cls

    #prompt user for decision for finding specific or all packages
    $packages_user_decision = Read-Host -Prompt "If you would like to check if a specific package is installed, type it now, otherwise hit [Enter] to list all installed packages"

    #notify user program is gathering information
    Write-Host "Gathering list of installed packages" -BackgroundColor Black -ForegroundColor Gray
    #create variable containing package information
    $PackageList = Get-WmiObject Win32_Product | where { $_.Name -ilike "*$packages_user_decision*"} | Format-Table -Property InstallDate, Version, Name

    #clear screen and sleep
    cls_sleep

    #build options menu using function
    sys_admin_options

    #prompt user if they want to save to output file or print to screen
    Write-Host ""
    $User_Save_or_Print_Packages = Read-Host -Prompt "Choose one of the above options"

    #process the user selection
    if ($User_Save_or_Print_Packages -eq "Y") {

        #clear screen and sleep
        cls_sleep

        #run file path function
        file_path_request

        #Create a variable with user request file path
        $package_path = Read-Host -Prompt "Type the full file path location where you would like to save the results"

        #Ensure $service_path has a value
        While ($package_path -eq "") {
            Write-Host "Please enter in a valid file path" -BackgroundColor Black -ForegroundColor Red
            $package_path = Read-Host -Prompt " "
            } #end while loop

        #Save file to chosen location
        $PackageList | Export-Csv -NoTypeInformation -Path $package_path

        #Wait 1 second
        sleep 1

        #Evaluate whether path was created successfully.
        if (Test-Path $package_path) {

            #inform user that file was created successfully
            Write-Host "File successfully created" -BackgroundColor Black -ForegroundColor Green
            Write-Host "Saved Location is:"$package_path -BackgroundColor Black -ForegroundColor Green

            #run hit enter function before returning user to Sys_admin menu
            hit_enter

            #Notify user they will return to sys admin menu
            Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Green

            #wait 1 second
            sleep 1

            #Return to sys admin menu
            sys_admin

        } else {

            #inform user that file creation failed
            Write-Host "Error: File creation was unsuccessful." -BackgroundColor Black -ForegroundColor Red

            #run hit enter function before returning to previous menu
            hit_enter
            save_or_print_processes

        } #end inner IF statement

        #run hit enter function before returning user to Sys_admin menu
        hit_enter

        #Notify user they will return to sys admin menu
        Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Green

        #wait 1 second
        sleep 1

        #Return to sys admin menu
        sys_admin

    } elseif ($User_Save_or_Print_Packages -eq "N") {

        #clear screen and sleep
        cls_sleep

        #notify user results are printing
        Write-Host "Printing Results" -BackgroundColor Black -ForegroundColor Gray

        #wait 1 second
        sleep 1

        #print results
        $PackageList | Out-Host
        #return to sys admin menu using [Enter]
        hit_enter
        #call sys admin menu function
        sys_admin

    } else {

        Write-Host -ForegroundColor Red -BackgroundColor Black "Invalid menu option."
        #wait 1 second
        sleep 1
        #reprint menu"
        save_or_print_packages

    } #end outer IF statement

} #End save or print packages function

#-------------------------------------------------------------------------------------------------------------------------

function hardware_statistics {

    #clear the screen and sleep
    cls_sleep

    #notify user of information gathering
    Write-Host "Information is being gathered about the Hardware" -BackgroundColor Black -ForegroundColor Gray

    #gather hardware information (Processor, amount of RAM, mounted disks, disk space available, and disk space used)
    $processor = Get-WmiObject Win32_processor | Select -Property Name
    $ram = "RAM = " + (Get-WmiObject Win32_ComputerSystem).totalphysicalmemory / (1024 * 1024 * 1024) + " GB"
    $diskID0 = "Disk " + (Get-WmiObject Win32_Logicaldisk).DeviceID[0]
    $diskUsedSpace0 = "GB Used: " + ((Get-WmiObject Win32_Logicaldisk).Size[0] - (Get-WmiObject Win32_Logicaldisk).FreeSpace[0]) / (1024 * 1024 * 1024)
    $diskFreeSpace0 = "GB Free: " + (Get-WmiObject Win32_Logicaldisk).FreeSpace[0] / (1024 * 1024 * 1024)
    $diskID1 = "Disk " + (Get-WmiObject Win32_Logicaldisk).DeviceID[1]
    $diskUsedSpace1 = "GB Used: " + ((Get-WmiObject Win32_Logicaldisk).Size[1] - (Get-WmiObject Win32_Logicaldisk).FreeSpace[1]) / (1024 * 1024 * 1024)
    $diskFreeSpace1 = "GB Free: " + (Get-WmiObject Win32_Logicaldisk).FreeSpace[1] / (1024 * 1024 * 1024)   
   
    #creating exportable variable for CSV
    $report = New-Object psobject
    $report | Add-Member -MemberType NoteProperty -Name Processor -Value $processor.Name
    $report | Add-Member -MemberType NoteProperty -Name RAM -Value $ram
    $report | Add-Member -MemberType NoteProperty -Name DiskName -Value $diskID0
    $report | Add-Member -MemberType NoteProperty -Name UsedSpace -Value $diskUsedSpace0 
    $report | Add-Member -MemberType NoteProperty -Name AvailableSpace -Value $diskFreeSpace0
    $report | Add-Member -MemberType NoteProperty -Name DiskName2 -Value $diskID1
    $report | Add-Member -MemberType NoteProperty -Name UsedSpace2 -Value $diskUsedSpace1
    $report | Add-Member -MemberType NoteProperty -Name AvailableSpace2 -Value $diskFreeSpace1

    #Creating a Printable View of Hardware Statistics
    #C drive Disk Drive
    $C_Drive_Disk = "Disk " + (Get-WmiObject Win32_Logicaldisk).DeviceID[0]
    #C drive Used Space
    $C_Drive_Used_Space = "GB Used: " + ((Get-WmiObject Win32_Logicaldisk).Size[0] - (Get-WmiObject Win32_Logicaldisk).FreeSpace[0]) / (1024 * 1024 * 1024)
    #C drive Free Space
    $C_Drive_Free_Space = "GB Free: " + (Get-WmiObject Win32_Logicaldisk).FreeSpace[0] / (1024 * 1024 * 1024)
    #D drive Disk Drive
    $D_Drive_Disk = "Disk " + (Get-WmiObject Win32_Logicaldisk).DeviceID[1]
    #D drive Used Space
    $D_Drive_Used_Space = "GB Used: " + ((Get-WmiObject Win32_Logicaldisk).Size[1] - (Get-WmiObject Win32_Logicaldisk).FreeSpace[1]) / (1024 * 1024 * 1024)
    #D drive Free Space
    $D_Drive_Free_Space = "GB Free: " + (Get-WmiObject Win32_Logicaldisk).FreeSpace[1] / (1024 * 1024 * 1024)

    #clear_screen and sleep
    cls_sleep

    #Build Menu
    sys_admin_options

    #Prompt user for a selection
    Write-Host ""
    $User_Save_or_Print_Hardware = Read-Host -Prompt "Chose one of the above options"

    #Process the user selection
    if ($User_Save_or_Print_Hardware -eq "Y") {

        #clear screen and sleep
        cls_sleep

        #Ask to provide filename and location using function
        file_path_request

        #create a variable with user request file path
        $hardware_path = Read-Host -Prompt "Type the full file path location where you would like to save the results"
        
        #Ensure $hardware_path has a value
        While ($hardware_path -eq "") {
            Write-Host "Please enter in a valid file path" -BackgroundColor Black -ForegroundColor Red
            $hardware_path = Read-Host -Prompt " "

        } #end while loop

        #Save file to chosen location
        $report | Export-Csv -NoTypeInformation -Path $hardware_path

        #wait 1 second
        sleep 1

        #Evaluate whether path was created successfully.
        if (Test-Path $hardware_path) {

            #inform user that the file was created successfully
            Write-Host "File successfully created" -BackgroundColor Black -ForegroundColor Green
            Write-Host "Saved Location is:"$hardware_path -BackgroundColor Black -ForegroundColor Green

            #run hit enter function before returning user to sys_admin menu
            hit_enter

            #notify user they will return to sys admin menu
            Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

            #wait 1 second
            sleep 1

            #Return to sys admin menu
            sys_admin

        } else {
            
            #inform user that file creation failed
            Write-Host "Error: File creation was unsuccessful." -BackgroundColor Black -ForegroundColor Red

            #run hit enter function before returning to previous menu
            hit_enter
            hardware_statistics

        } #end inner if statement

    } elseif ($User_Save_or_Print_Hardware -eq "N") {

        #clear screen and sleep
        cls_sleep

        #print results to the screen
        Write-Host " " #formatting space
        Write-Host "Hardware Information" -BackgroundColor Black -ForegroundColor Gray
        $processor | Out-Host
        $ram | Out-Host
        Write-Host " " #formatting space
        $C_Drive_Disk
        $C_Drive_Used_Space
        $C_Drive_Free_Space
        Write-Host " " #formatting space
        $D_Drive_Disk
        $D_Drive_Used_Space
        $D_Drive_Free_Space
        #go back to system admin menu using "Enter"
        hit_enter

        #notify user they will return to sys_admin menu
        Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

        #wait 1 second
        sleep 1

        #Return to Sys Admin Menu
        sys_admin

    } else {

        Write-Host -ForegroundColor Red -BackgroundColor Black "Invalid menu option."
        
        #wait 1 second
        sleep 1
        
        #reprint menu"
        hardware_statistics

    } #end if statement

} # End hardware statistics function

#-------------------------------------------------------------------------------------------------------------------------

function NumberCheck { #check to see if user entry is a number
    
    $yes = " " #acts as placeholder to decide whether or not answer is acceptable (number or not)
    $script:Choose_Events = Read-Host "Enter the number of events you would like to receive"
    
        for($i=0; $i -lt $Choose_Events.length; $i++){
            if(58 -lt [int][char]$Choose_Events[$i] -or [int][char]$Choose_Events[$i] -lt 47){

                $yes = "letter"
                    }
            } #end IF statement
            if ($yes -eq "letter") {

                    #if entered is not a number
                    Write-Host "Not a valid answer" -BackgroundColor Black -ForegroundColor Red
                    
                    #restart function
                    NumberCheck
        } #end FOR loop 
      
} #end function

#-------------------------------------------------------------------------------------------------------------------------

function event_logs {
    
    #clear screen and sleep
    cls_sleep

    #Create list of possible logs to search
    $LogOptions = Get-Eventlog -list | select Log | Out-Host

    #Inform user of their options
    Write-Host "These are the possible Logs which you can search" -BackgroundColor Black -ForegroundColor Gray
    $LogOptions

    #Ask which log they want to search
    $Log_Choice = Read-Host -Prompt "Which log would you like to search?"

    #Verify choice
    $TestingList = "Application","HardwareEvents","Hewlett-Packard","HP CASL Framework","Internet Explorer","Kaspersky Event Log","OAlerts","Security","System","Windows Powershell"
    if ($Log_Choice -notin $TestingList) {

        #tell user they entered option incorrectly
        Write-Host "You did not enter in one of the available options" -BackgroundColor Black -ForegroundColor Red

        #Tell user function is restarting
        Write-Host "Restarting function" -BackgroundColor Black -ForegroundColor Gray

        #wait 1 second
        sleep 1
        Write-Host "..................." -BackgroundColor Black -ForegroundColor Gray
        
        #wait 1 second
        sleep 1

        #restart function
        event_logs
   
    } #close if statement

    #Ask how many logs they want to list
    NumberCheck
   
    #Ask if they want to search for a specific keyword
    $Keyword_search = Read-Host -Prompt "Would you like to search for a specific keyword? If so, type it now. If not, press [Enter] to search all events"

    #gather search information
    $LogList = Get-EventLog $Log_Choice -Newest $Choose_Events | where {$_.Message -ilike "*$Keyword_search*" }

    #clear screen and sleep
    cls_sleep

    #Build options menu
    sys_admin_options

    #Prompt user for decision
    $user_save_or_print_logs = Read-Host -Prompt "Chose on of the above options"

        #process the user selection
        if ($user_save_or_print_logs -eq "Y") {

            if ($LogList -eq $null) {
                
                #tell user nothin was found
                Write-Host "There is nothing to save because nothing was found" -BackgroundColor Black -ForegroundColor Red
                
                #return user to event log menu
                hit_enter

                #let user know they are returning to menu
                Write-Host "Returning to Event Log Menu" -BackgroundColor Black -ForegroundColor Gray

                #wait 2 seconds
                sleep 2

                #call event log menu
                event_logs

            } #end if statement

            #Ask to provide filename and location using function
            file_path_request

            #create a variable with user request file path
            $log_path = Read-Host -Prompt "Type the full file path location where you would like to save the results"
        
            #Ensure $hardware_path has a value
            While ($log_path -eq "") {
                Write-Host "Please enter in a valid file path" -BackgroundColor Black -ForegroundColor Red
                $log_path = Read-Host -Prompt " "

            } #end while loop

            #Save file to chosen location
            $LogList | Export-Csv -NoTypeInformation -Path $log_path

            #wait 1 second
            sleep 1

            #Evaluate whether path was created successfully.
            if (Test-Path $log_path) {

                #inform user that the file was created successfully
                Write-Host "File successfully created" -BackgroundColor Black -ForegroundColor Green
                Write-Host "Saved Location is:"$log_path -BackgroundColor Black -ForegroundColor Green

                #run hit enter function before returning user to sys_admin menu
                hit_enter

                #notify user they will return to sys admin menu
                Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

                #wait 1 second
                sleep 1

                #Return to sys admin menu
                sys_admin

            } else {
            
                #inform user that file creation failed
                Write-Host "Error: File creation was unsuccessful." -BackgroundColor Black -ForegroundColor Red

                #run hit enter function before returning to previous menu
                hit_enter
                event_logs

            } #close if statement

        } elseif ($user_save_or_print_logs -eq "N") {

            #print results to the screen
            Write-Host " "

            #evaluate whether or not anything was found
            if ($LogList -eq $null) {

                Write-Host "Nothing was found using your search parameters" -BackgroundColor Black -ForegroundColor Red

                } else {

                $LogList | Out-Host #if something WAS found, print it here
                
                } #close if statement


            #go back to system admin menu using "Enter"
            hit_enter

            #let user know they are returning to sys admin menu
            Write-Host "Returning to System Admin Menu" -BackgroundColor Black -ForegroundColor Gray

            #wait 2
            sleep 2

            #return to sys admin menu
            sys_admin

        } else {

            Write-Host -ForegroundColor Red -BackgroundColor Black "Invalid menu option."
            #wait 1 second
            sleep 1
            #reprint menu"
            event_logs

        } #close if statement

} #close function

#-------------------------------------------------------------------------------------------------------------------------

function security_vulnerabiities {

    #Ensures Invoke-WebRequest works properly
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #clear screen and sleep
    cls_sleep

    #build menu
    Write-Host "Would you like to search vulnerabilites from an existing CVE file or download the most recent CVE file?" -BackgroundColor Black -ForegroundColor Yellow
    Write-Host " "
    Write-Host "(1) Search from an existing CVE file"
    Write-Host "(2) Download most current CVE file, then search"
    Write-Host " "
    $cve_update_or_not = Read-Host -Prompt " "
    
    #process user choice
    if ($cve_update_or_not -eq 1) {

        #assign hard coded path to variable
        $hard_path = "C:\Users\Ben Fretz\Desktop\cve.csv"

        #retrieve existing CSV file
        if (Test-Path $hard_path) {

            #notify user the file exists
            write-host "There is an existing CVE.CSV file" -BackgroundColor Black -ForegroundColor Yellow
            
            #wait 1
            sleep 1
            #tell user file is being retrieved
            write-host "Retrieving existing file" -BackgroundColor Black -ForegroundColor Yellow
            
        } else {

            #let user know there is no file, and one will be downloaded
            write-host "There is no current CVE.CSV file. Downloading most recent now"

            #downloading most recent file
            Invoke-WebRequest -URI https://cve.mitre.org/data/downloads/allitems.csv -OutFile "c:\users\Ben Fretz\Desktop\cve.csv"

        } #close if statement

    } elseif ($cve_update_or_not -eq 2) {

        #Upadate CSV file
        Invoke-WebRequest -URI https://cve.mitre.org/data/downloads/allitems.csv -OutFile "c:\users\Ben Fretz\Desktop\cve.csv"

    } else {

        Write-Host "Incorrect Menu Option" -BackgroundColor Black -ForegroundColor Red
        
        #wait 1 second
        sleep 1

        #return to previous question
        security_vulnerabiities

    } #close IF statement

    #create email attachment array
    $email_attachment = @()

    #Import-CSV file
    $cve_file = Import-Csv "c:\users\Ben Fretz\Desktop\cve.csv" -Header Name,Status,Description,References,Phase

    #clear screen and sleep
    cls_sleep

    #Ask user how they would like to search the file
    Write-Host "How would you like to parse through the CVE (N/D)?"
    Write-Host "(N) Search for CVE using Name"
    Write-Host "(D) Search for CVE using Description"
    $parse_choice = Read-Host -prompt " " #receive user entry

    if ($parse_choice -ne "N" -and $parse_choice -ne "D") { #ensure user enters in a valid choice
        
        #notify user they entered incorrectly
        Write-Host "Invalid Menu Option" -BackgroundColor Black -ForegroundColor Red

        #wait 1 second
        sleep 1

        #restart function
        security_vulnerabiities

        } #close if statement
    
    #define variable Not found initially so it is always present when deciding if something is present or not. Used as evaluator.
    $notFound = ""

    #evaluate user choice
    if ($parse_choice -eq "N") {

        #Prompt user the specific name they want to search for.
        $inputName = Read-Host -Prompt "What CVE name would you like to search? Example: CVE-1999-0001"
        
        if ($inputName -eq "") { #ensure user enters in acceptable answer

            #cant search for a blank name
            Write-Host "You cannot search for a CVE without a name!" -BackgroundColor Black -ForegroundColor Red
            Write-Host "Restarting function"

            #sleep 2
            sleep 2

            #restart function
            security_vulnerabiities

        } #end if statement
            
        #Parse through each line of CSV file.
        foreach ($cveEntry in $cve_file) {
            #If there is a positive match.
            if ($cveEntry.Name -eq "$inputName") {
                # Print that the CVE was found.
                write-host -BackgroundColor DarkGreen "Found."
                # Assign the results for the CVE to variables.
                $entryName = $cveEntry.Name
                $entryDesc = $cveEntry.Description
                $entryStatus = $cveEntry.Status
                $entryReferences = $cveEntry.References
                $entryPhase = $cveEntry.Phase

                #Add entry to array
                $email_attachment += $cveEntry

                #Print the newly assigned variables.
                Write-Host "CVE NAME: $entryName" -BackgroundColor Black -ForegroundColor Yellow
                Write-Host "CVE DESC: $entryDesc"
                Write-Host " "


                # Set value to false to denote the entry was found.
                $notFound = "false"
                # This reduces memory and file read operations and you get the results faster.
            
            } else {

                #If searching and Name matches, hooray!
                if ($notFound -eq "false") {

                    continue

                } else {
                #if searching and Name matches nothing, variable will be set to trigger alert stating the CVE was not found 
                    $notFound = "true"
                } #close else statement regarding variable $notFound

            } #End check for CVE.

        } #end foreach loop.
    
        if ($notFound -eq "true") {

            #notify user nothing was found
            Write-Host -BackgroundColor Black -ForegroundColor Red "CVE Not Found"

            #hit enter to continue
            hit_enter

            #tell user they will be returning to security admin menu
            Write-Host "Returning to security admin menu" -BackgroundColor Black -ForegroundColor Yellow

            #wait 2 seconds
            sleep 2

            #return to security admin menu
            sec_admin

        } else {

            #ask if user wants to email
            Write-Host "Would you like to email the CSV(s)? [Y] Otherwise hit any button to continue" -BackgroundColor Black -ForegroundColor Yellow
            $email_or_not = Read-Host -Prompt " "
            #evaluate answer
            if ($email_or_not -eq "Y") {

                #ask user for subject
                $email_subject = Read-Host -Prompt "What would you like the subject of the email to be?"

                #ask user for message
                $email_message = Read-Host -Prompt "What would you like the message of the email to be?"

                #add array of info to custom message
                $email_message += $email_attachment

                Send-MailMessage -From "benjamin.fretz@mymail.champlain.edu"-To "mini@miniBuntu" -Subject "$email_subject" -Body [$email_message] -SmtpServer 192.168.1.32  
                
                } #close email option 

            #hit enter to continue
            hit_enter

            #tell user they will be returning to security admin menu
            Write-Host "Returning to security admin menu" -BackgroundColor Black -ForegroundColor Yellow

            #wait 2 seconds
            sleep 2

            #return to security admin menu
            sec_admin

        } #end if statement
                            
     } elseif ($parse_choice -eq "D") {

        #Prompt the user for the specific description they want to search for.
        $inputDescription = Read-Host -Prompt "What description would you like to search with?"  

        #Parse through each line of CSV file
        foreach ($cveEntry in $cve_file) {
            #If there is a positive match.
            if ($cveEntry.Description -ilike "*$inputDescription*") {
                # Print that the CVE was found.
                write-host -BackgroundColor DarkGreen "Found." #State when there is a matching CVE
                # Create variables with the newly acquired information.
                $entryName = $cveEntry.Name
                $entryDesc = $cveEntry.Description
                $entryStatus = $cveEntry.Status
                $entryReferences = $cveEntry.References
                $entryPhase = $cveEntry.Phase

                #Add entry to array
                $email_attachment += $cveEntry

                # Print the vairables so the user can see.
                Write-Host "CVE NAME: $entryName" -BackgroundColor Black -ForegroundColor Yellow
                Write-Host "CVE DESC: $entryDesc"
                Write-Host " "

                # Set value to false to denote the entry was found.
                $notFound = "false"
                # Stops the foreach loop since the file only contains one CVE named "CVE-1999-0001"
                # This reduces memory and file read operations and you get the results faster.
            } else {
         
                #If searching and at least one occurance of keyword is found, there is a match.
                if ($notFound -eq "false") {
                
                    continue #continue searching

                } else {

                    $notFound = "true"
                } #close else statement regarding variable $notFound

            } #end check for CVE
        
        } #end foreach loop

        if ($notFound -eq "true") {
            Write-Host -BackgroundColor Black -ForegroundColor Red "CVE Not Found"

            #hit enter to continue
            hit_enter

            #tell user they will be returning to security admin menu
            Write-Host "Returning to security admin menu" -BackgroundColor Black -ForegroundColor Yellow

            #wait 2 seconds
            sleep 2

            #return to security admin menu
            sec_admin

        } else {

            #ask if user wants to email
            Write-Host "Would you like to email the CVE(s)? [Y] Otherwise press any button to continue" -BackgroundColor Black -ForegroundColor Yellow
            $email_or_not = Read-Host -Prompt " "

            #evaluate answer
            if ($email_or_not -eq "Y") {

                #ask user for subject
                $email_subject = Read-Host -Prompt "What would you like the subject of the email to be?"

                #ask user for message
                $email_message = Read-Host -Prompt "What would you like the message of the email to be?"

                #add array of info to custom message
                $email_message += $email_attachment

                Send-MailMessage -From "benjamin.fretz@mymail.champlain.edu"-To "mini@miniBuntu" -Subject "$email_subject" -Body [$email_message] -SmtpServer 192.168.1.32
                } #close mail option

            #hit enter to continue
            hit_enter

            #tell user they will be returning to security admin menu
            Write-Host "Returning to security admin menu" -BackgroundColor Black -ForegroundColor Yellow

            #wait 2 seconds
            sleep 2

            #return to security admin menu
            sec_admin
        } #end if statement

     } #and Description search   

} #importcsv function

main_menu
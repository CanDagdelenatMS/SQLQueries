$createquery= @”
    IF EXISTS (SELECT 1 FROM SYS.objects WHERE name ='UserRights')
        DROP TABLE UserRights
    CREATE TABLE [UserRights]
    (
    [ComputerName] [varchar](500) NULL,
    [Create_a_token_object] [nvarchar](max) NULL,
    [Replace_a_process_level_token] [nvarchar](max) NULL,
    [Lock_pages_in_memory] [nvarchar](max) NULL,
    [Adjust_memory_quotas_for_a_process] [nvarchar](max) NULL,
    [Not_applicable] [nvarchar](max) NULL,
    [Add_workstations_to_domain] [nvarchar](max) NULL,
    [Act_as_part_of_the_operating_system] [nvarchar](max) NULL,
    [Manage_auditing_and_the_security_log] [nvarchar](max) NULL,
    [Take_ownership_of_files_or_other_objects] [nvarchar](max) NULL,
    [Load_and_unload_device_drivers] [nvarchar](max) NULL,
    [Profile_system_performance] [nvarchar](max) NULL,
    [Change_the_system_time] [nvarchar](max) NULL,
    [Profile_single_process] [nvarchar](max) NULL,
    [Increase_scheduling_priority] [nvarchar](max) NULL,
    [Create_a_pagefile] [nvarchar](max) NULL,
    [Create_permanent_shared_objects] [nvarchar](max) NULL,
    [Back_up_files_and_directories] [nvarchar](max) NULL,
    [Restore_files_and_directories] [nvarchar](max) NULL,
    [Shut_down_the_system] [nvarchar](max) NULL,
    [Debug_programs] [nvarchar](max) NULL,
    [Generate_security_audits] [nvarchar](max) NULL,
    [Modify_firmware_environment_values] [nvarchar](max) NULL,
    [Bypass_traverse_checking] [nvarchar](max) NULL,
    [Force_shutdown_from_a_remote_system] [nvarchar](max) NULL,
    [Remove_computer_from_docking_station] [nvarchar](max) NULL,
    [Synchronize_directory_service_data] [nvarchar](max) NULL,
    [Enable_computer_and_user_accounts_to_be_trusted_for_delegation] [nvarchar](max) NULL,
    [Manage_the_files_on_a_volume] [nvarchar](max) NULL,
    [Impersonate_a_client_after_authentication] [nvarchar](max) NULL,
    [Create_global_objects] [nvarchar](max) NULL,
    [Access_Credential_Manager_as_a_trusted_caller] [nvarchar](max) NULL,
    [Modify_an_object_label] [nvarchar](max) NULL,
    [Increase_a_process_working_set] [nvarchar](max) NULL,
    [Change_the_time_zone] [nvarchar](max) NULL,
    [Create_symbolic_links] [nvarchar](max) NULL,
	[LogDate] [smalldatetime] NULL
    ) 
    ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
"@

$dbname= "tester"
$servername="node1"
Invoke-Sqlcmd -ServerInstance $servername -Database $dbname -Query $createquery
--	last backup 
select server_name, database_name, last_backup
from database_configuration_production_group
where 
database_name <> 'tempdb' and (
	convert(date, getdate() - 30, 103) > convert(date, last_backup, 103)
	or last_backup is null
	)
and convert(date, capture_date, 103) = convert(date, getdate(), 103)



-- data or log percent growth 
select server_name, database_name, rows_total_size_gb, [rows_p_growth], log_total_size_gb, [log_p_growth]
from database_configuration_production_group
where (
	[rows_p_growth] = 1 or [log_p_growth] = 1
)
and convert(date, capture_date, 103) = convert(date, getdate(), 103)



-- page_verify <> CHECKSUM
select server_name, database_name, page_verify_option 
from database_configuration_production_group
where page_verify_option <> 'CHECKSUM'
and convert(date, capture_date, 103) = convert(date, getdate(), 103)



-- db_owner <> sa
select server_name, database_name, owner_sid, sysuser_loginname
from database_configuration_production_group
where sysuser_loginname <> 'sa'
and convert(date, capture_date, 103) = convert(date, getdate(), 103)



-- database set to offline
select server_name, database_name, state 
from database_configuration_production_group
where state <> 'ONLINE'
and convert(date, capture_date, 103) = convert(date, getdate(), 103)



-- auto update stats
select server_name, database_name, is_auto_create_stats_on, is_auto_update_stats_on
from database_configuration_production_group
where (
	(is_auto_create_stats_on = 0 or is_auto_update_stats_on = 0) and
	server_name <> 'SOME-SHAREPOINT-SERVER'
)
and convert(date, capture_date, 103) = convert(date, getdate(), 103)



-- is auto shrink on
select server_name, database_name from database_configuration_production_group
where is_auto_shrink_on = 1



-- recovery model = FULL or BULK_LOGGED
select server_name, database_name, recovery_model, rows_total_size_gb, log_total_size_gb
from database_configuration_production_group
where recovery_model <> 'SIMPLE' 
and convert(date, capture_date, 103) = convert(date, getdate(), 103)




/*
--adhoc randomness
select * from database_configuration_production_group where server_name = ''

delete from database_configuration_production_group
where convert(date, capture_date, 103) = convert(date, getdate(), 103)
*/

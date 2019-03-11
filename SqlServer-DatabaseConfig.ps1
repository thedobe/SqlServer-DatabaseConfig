#Find-Module -Name SqlServer | Install-Module -AllowClobber

Import-Module SqlServer 

$dba_main = 'SERVER-CONTAINING-THE-CMS'

Invoke-Sqlcmd -ServerInstance $dba_main -Database 'DBA' -Query 'exec [dbo].[usp_database_configuration_create_tables]'

$fetch_rs = Invoke-Sqlcmd -ServerInstance $dba_main -Database 'DBA' -Query 'exec [dbo].[usp_fetch_production_registered_servers]'

foreach ($rs in $fetch_rs) { 
    
    $sqlcon = 'SQLSERVER:\SQL\' + $rs.server_name + '\' + $rs.instance_name + ''
    
    $sqlserver = Get-Item $sqlcon

    $fetch_db_config = '
    insert into [linked_server_here]..[database_configuration_production_group] (
        capture_date, server_name, [database_name], last_backup,
	    ROWS_total_size_gb, ROWS_files, ROWS_p_growth, LOG_total_size_gb, LOG_p_growth,
	    owner_sid, sysuser_loginname,
	    [compatibility_level],
	    collation_name,
	    user_access,
	    recovery_model,
	    is_auto_shrink_on, [state],
	    snapshot_isolation_state, is_read_committed_snapshot_on,
	    page_verify_option,
	    is_auto_create_stats_on,is_auto_update_stats_on,
	    is_encrypted
    )
	select 
		getdate() as [capture_date],
        ''' + $sqlServer.Name + ''' as [server_name],
		d.[name] as [database_name], 
		max(bs.backup_finish_date) as [last_backup],
		sum(r.size * 8 / 1024 / 1024) as [ROWS_total_size_gb], 
		max(rc.c) as [ROWS_files],
		max(cast(r.is_percent_growth as tinyint)) as [ROWS_p_growth],
		max(((l.size * 8) / 1024) / 1024) as [LOG_total_size_db], 
		max(cast(l.is_percent_growth as tinyint)) as [LOG_p_growth],
		max(d.owner_sid) as [owner_sid],
		max(sl.loginname) as [sysuser_loginname],
		max(d.compatibility_level) as [compatibility_level],
		max(d.collation_name) as [collation_name],
		max(d.user_access_desc) as [user_access],
		max(d.recovery_model_desc) as [recovery_model],
		max(cast(d.is_auto_shrink_on as tinyint)) as [is_auto_shrink_on],
		max(d.state_desc) as [state],
		max(d.snapshot_isolation_state) as [snapshot_isolation_state],
		max(cast(d.is_read_committed_snapshot_on as tinyint)) as [is_read_committed_snapshot_on],
		max(d.page_verify_option_desc) as [page_verify_option],
		max(cast(d.is_auto_create_stats_on as tinyint)) as [is_auto_create_stats_on],
		max(cast(d.is_auto_update_stats_on as tinyint)) as [is_auto_update_stats_on],
		max(cast(d.is_encrypted as tinyint)) as [is_encrypted]
	from sys.databases d
	inner join (select database_id, size, is_percent_growth from sys.master_files where type_desc = ''ROWS'') r on r.database_id=d.database_id
	inner join (select database_id, count(*) as c from sys.master_files where type_desc = ''ROWS'' group by database_id) rc on rc.database_id=d.database_id
	inner join (select database_id, size, is_percent_growth from sys.master_files where type_desc = ''LOG'') l on l.database_id=d.database_id
	left join (select database_name, max(backup_finish_date) as backup_finish_date from msdb.dbo.backupmediafamily bm inner join msdb.dbo.backupset bs ON bs.media_set_id = bm.media_set_id group by bs.database_name) bs on bs.database_name=d.name
	left join sys.syslogins sl on sl.[sid]=d.owner_sid
	group by d.name
	order by d.name
    '
    Invoke-SqlCmd -ServerInstance $sqlServer.Name -Database 'master' -Query $fetch_db_config
}

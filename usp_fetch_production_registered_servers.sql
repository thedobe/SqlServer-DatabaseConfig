USE [DATABASE_HERE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_fetch_production_registered_servers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here	
	if object_id('tempdb..#production_registered_servers') is not null
		begin
			drop table #production_registered_servers
		end

	create table #production_registered_servers (
		[server_name] sysname,
		[instance_name] sysname
	)

	insert into #production_registered_servers
	select
			case 
				when s.server_name like '%\%' then substring(s.server_name, 0, charindex('\', s.server_name))
				else s.server_name
			end as server_name,
			case
				when s.server_name like '%\%' then substring(s.server_name, charindex('\', s.server_name) + 1, len(s.server_name))
				else 'DEFAULT'
			end as instance_name
		from msdb.dbo.sysmanagement_shared_server_groups_internal g
		inner join msdb.dbo.sysmanagement_shared_registered_servers_internal s on  s.server_group_id = g.server_group_id
		where
		g.parent_id in (select server_group_id from msdb.dbo.sysmanagement_shared_server_groups_internal where [name] = 'Production') 
		--and server_name in ('ISOLATE-SERVER-HERE-IF-NEEDED')

		select server_name, instance_name from #production_registered_servers
	return	
END

USE []
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
ALTER PROCEDURE [dbo].[usp_database_configuration_create_tables]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	if not exists (select [name] from sys.tables where [name] = 'database_configuration_production_group')
		create TABLE [dbo].[database_configuration_production_group] (
			[id] [int] identity(1,1) NOT NULL,
			[capture_date] [datetime] default getdate() NOT NULL,
			[server_name] [sysname] NULL,
			[database_name] [sysname] NULL,
			[last_backup] [datetime] NULL,
			[ROWS_total_size_gb] [int] NULL,
			[ROWS_files] [int] NULL,
			[ROWS_p_growth] [tinyint] NULL,
			[LOG_total_size_gb] [int] NULL,
			[LOG_p_growth] [tinyint] NULL,
			[owner_sid] [varbinary](256) NULL,
			[sysuser_loginname] [sysname] NULL,
			[compatibility_level] [tinyint] NULL,
			[collation_name] [sysname] NULL,
			[user_access] [varchar](60) NULL,
			[recovery_model] [varchar](60) NULL,
			[is_auto_shrink_on] [tinyint] NULL,
			[state] [varchar](60) NULL,
			[snapshot_isolation_state] [tinyint] NULL,
			[is_read_committed_snapshot_on] [tinyint] NULL,
			[page_verify_option] [varchar](60) NULL,
			[is_auto_create_stats_on] [tinyint] NULL,
			[is_auto_update_stats_on] [tinyint] NULL,
			[is_encrypted] [tinyint] NULL
			primary key clustered ([id] asc) 
	)
END

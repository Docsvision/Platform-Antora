

-- Create and fill outer DB

--БД для журналов
declare @ret int; 
exec @ret = dbo.dvsys_create_dependent_database @db_name_suffix =  N'Log', @DBFilePath = null, @DBLogPath = null, @DBInMemoryPath = null, @useInMemory = 1, @AddFileGroup = N'Logs';

--Delimiter
GO

----------------------------------------------------------------
-- Create log tables
----------------------------------------------------------------
declare @exec_str nvarchar(max);
set @exec_str = N'use [' + db_name() + N'_Log];
IF OBJECT_ID (''dvsys_log'') IS NULL
CREATE TABLE [dbo].[dvsys_log](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[EmployeeID] [uniqueidentifier] NULL,
	[ComputerName] [varchar](32) NULL,
	[ComputerAddress] [char](15) NULL,
	[Date] [datetime] NOT NULL,
	[Type] [int] NOT NULL,
	[OperationID] [uniqueidentifier] NOT NULL,
	[Code] [int] NOT NULL,
	[TypeID] [uniqueidentifier] NULL,
	[ResourceID] [uniqueidentifier] NULL,
	[ParentID] [uniqueidentifier] NULL,
	[NewResourceID] [uniqueidentifier] NULL,
	[ResourceName] [nvarchar](1024) NULL,
	[Data] [nvarchar](max) NULL,
	CONSTRAINT [dvsys_log_pk_id_date] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Logs]
) ON [Logs] TEXTIMAGE_ON [Logs]

IF OBJECT_ID (''dvsys_log_backup'') IS NULL
CREATE TABLE [dbo].[dvsys_log_backup](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[EmployeeID] [uniqueidentifier] NULL,
	[ComputerName] [varchar](32) NULL,
	[ComputerAddress] [char](15) NULL,
	[Date] [datetime] NOT NULL,
	[Type] [int] NOT NULL,
	[OperationID] [uniqueidentifier] NOT NULL,
	[Code] [int] NOT NULL,
	[TypeID] [uniqueidentifier] NULL,
	[ResourceID] [uniqueidentifier] NULL,
	[ParentID] [uniqueidentifier] NULL,
	[NewResourceID] [uniqueidentifier] NULL,
	[ResourceName] [nvarchar](1024) NULL,
	[Data] [nvarchar](max) NULL,
	CONSTRAINT [dvsys_log_backup_pk_id_date] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Logs]
) ON [Logs] TEXTIMAGE_ON [Logs]

IF OBJECT_ID (''dvsys_log_security'') IS NULL
CREATE TABLE [dbo].[dvsys_log_security](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [uniqueidentifier] NULL,
	[EmployeeID] [uniqueidentifier] NULL,
	[ComputerName] [varchar](32) NULL,
	[ComputerAddress] [char](15) NULL,
	[Date] [datetime] NOT NULL,
	[OperationID] [uniqueidentifier] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[DesiredAccess] [int] NOT NULL,
	[ObjectType] [tinyint] NOT NULL,
	[ObjectID] [uniqueidentifier] NOT NULL,
	[LocationID] [uniqueidentifier] NULL,
	[PropertyID] [uniqueidentifier] NULL,
	[Data] [nvarchar](max) NULL,
	CONSTRAINT [dvsys_log_security_pk_id_date] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Logs]
) ON [Logs] TEXTIMAGE_ON [Logs]

IF OBJECT_ID (''dvsys_log_security_backup'') IS NULL
CREATE TABLE [dbo].[dvsys_log_security_backup](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [uniqueidentifier] NULL,
	[EmployeeID] [uniqueidentifier] NULL,
	[ComputerName] [varchar](32) NULL,
	[ComputerAddress] [char](15) NULL,
	[Date] [datetime] NOT NULL,
	[OperationID] [uniqueidentifier] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[DesiredAccess] [int] NOT NULL,
	[ObjectType] [tinyint] NOT NULL,
	[ObjectID] [uniqueidentifier] NOT NULL,
	[LocationID] [uniqueidentifier] NULL,
	[PropertyID] [uniqueidentifier] NULL,
	[Data] [nvarchar](max) NULL,
	CONSTRAINT [dvsys_log_security_backup_pk_id_date] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Logs]
) ON [Logs] TEXTIMAGE_ON [Logs]'

exec sp_executesql @exec_str;

--Delimiter
GO


-- update main base

-- Set flag in main base
declare @paramVal bit, @paramName nvarchar(128);
select @paramVal = 1, @paramName = N'UseOuterLog';
update [dbo].[dvsys_settings] set [Value] = @paramVal Where [Name] = @paramName;
if @@rowcount = 0 insert [dbo].[dvsys_settings] ([Value], Name) values (@paramVal, @paramName);

--Delimiter
GO

-- rename old tables
EXEC sp_rename 'dvsys_log', 'dvsys_log_local_table'
GO 
EXEC sp_rename 'dvsys_log_backup', 'dvsys_log_backup_local_table'
GO 
EXEC sp_rename 'dvsys_log_security', 'dvsys_log_security_local_table'
GO 
EXEC sp_rename 'dvsys_log_security_backup', 'dvsys_log_security_backup_local_table'
GO

-- create synonyms
declare @exec_str nvarchar(max);
set @exec_str = N'
CREATE SYNONYM [dbo].[dvsys_log] FOR [' + db_name() + N'_Log].[dbo].[dvsys_log]

CREATE SYNONYM [dbo].[dvsys_log_backup] FOR [' + db_name() + N'_Log].[dbo].[dvsys_log_backup]

CREATE SYNONYM [dbo].[dvsys_log_security] FOR [' + db_name() + N'_Log].[dbo].[dvsys_log_security]

CREATE SYNONYM [dbo].[dvsys_log_security_backup] FOR [' + db_name() + N'_Log].[dbo].[dvsys_log_security_backup]'

exec sp_executesql @exec_str;
go


ALTER procedure [dbo].[dvsys_log_refine_ex] 
(
    @LogType tinyint = null,
    @Strategy int = null,
    @CutDays int = null,
    @CutCount int = null,
    @BackupDb nvarchar(255) = null,
    @dbts bigint = null output
)
as
----------------
set nocount on;
set transaction isolation level read uncommitted;
--set @dbts = @@dbts;
----------------

	-- @LogType		tinyint
	-- @Strategy	int
	-- @CutDays		int
	-- @CutCount	int
	-- @BackupDb	nvarchar(255)
	declare @exec_str nvarchar(max), @UseOuterDB nvarchar(255), @DB nvarchar(255), @DBSuffix sysname;
	select @UseOuterDB = N'', @DB = N'', @DBSuffix = N'';
	if @LogType in (0, 1)
		select @DBSuffix = N'Log', @UseOuterDB = N'use [' + db_name() + N'_' + @DBSuffix + N'];', @DB = N'[' + db_name() + N'].';
	set @exec_str = convert(nvarchar(max), @UseOuterDB + N'
    declare @Cmd nvarchar(4000), @LogName nvarchar(16), @LogTable nvarchar(128), @LogBackupTable nvarchar(128), @LogPartitionScheme nvarchar(128), @LogPartitionFunction nvarchar(128);
    -- Load object names
    select	@LogName = [Name], @LogTable = [Table], @LogBackupTable = [BackupTable], @LogPartitionScheme = [PartitionScheme], @LogPartitionFunction = [PartitionFunction]
    from	' + @DB + N'[dbo].[dvfn_log_get_info](@LogType);
    if @@rowcount = 0
    begin
        raiserror(N''Invalid LogType value:''''%d''''.'', 11, 1, @LogType);
        return;
    end') + convert(nvarchar(max), N'
    declare @EdgeDate datetime;
    if not exists ( select top 1 t.[object_id] from	sys.tables t inner join sys.partition_schemes p on t.lob_data_space_id = p.data_space_id and t.[object_id] = object_id(@LogTable))
	begin --log table has no partitions
		if @Strategy = 0 /*Never clear log*/ return;
		if @Strategy = 2 /*Clear by date*/
			set @EdgeDate = dateadd(day, -@CutDays, getdate());
		else                -- Clear log by count
		begin
			set @Cmd = N''declare @RowSum int, @RowCount int, @BaseDate datetime;
declare DateCursor cursor fast_forward for
select convert(datetime, convert(date, [Date])) as [BaseDate], count([Date]) [RowCount]
from dbo.['' + @LogTable + N''] with(nolock)
group by convert(datetime, convert(date, [Date]))
order by [BaseDate] desc;') + convert(nvarchar(max), N'
--
select @RowSum = 0, @EdgeDate = convert(datetime, convert(date, getdate()));
-- Iterate through cursor data until "cut count" value would be reached and get edge date
open DateCursor;
fetch next from DateCursor into @BaseDate, @RowCount;

while (@@fetch_status = 0 and @CutCount > @RowSum)
begin
	select	@RowSum = @RowSum + @RowCount, @EdgeDate = @BaseDate;
	fetch next from DateCursor into @BaseDate, @RowCount;
end
close DateCursor;
deallocate DateCursor;'';') + convert(nvarchar(max), N'
			-- Compute edge date using required number of records in log table
			exec dbo.sp_executesql @Cmd, N''@CutCount int, @EdgeDate datetime output'', @CutCount, @EdgeDate output; 
		end
		--------------------------------------------------------------------------------------
		-- Backup and remove data from log table
		--------------------------------------------------------------------------------------
		-- Backup log data
		declare @LeftBound datetime, @RightBound datetime, @MinDate datetime, @Query nvarchar(4000);
		select @LeftBound = dateadd(day, -1, @EdgeDate), @RightBound = @EdgeDate;
		set @Cmd = N''select top 1 @MinDate = [Date] from dbo.['' + @LogTable + N''] with(nolock) order by [Date] asc '';
		-- Fetch min date value in log table
		exec dbo.sp_executesql @Cmd, N''@MinDate datetime output'', @MinDate output;
		set @MinDate = convert(datetime, convert(varchar(10), @MinDate, 120) , 120);
		-- Export log data in one file per day') + convert(nvarchar(max), N'
		while (@RightBound > @MinDate)
		begin
			set @Query =  N''[Date] between CONVERT(datetime, '''''' + convert(nvarchar(30), @LeftBound, 121) + N'''''', 121) and CONVERT(datetime, '''''' + convert(nvarchar(30), @RightBound, 121) + N'''''', 121) '';
			-- Backup old log messages to LogDB
			select @Cmd = ' + @DB + N'[dbo].[dvfn_log_get_backup_command_ex](@BackupDB, @LogType, @LogTable, @Query, ''' + @DBSuffix + N''');
			exec dbo.sp_executesql @Cmd;
			-- Compute next date range
			select @RightBound = @LeftBound, @LeftBound = dateadd(day, -1, @LeftBound);
		end
') + convert(nvarchar(max), N'
		-- Remove old data from log
		set @Cmd = 	N''while exists (select * from dbo.['' + @LogTable+ N''] tLog with(nolock) where tLog.[Date] < @EdgeDate)
	delete	top(100000) tLog from	dbo.['' + @LogTable+ N''] tLog with(paglock) where	tLog.[Date] < @EdgeDate;'';
		exec dbo.sp_executesql @Cmd, N''@EdgeDate datetime'', @EdgeDate;	
	end
	else 
	begin --log table has partitions
		declare @TruncateCmd nvarchar(4000), @MoveDataCmd nvarchar(4000), @MergePartitionCmd nvarchar(4000), @BoundaryCount int, @MinBoundary datetime, @next_Day_count int;
		set @next_Day_count = 10;
		--------------------------------------------------------------------------------------	    
		set @TruncateCmd = N''truncate table dbo.['' + @LogBackupTable + N''];'';
		set @MoveDataCmd = N''alter table dbo.['' + @LogTable + N''] switch partition $partition.['' + @LogPartitionFunction + N''](@Boundary) to dbo.['' + @LogBackupTable+ N''] '';
		set @MergePartitionCmd = N''alter partition function ['' + @LogPartitionFunction + N'']() merge range (@Boundary)'';
		--------------------------------------------------------------------------------------
		-- Create new log partition (ALWAYS)') + convert(nvarchar(max), N'
		--------------------------------------------------------------------------------------	    
		set @Cmd = N''declare @function_id int, @boundary_id int, @boundary_value datetime;
set @boundary_value = convert(datetime, convert(varchar(10), getdate(), 120), 120);
select @function_id = [function_id] from sys.[partition_functions] where [name] = '''''' + @LogPartitionFunction + N''''''
while @boundary_value < dateadd(d, '' + convert(nvarchar(10), @next_Day_count) + N'', getdate())
begin
	if not exists (select top 1 * from sys.[partition_range_values] where	[function_id] = @function_id and [value] = @boundary_value)
	begin
		declare @lastPart sysname, @exec_str nvarchar(max);

		select top 1 @lastPart = fg.name 
		from	sys.partition_schemes part
				inner join sys.destination_data_spaces dest
					on part.data_space_id = dest.partition_scheme_id
					and part.name = '''''' + @LogPartitionScheme + N''''''
				inner join sys.filegroups fg
					on dest.data_space_id = fg.data_space_id
		order by dest.destination_id desc;

		set @exec_str = N''''alter partition scheme ['' + @LogPartitionScheme + N''] next used ['''' + @lastPart + N'''']'''';
		exec sp_executesql @exec_str;
		alter partition function ['' + @LogPartitionFunction + N'']() split range (@boundary_value);
	end
	set @boundary_value = dateadd(d, 1, @boundary_value);
end;'';') + convert(nvarchar(max), N'
		--------------------------------------------------------------------------------------
		-- Check log partitions number (ALWAYS)
		--------------------------------------------------------------------------------------
		select @BoundaryCount = count(*) ,@MinBoundary = min(cast(Ranges.[value] as datetime)) from	sys.partition_functions Func INNER join sys.partition_range_values Ranges on (Ranges.[function_id] = Func.[function_id] and Func.[Name] = @LogPartitionFunction);
		-- Merge last boundary if max number of boundaries reached
		while @BoundaryCount > 998 - @next_Day_count
		begin
			exec dbo.sp_executesql @MergePartitionCmd, N''@Boundary datetime'', @MinBoundary;    
			select @BoundaryCount = count(*) ,@MinBoundary = min(cast(Ranges.[value] as datetime)) from	sys.partition_functions Func INNER join sys.partition_range_values Ranges on (Ranges.[function_id] = Func.[function_id] and Func.[Name] = @LogPartitionFunction);
		end;
		--------------------------------------------------------------------------------------
		-- Create new log partition to today and next 10 days (ALWAYS)
		exec dbo.sp_executesql @Cmd;') + convert(nvarchar(max), N'
		--------------------------------------------------------------------------------------
		if @Strategy <> 0 
		begin
			--------------------------------------------------------------------------------------
			-- Compute edge date value (messages older than that date would be unloaded)
			--------------------------------------------------------------------------------------		  
			if @Strategy = 2 /*Clear by date*/
				set @EdgeDate = dateadd(day, -@CutDays, getdate());
			else /*Clear log by count*/
			begin
				set @Cmd = N''declare @RowSum int, @RowCount int, @Partition int, @MinDate datetime;
-- Fetch number of rows in each partition') + convert(nvarchar(max), N'
declare PartitionCursor cursor fast_forward for
select $partition.'' + @LogPartitionFunction + N''([Date]) [Partition], count([Date]) [RowCount], min([Date]) [MinDate]
from dbo.['' + @LogTable + N''] with(nolock) group by $partition.'' + @LogPartitionFunction + N''([Date]) order by [MinDate] desc;
select @RowSum = 0, @EdgeDate = convert(date, getdate());
-- Iterate through partition data until "cut count" value would be reached and get edge date
open PartitionCursor;
fetch next from PartitionCursor into @Partition, @RowCount, @MinDate;
while (@@fetch_status = 0 and @CutCount > @RowSum)
begin
   select @RowSum = @RowSum + @RowCount, @EdgeDate = @MinDate;
   fetch next from PartitionCursor into @Partition, @RowCount, @MinDate;
end
close PartitionCursor;
deallocate PartitionCursor;'';') + convert(nvarchar(max), N'
				-- Compute edge date using required number of records in log table
				exec dbo.sp_executesql @Cmd, N''@CutCount int, @EdgeDate datetime output'', @CutCount, @EdgeDate output; 
			end
			--------------------------------------------------------------------------------------
			-- Unload data from log table and backup it
			--------------------------------------------------------------------------------------
			-- Fetch boundaries for backup from partition function
			declare @Boundary datetime;
			declare BoundaryCursor cursor fast_forward for
			select	cast(Ranges.[value] as datetime) [Boundary]
			from	sys.partition_functions Func
					inner join sys.partition_range_values Ranges
						on Ranges.[function_id] = Func.[function_id] and Func.Name = @LogPartitionFunction and Ranges.[value] < @EdgeDate
			order by [Boundary] asc;

			open BoundaryCursor;') + convert(nvarchar(max), N'
			fetch next from BoundaryCursor into @Boundary;
			-- Process partitions
			while (@@fetch_status = 0)
			begin
				-- Backup old log messages to LogDB (if PROCESS WAS STOPPED)
				select @Cmd = ' + @DB + N'[dbo].[dvfn_log_get_backup_command_ex](@BackupDB, @LogType, @LogBackupTable, N'''', ''' + @DBSuffix + N''');
				exec dbo.sp_executesql @Cmd;
				-- Clear backup table
				exec dbo.sp_executesql @TruncateCmd;
				-- Move log data to backup
				exec dbo.sp_executesql @MoveDataCmd, N''@Boundary datetime'', @Boundary;
				-- Merge empty partition
				exec dbo.sp_executesql @MergePartitionCmd, N''@Boundary datetime'', @Boundary;
				fetch next from BoundaryCursor into @Boundary;
			end') + convert(nvarchar(max), N'
			-- Backup old log messages (LAST partition) to LogDB
			select @Cmd = ' + @DB + N'[dbo].[dvfn_log_get_backup_command_ex](@BackupDB, @LogType, @LogBackupTable, N'''', ''' + @DBSuffix + N''');
			exec dbo.sp_executesql @Cmd;
			close BoundaryCursor;
			deallocate BoundaryCursor;			
		end		
	end') + convert(nvarchar(max), N'
	-- check whether to del old records in logdb table
	declare @LogDbPreservDays int = isnull(convert(int, ' + @DB + N'[dbo].[dvfn_setting_get_setting](N''LogDatabasePreservDays'')), 0)
	if @LogDbPreservDays > 0
	begin
		declare @LogDbEdgeDate datetime = dateadd(d, -@LogDbPreservDays, getdate())
		declare @LogDbPurgeScript nvarchar(2000) = N''while exists (select * from '' + @BackupDB + N''.dbo.['' + @LogTable + N''] tLog with(nolock) where tLog.[Date] < @EdgeDate)
	delete	top(100000) tLog from '' + @BackupDB + N''.dbo.['' + @LogTable + N''] tLog with(paglock) where	tLog.[Date] < @EdgeDate;'';
		exec dbo.sp_executesql @LogDbPurgeScript, N''@EdgeDate datetime'', @LogDbEdgeDate;
	end');
	exec dbo.sp_executesql @exec_str, N'@LogType tinyint, @Strategy	int, @CutDays int, @CutCount int, @BackupDb	nvarchar(255)', @LogType = @LogType, @Strategy	= @Strategy, @CutDays = @CutDays, @CutCount = @CutCount, @BackupDb = @BackupDb;
	-- Write Clear log message with LocalSystem user
	-- To do:
	--		1. Check if operation was disabled
	--      2. Write additional info about deleted messages
	exec [dbo].[dvsys_log_write_message] '{11111111-1111-0001-1111-000000000000}', '{00000000-0000-0000-0000-000000000000}', null, null, 2, '{BBBBBBBB-BBBB-0047-BBBB-000000000000}', 0;
	
----------------
set @dbts = @@dbts;
----------------
GO

ALTER procedure [dbo].[dvsys_log_refine] 
(
    @LogType tinyint = null,
    @Strategy int = null,
    @CutDays int = null,
    @CutCount int = null,
    @BackupDir nvarchar(255) = null,
    @dbts bigint = null output
)
as
----------------
set nocount on;
set transaction isolation level read uncommitted;
--set @dbts = @@dbts;
----------------

	--  @LogType   tinyint
	-- , @Strategy  int
	-- , @CutDays   int
	-- , @CutCount  int
	-- , @BackupDir nvarchar(255)
	declare @exec_str nvarchar(max), @UseOuterDB nvarchar(255), @DB nvarchar(255), @DBSuffix sysname;
	select @UseOuterDB = N'', @DB = N'', @DBSuffix = N'';
	if @LogType in (0, 1)
		select @DBSuffix = N'Log', @UseOuterDB = N'use [' + db_name() + N'_' + @DBSuffix + N'];', @DB = N'[' + db_name() + N'].';
	set @exec_str = convert(nvarchar(max), @UseOuterDB + N'
    declare @Cmd nvarchar(4000), @LogName nvarchar(16), @LogTable nvarchar(128), @LogBackupTable nvarchar(128), @LogPartitionScheme nvarchar(128), @LogPartitionFunction nvarchar(128), @db_name sysname;
    -- Load object names
    select @LogName = [Name], @LogTable = [Table], @LogBackupTable = BackupTable, @LogPartitionScheme = PartitionScheme, @LogPartitionFunction = PartitionFunction
    from ' + @DB + N'[dbo].[dvfn_log_get_info](@LogType);
    if @@rowcount = 0
    begin
        raiserror(N''Invalid LogType value:''''%d''''.'', 11, 1, @LogType); return;
    end') + convert(nvarchar(max), N'
    declare @EdgeDate datetime;
    if not exists (	select top 1 t.[object_id] from	sys.tables t inner join sys.partition_schemes p on t.lob_data_space_id = p.data_space_id and t.[object_id] = object_id(@LogTable))
	begin --log table has no partitions
		if @Strategy = 0 /*Never clear log*/ return;
		if @Strategy = 2    -- Clear by date
			set @EdgeDate = dateadd(day, -@CutDays, getdate());
		else                -- Clear log by count
		begin
			set @Cmd = N''declare @RowSum int, @RowCount int, @BaseDate datetime;
declare DateCursor cursor fast_forward for
select convert(date, [Date]) [BaseDate], count([Date]) [RowCount] from dbo.['' + @LogTable + N''] with(nolock) group by convert(date, [Date]) order by [BaseDate] desc;
select @RowSum = 0, @EdgeDate = convert(date, getdate());
-- Iterate through cursor data until "cut count" value would be reached and get edge date
open DateCursor;
fetch next from DateCursor into @BaseDate, @RowCount;
while (@@fetch_status = 0 and @CutCount > @RowSum)
begin
    select @RowSum = @RowSum + @RowCount, @EdgeDate = @BaseDate;
    fetch next from DateCursor into @BaseDate, @RowCount
end') + convert(nvarchar(max), N'
close DateCursor;
deallocate DateCursor;'';
			-- Compute edge date using required number of records in log table
			exec dbo.sp_executesql @Cmd, N''@CutCount int, @EdgeDate datetime output'', @CutCount, @EdgeDate output; 
		end
		--------------------------------------------------------------------------------------
		-- Backup and remove data from log table
		--------------------------------------------------------------------------------------
		-- Backup log data') + convert(nvarchar(max), N'
		if len(isnull(@BackupDir, N'''')) > 0
		begin
			declare @LeftBound datetime, @RightBound datetime, @MinDate datetime, @Query nvarchar(4000);
			select @LeftBound = dateadd(day, -1, @EdgeDate), @RightBound = @EdgeDate;
			set @Cmd = N''select top 1 @MinDate = [Date] from dbo.['' + @LogTable + N''] with(nolock) order by [Date] asc '';
			-- Fetch min date value in log table
			exec dbo.sp_executesql @Cmd, N''@MinDate datetime output'', @MinDate output;
			set @MinDate = convert(datetime, convert(varchar(10), @MinDate, 120) , 120);
			-- Export log data in one file per day
			while (@RightBound > @MinDate)
			begin
				set @Query =  N''select * from ['' + db_name() + N''].dbo.['' + @LogTable + N''] with(nolock) where [Date] between '''''' + convert(nvarchar(30), @LeftBound, 121) + N'''''' and '''''' + convert(nvarchar(30), @RightBound, 121) + N''''''order by [Date] asc '';
				-- Backup log data to file
				select @Cmd = ' + @DB + N'[dbo].[dvfn_log_get_backup_command](@BackupDir, 1, @Query, @LogName, @LeftBound, ''' + @DBSuffix + N''');
				exec master..xp_cmdshell @Cmd, no_output;
				-- Compute next date range
				set @RightBound = @LeftBound;
				set @LeftBound = dateadd(day, -1, @LeftBound);
			end
		end') + convert(nvarchar(max), N'
		-- Remove old data from log
		set @Cmd = 	N''while exists (select * from dbo.['' + @LogTable+ N''] tLog with(nolock) where tLog.[Date] < @EdgeDate)
	delete	top(100000) tLog from dbo.['' + @LogTable+ N''] tLog with(paglock) where	tLog.[Date] < @EdgeDate;'';
		exec dbo.sp_executesql @Cmd, N''@EdgeDate datetime'', @EdgeDate;	
	end
	else 
	begin --log table has partitions
		declare @TruncateCmd nvarchar(4000), @MoveDataCmd nvarchar(4000), @MergePartitionCmd nvarchar(4000), @BoundaryCount int, @MinBoundary datetime, @next_Day_count int;
		set @next_Day_count = 10;
		--------------------------------------------------------------------------------------	    
		select	@TruncateCmd = N''truncate table dbo.['' + @LogBackupTable + N'']; ''
				, @MoveDataCmd = N''alter table dbo.['' + @LogTable + N''] switch partition $partition.['' + @LogPartitionFunction + N''](@Boundary) to dbo.['' + @LogBackupTable+ N'']''
				, @MergePartitionCmd = N''alter partition function ['' + @LogPartitionFunction + N'']() merge range (@Boundary) ''
				, @Cmd = N''declare @function_id int, @boundary_id int, @boundary_value datetime;') + convert(nvarchar(max), N'
set @boundary_value = convert(datetime, convert(varchar(10), getdate(), 120), 120);
select @function_id = [function_id] from sys.[partition_functions] where [name] = '''''' + @LogPartitionFunction + N''''''
while @boundary_value < dateadd(d, '' + convert(nvarchar(10), @next_Day_count) + N'', getdate())
begin
	if not exists (select top 1 * from sys.[partition_range_values] where	[function_id] = @function_id and [value] = @boundary_value)
	begin
		declare @lastPart sysname, @exec_str nvarchar(max);

		select top 1 @lastPart = fg.name 
		from	sys.partition_schemes part
				inner join sys.destination_data_spaces dest
					on part.data_space_id = dest.partition_scheme_id
					and part.name = '''''' + @LogPartitionScheme + N''''''
				inner join sys.filegroups fg
					on dest.data_space_id = fg.data_space_id
		order by dest.destination_id desc;

		set @exec_str = N''''alter partition scheme ['' + @LogPartitionScheme + N''] next used ['''' + @lastPart + N'''']'''';
		exec sp_executesql @exec_str;

		alter partition function ['' + @LogPartitionFunction + N'']() split range (@boundary_value);
	end
	set @boundary_value = dateadd(d, 1, @boundary_value);
end;'';') + convert(nvarchar(max), N'
		--------------------------------------------------------------------------------------
		-- Check log partitions number (ALWAYS)
		--------------------------------------------------------------------------------------
		select @BoundaryCount = count(*) ,@MinBoundary = min(cast(Ranges.[value] as datetime)) from	sys.partition_functions Func INNER join sys.partition_range_values Ranges on (Ranges.[function_id] = Func.[function_id] and Func.Name = @LogPartitionFunction);
		-- Merge last boundary if max number of boundaries reached
		while @BoundaryCount > 998 - @next_Day_count
		begin
			exec dbo.sp_executesql @MergePartitionCmd, N''@Boundary datetime'', @MinBoundary;    
			select @BoundaryCount = count(*) ,@MinBoundary = min(cast(Ranges.[value] as datetime)) from	sys.partition_functions Func INNER join sys.partition_range_values Ranges on (Ranges.[function_id] = Func.[function_id] and Func.Name = @LogPartitionFunction);
		end;
		--------------------------------------------------------------------------------------
		-- Create new log partition to today and next 10 days (ALWAYS)
		exec dbo.sp_executesql @Cmd;') + convert(nvarchar(max), N'
		--------------------------------------------------------------------------------------
		if @Strategy <> 0 
		begin
			--------------------------------------------------------------------------------------
			-- Compute edge date value (messages older than that date would be unloaded)
			--------------------------------------------------------------------------------------		  
			if @Strategy = 2 -- Clear by date
				set @EdgeDate = dateadd(day, -@CutDays, getdate());
			else -- Clear log by count
			begin
				set @Cmd = N''declare @RowSum int, @RowCount int, @Partition int, @MinDate datetime;
-- Fetch number of rows in each partition') + convert(nvarchar(max), N'
declare PartitionCursor cursor fast_forward for
select $partition.'' + @LogPartitionFunction + N''([Date]) [Partition] ,count([Date]) [RowCount], min([Date]) [MinDate]
from dbo.['' + @LogTable + N''] with(nolock)
group by $partition.'' + @LogPartitionFunction + N''([Date])
order by [MinDate] desc;
') + convert(nvarchar(max), N'
select @RowSum = 0, @EdgeDate = convert(date, getdate());
-- Iterate through partition data until "cut count" value would be reached and get edge date
open PartitionCursor;
fetch next from PartitionCursor into @Partition, @RowCount, @MinDate;
while (@@fetch_status = 0 and @CutCount > @RowSum)
begin
   select @RowSum = @RowSum + @RowCount, @EdgeDate = @MinDate;
   fetch next from PartitionCursor into @Partition, @RowCount, @MinDate;
end
close PartitionCursor;
deallocate PartitionCursor;'';') + convert(nvarchar(max), N'
				-- Compute edge date using required number of records in log table
				exec dbo.sp_executesql @Cmd, N''@CutCount int, @EdgeDate datetime output'', @CutCount, @EdgeDate output; 
			end
			--------------------------------------------------------------------------------------
			-- Unload data from log table and backup it
			--------------------------------------------------------------------------------------
			-- Fetch boundaries for backup from partition function
			declare @Boundary datetime;
			declare BoundaryCursor cursor fast_forward for
				select cast(Ranges.[value] as datetime) [Boundary]
				from	sys.partition_functions Func
						inner join sys.partition_range_values Ranges
							on Ranges.[function_id] = Func.[function_id]
							and Func.Name = @LogPartitionFunction
							and Ranges.[value] < @EdgeDate
				order by [Boundary] asc;
			open BoundaryCursor;
			fetch next from BoundaryCursor into @Boundary;
			-- Process partitions') + convert(nvarchar(max), N'
			while (@@fetch_status = 0)
			begin
				-- Clear backup table
				exec dbo.sp_executesql @TruncateCmd;
				-- Move log data to backup
				exec dbo.sp_executesql @MoveDataCmd, N''@Boundary datetime'', @Boundary;
				-- Merge empty partition
				exec dbo.sp_executesql @MergePartitionCmd, N''@Boundary datetime'', @Boundary;
				-- Backup old log messages
				if len(isnull(@BackupDir, N'''')) > 0
				begin
					select @Cmd = ' + @DB + N'[dbo].[dvfn_log_get_backup_command](@BackupDir, 0, @LogBackupTable, @LogName, @Boundary, ''' + @DBSuffix + N''');
					exec master..xp_cmdshell @Cmd, no_output;
				end
				fetch next from BoundaryCursor into @Boundary;
			end
			close BoundaryCursor;
			deallocate BoundaryCursor;			
		end		
	end');
	exec dbo.sp_executesql @exec_str, N'@LogType tinyint, @Strategy int, @CutDays int, @CutCount int, @BackupDir nvarchar(255)', @LogType = @LogType, @Strategy = @Strategy, @CutDays = @CutDays, @CutCount = @CutCount, @BackupDir = @BackupDir;
	-- Write Clear log message with LocalSystem user
	-- To do:
	--		1. Check if operation was disabled
	--      2. Write additional info about deleted messages
	exec [dbo].[dvsys_log_write_message] '{11111111-1111-0001-1111-000000000000}', '{00000000-0000-0000-0000-000000000000}', null, null, 2, '{BBBBBBBB-BBBB-0047-BBBB-000000000000}', 0;

----------------
set @dbts = @@dbts;
----------------
GO
-- ************************************************************************************
-- Setup Script for BI Builder Production Components 
-- (c)2014 Patrick Connors, Curious Developments Pty
-- Version alpha-0.1.0
-- FOR PRODUCTION DATABASES, THIS IS NOT THE BI BUILDER APPLICATION - JUST DEPENDENCIES
-- ************************************************************************************

--USE [<ProductionDatabaseName>]
--GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Audit')
EXEC sys.sp_executesql N'CREATE SCHEMA [Audit]'

GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'BIB')
EXEC sys.sp_executesql N'CREATE SCHEMA [BIB]'

GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DWHUtils')
EXEC sys.sp_executesql N'CREATE SCHEMA [DWHUtils]'

GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'ETL')
EXEC sys.sp_executesql N'CREATE SCHEMA [ETL]'

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BIB].[ForceFileGroupCreation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [BIB].[ForceFileGroupCreation] AS' 
END
GO

ALTER PROCEDURE [BIB].[ForceFileGroupCreation] (
@FileGroupName nvarchar(255))
AS
/*+ Version alpha-0.1.7.1062 20141005.170752 -------------------------------------------------------------- 
Stored Procedure [bib].[ForceFileGroupCreation]

When you build the tables and ETL routines from a Model Table,
you can specify what FILEGROUPs the staging and dimension tables will
be created within.

If the FILEGROUP does not exist, this routine is called to create it.

By default, it creates FILEs in the default data directory. If you want to override that
behaviour, you can alter this procedure.
-- -----------------------------------------------------------+*/
BEGIN

DECLARE @Default_Data_Path VARCHAR(512),   
        @Default_Log_Path VARCHAR(512);

IF NOT EXISTS(SELECT fg.name 
       FROM
		  sys.filegroups fg
		  WHERE fg.name = @FileGroupName
)
BEGIN

	   SELECT @Default_Data_Path =    
	   (   SELECT TOP 1 LEFT(physical_name,LEN(physical_name)-CHARINDEX('\',REVERSE(physical_name))+1) 
		  FROM sys.master_files mf   
		  INNER JOIN sys.[databases] d   
		  ON mf.[database_id] = d.[database_id]   
		  WHERE d.[name] = DB_NAME() AND type = 0);

	   DECLARE @Filename nvarchar(50)
	   DECLARE @SizeMB int
	   DECLARE @MaxSizeMB int
	   DECLARE @FileGrowthMB int
	   DECLARE @Msg nvarchar(255)
	   
	   SET @Filename = @FileGroupName
	   SET @SizeMB = 10
	   SET @FileGrowthMB = 10
	   SET @MaxSizeMB = 1000

	   BEGIN TRY
	   EXECUTE [bib].[CreateFilegroupWithFile] 
		 @FileGroupName
		,@Filename
		,@Default_Data_Path
		,@SizeMB
		,@MaxSizeMB
		,@FileGrowthMB
	   END TRY
	   BEGIN CATCH
		  SET @Msg = 'Problem creating the filegroup "'+@FileGroupName+'"in stored procedure [bib].[ForceFileGroupCreation]'
		  RAISERROR(@Msg, 16, 1);
	   END CATCH
  END
END

GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BIB].[CreateFilegroupWithFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [BIB].[CreateFilegroupWithFile] AS' 
END
GO

ALTER PROCEDURE [BIB].[CreateFilegroupWithFile]
( 
  @FileGroupName nvarchar(50)
, @Filename nvarchar(255)
, @FolderPath nvarchar(550)
, @SizeMB int = 5
, @MaxSizeMB int = 1000
, @FileGrowthMB int = 5
)
AS
--/*+ Version alpha-0.1.7.1034 20141005.170752 -------------------------------------------------------------- 
--Stored Procedure [bib].[CreateFilegroupWithFile]

--Called automatically within the ETL build process to create
--any FILEGROUPS specified in the parameters of [bib].[Main]
---- -----------------------------------------------------------+*/
DECLARE @SQL nvarchar(MAX)

SET @SQL = 
'
ALTER DATABASE '+ DB_Name() + '
ADD FILEGROUP '+@FileGroupName+'
'

--PRINT @SQL
EXECUTE sp_ExecuteSQL @SQL

SET @Filename = DB_Name() + '_' + @Filename

SET @SQL = 
' 
ALTER DATABASE '+ DB_Name() + '
ADD FILE 
(
    NAME = '''+@Filename+''',
    FILENAME = '''+@FolderPath+'\'+@Filename+'.ndf'',
    SIZE = '+LTRIM(@SizeMB)+'MB,
    MAXSIZE = '+LTRIM(@MaxSizeMB)+'MB,
    FILEGROWTH = '+LTRIM(@FileGrowthMB)+'MB
) TO FILEGROUP ['+@FileGroupName+']
'
--PRINT @SQL
EXECUTE sp_ExecuteSQL @SQL


GO

-- CREATE BIB FILEGROUPS


EXECUTE [BIB].[ForceFileGroupCreation] 'BIB'
EXECUTE [BIB].[ForceFileGroupCreation] 'Models'
EXECUTE [BIB].[ForceFileGroupCreation] 'DWH'
EXECUTE [BIB].[ForceFileGroupCreation] 'ETL_Logs'
EXECUTE [BIB].[ForceFileGroupCreation] 'Audit'


GO




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BIB].[BIB_Versions]') AND type in (N'U'))
BEGIN
CREATE TABLE [BIB].[BIB_Versions](
	[BIBVersion_Id] [int] IDENTITY(1,1) NOT NULL,
	[MajorVersion] [int] NOT NULL,
	[MinorVersion] [int] NOT NULL,
	[Revision] [int] NOT NULL,
	[VersionType] [nvarchar](50) NOT NULL CONSTRAINT [DF_BIBVersions_VersionType]  DEFAULT (N'alpha'),
	[ReleaseNotes] [nvarchar](max) NULL,
 CONSTRAINT [PK_BIBVersions] PRIMARY KEY CLUSTERED 
(
	[BIBVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [BIB]
) ON [BIB] TEXTIMAGE_ON [BIB]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BIB].[DataStates]') AND type in (N'U'))
BEGIN
CREATE TABLE [BIB].[DataStates](
	[DataState_Id] [int] NOT NULL,
	[DataStateName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_DataStates] PRIMARY KEY CLUSTERED 
(
	[DataState_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [BIB]
) ON [BIB]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BIB].[SourceSystems]') AND type in (N'U'))
BEGIN
CREATE TABLE [BIB].[SourceSystems](
	[SourceSystem_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystemName] [nvarchar](250) NOT NULL,
	[SourceSystemNotes] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_SourceSystems] PRIMARY KEY CLUSTERED 
(
	[SourceSystem_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [BIB]
) ON [BIB] TEXTIMAGE_ON [BIB]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ETL].[ETL_Batch_Details]') AND type in (N'U'))
BEGIN
CREATE TABLE [ETL].[ETL_Batch_Details](
	[ETL_Batch_Details_Id] [int] IDENTITY(1,1) NOT NULL,
	[ETL_Batch_Log_Id] [bigint] NOT NULL,
	[ETLLoadStatus_Id] [int] NOT NULL,
	[Start_Time] [datetime] NOT NULL,
	[End_Time] [datetime] NULL,
	[Run_Duration] [varchar](50) NULL,
	[Duration] [numeric](9, 2) NULL,
	[Success_Flag] [bit] NULL,
	[Error_Code] [int] NULL,
	[RecordsAffected] [int] NULL,
	[Message] [nvarchar](255) NULL,
 CONSTRAINT [PK_ETL_Batch_Details] PRIMARY KEY CLUSTERED 
(
	[ETL_Batch_Details_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [ETL_Logs]
) ON [ETL_Logs]
END
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ETL].[ETL_Batch_Logs]') AND type in (N'U'))
BEGIN
CREATE TABLE [ETL].[ETL_Batch_Logs](
	[ETL_Batch_Log_Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Process_Name] [varchar](1024) NOT NULL,
	[Start_Time] [datetime] NOT NULL,
	[End_Time] [datetime] NULL,
	[Run_Duration] [varchar](50) NULL,
	[Duration] [numeric](9, 2) NULL,
	[Success_Flag] [bit] NULL,
	[Error_Code] [int] NULL,
	[Load_Detail_Desc] [varchar](max) NULL,
	[Load_Detail] [varchar](max) NULL,
	[NoOfRecords] [int] NULL,
	[NoOfNewRecords] [int] NULL,
	[NoOfUpdatedRecords] [int] NULL,
	[Completeness] [int] NULL,
	[NoOfUnderlyingDataElements] [int] NULL,
	[NoOfNonApplicableDataElements] [int] NULL,
	[NoOfCorruptDataElements] [int] NULL,
	[NoOfOutOfBoundsDataElements] [int] NULL,
	[NoOfUnknownDataElementsTreatedAsZero] [int] NULL,
	[NoOfDataElementsChangedManually] [int] NULL,
	[NoOfCorrectionsPostedSinceOriginalDataLoad] [int] NULL,
	[Current_Row_Version] [varbinary](8) NULL,
 CONSTRAINT [PK_ETL_Batch_Logs] PRIMARY KEY CLUSTERED 
(
	[ETL_Batch_Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [ETL_Logs]
) ON [ETL_Logs] TEXTIMAGE_ON [ETL_Logs]
END
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DWHUtils].[ReportOnFilegroupTablesAndIndexes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DWHUtils].[ReportOnFilegroupTablesAndIndexes] AS' 
END
GO

ALTER PROCEDURE [DWHUtils].[ReportOnFilegroupTablesAndIndexes]
AS
/*+ Version alpha-0.1.0.0 20141005.170752 -------------------------------------------------------------- 
Stored Procedure [DWHUtils].[ReportOnFilegroupTablesAndIndexes]  

Provides a listing of what tables are on what filegroups and other information
about them.
-- -----------------------------------------------------------+*/
BEGIN

SELECT
		 OBJECT_SCHEMA_NAME ( t.object_id )  AS schema_name
		, t.name AS table_name
		, i.index_id
		, i.name AS index_name
		, p.partition_number
		, fg.name AS filegroup_name
		, p.rows as rows --FORMAT ( p.rows, '#,##' )  AS rows
FROM
	 sys.tables t 
	INNER JOIN  sys.indexes i
	ON t.object_id	=	i.object_id 
	INNER JOIN  sys.partitions p
	ON i.object_id	=	p.object_id AND i.index_id	=	p.index_id 
	LEFT OUTER JOIN  sys.partition_schemes ps
	ON i.data_space_id	=	ps.data_space_id 
	LEFT OUTER JOIN  sys.destination_data_spaces dds
	ON ps.data_space_id	=	dds.partition_scheme_id AND p.partition_number	=	dds.destination_id 
	INNER JOIN  sys.filegroups fg
		 ON COALESCE ( dds.data_space_id, i.data_space_id  ) 	=	fg.data_space_id 
	 ORDER BY	OBJECT_SCHEMA_NAME ( t.object_id ) 
	, t.name
	, fg.name
	, p.partition_number
	, i.name

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ETL].[AddETLBatchStepStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [ETL].[AddETLBatchStepStatus] AS' 
END
GO

--[ETL].[Flag_Staging_Sales_SalesTerritory_Records_For_Loading] 1

ALTER PROCEDURE [ETL].[AddETLBatchStepStatus]
( @Batch_ID bigint , @ETLLoadStatusId int, @Message nvarchar(1024), @RecordsAffected int)
AS
BEGIN

INSERT INTO [ETL].[ETL_Batch_Details]
           ([ETL_Batch_Log_Id]
           ,[ETLLoadStatus_Id]
           ,[Start_Time]
           ,[End_Time]
           ,[Run_Duration]
           ,[Duration]
           ,[Success_Flag]
           ,[Error_Code]
           ,[RecordsAffected]
		 , [Message])
     VALUES
           (@Batch_ID
           ,@ETLLoadStatusId
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,@RecordsAffected
		 ,@Message )

RETURN SCOPE_IDENTITY()
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ETL].[InitiateETLBatch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [ETL].[InitiateETLBatch] AS' 
END
GO

ALTER PROCEDURE [ETL].[InitiateETLBatch] ( @ProcessName nvarchar( 1024 ))
AS
/*+ -------------------------------------------------------------- 
Stored Procedure [ETL].[InitiateETLBatch]

For each batch of records loaded from staging to dimensions table in an ETL cycle
there are logs stored to document the metrics and success/failure of each load.

This routine initiates the logging table [ETL].[ETL_Batch_Logs] for each batch.

It is called by the ETL stored procedure [Load_<DIMENSION_NAME>] that is generated by 
BI Builder
-- -----------------------------------------------------------+*/
BEGIN

    SET NOCOUNT ON;

    INSERT INTO [ETL].[ETL_Batch_Logs]
			([Process_Name]
			,[Start_Time]
			,[End_Time])
    VALUES     (@ProcessName
			 ,GETDATE( ) 
			 , @@DBTS)           

    DECLARE @ETL_Batch_Log_Id bigint
    SET @ETL_Batch_Log_Id = SCOPE_IDENTITY()

    INSERT INTO [ETL].[ETL_Batch_Details]
			([ETL_Batch_Log_Id]
			,[ETLLoadStatus_Id]
			,[Start_Time]
			,[End_Time]
			,[Run_Duration]
			,[Duration]
			,[Success_Flag]
			,[Error_Code]
			,[Message]
			,[RecordsAffected] )
	    VALUES
			(@ETL_Batch_Log_Id
			,1
			,GETDATE()
			,GETDATE()
			,'0:00:00'
			,0
			,1
			,NULL
			,'ETL Batch Initiated OK'
			,0)

    RETURN @ETL_Batch_Log_Id

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ETL].[UpdateETLBatchStepStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [ETL].[UpdateETLBatchStepStatus] AS' 
END
GO

ALTER PROCEDURE [ETL].[UpdateETLBatchStepStatus]
( @Step_ID bigint , @ETLLoadStatusId int, @Message nvarchar(255), @RecordsAffected int, @Success bit, @ErrorCode int)
AS
BEGIN

DECLARE
   @EndTime datetime;
   DECLARE @Batch_Id bigint;

SET @EndTime = GETDATE( );

UPDATE [ETL].[ETL_Batch_Details]
   SET  [ETLLoadStatus_Id] = @ETLLoadStatusId
      ,[End_Time] = GETDATE()
      ,[Run_Duration] =  LTRIM( DATEDIFF( ss , Start_Time , @EndTime ) / 3600 ) + ':' + RIGHT( '00' + LTRIM( DATEDIFF( ss , Start_Time , @EndTime ) / 60 % 60 ) , 2 ) + ':' + RIGHT( '00' + LTRIM( DATEDIFF( ss , Start_Time , @EndTime ) % 60 ) , 2 )
      ,[Duration] = CEILING( 1.0 * DATEDIFF( ms , Start_Time , @EndTime ) / 1000 ) / 60
      ,[Success_Flag] = @Success
      ,[Error_Code] = @ErrorCode
      ,[RecordsAffected] = @RecordsAffected
      ,[Message] = @Message
 WHERE [ETL_Batch_Details_Id] = @Step_ID

 SELECT @Batch_Id = ETL_Batch_Log_Id FROM [ETL].[ETL_Batch_Details] WHERE  [ETL_Batch_Details_Id] = @Step_ID

UPDATE [ETL].[ETL_Batch_Logs]
SET 
    End_Time = GETDATE()
    ,[Success_Flag] = @Success
    ,[Error_Code] = @ErrorCode
    , Load_Detail_Desc = ISNULL(Load_Detail_Desc +'
', '' )+ @Message
     ,[Run_Duration] =  LTRIM( DATEDIFF( ss , Start_Time , @EndTime ) / 3600 ) + ':' + RIGHT( '00' + LTRIM( DATEDIFF( ss , Start_Time , @EndTime ) / 60 % 60 ) , 2 ) + ':' + RIGHT( '00' + LTRIM( DATEDIFF( ss , Start_Time , @EndTime ) % 60 ) , 2 )
      ,[Duration] = CEILING( 1.0 * DATEDIFF( ms , Start_Time , @EndTime ) / 1000 ) / 60
FROM [ETL].[ETL_Batch_Logs]
WHERE ETL_Batch_Log_Id = @Batch_Id

IF @ETLLoadStatusId = 2 -- Flagging records to import
BEGIN
    UPDATE [ETL].[ETL_Batch_Logs]
    SET 
	   NoOfRecords = @RecordsAffected

    FROM [ETL].[ETL_Batch_Logs]
    WHERE ETL_Batch_Log_Id = @Batch_Id
END

IF @ETLLoadStatusId = 3 -- Loading New Records
BEGIN
    UPDATE [ETL].[ETL_Batch_Logs]
    SET 
	   NoOfNewRecords = @RecordsAffected

    FROM [ETL].[ETL_Batch_Logs]
    WHERE ETL_Batch_Log_Id = @Batch_Id
END

IF @ETLLoadStatusId = 4-- Updating Records
BEGIN
    UPDATE [ETL].[ETL_Batch_Logs]
    SET 
	   NoOfUpdatedRecords = @RecordsAffected - NoOfNewRecords
    FROM [ETL].[ETL_Batch_Logs]
    WHERE ETL_Batch_Log_Id = @Batch_Id
END

END


GO
INSERT [bib].[DataStates] ([DataState_Id], [DataStateName]) VALUES (1, N'Staging - Flagged for load into dimension within batch')
GO
INSERT [bib].[DataStates] ([DataState_Id], [DataStateName]) VALUES (2, N'Staging - Loaded successfully into dimension within batch, ready for deletion')
GO
INSERT [bib].[DataStates] ([DataState_Id], [DataStateName]) VALUES (3, N'Staging - Error occurred loading records into dimension within batch')
GO
INSERT [bib].[DataStates] ([DataState_Id], [DataStateName]) VALUES (4, N'Dimension - Partial load of non-nullable columns (Part 1 of 2) - Not ready for reporting')
GO
INSERT [bib].[DataStates] ([DataState_Id], [DataStateName]) VALUES (5, N'Dimension - Load of all batched records complete (Part 2 of 2) - Ready for reporting')
GO
INSERT [bib].[DataStates] ([DataState_Id], [DataStateName]) VALUES (6, N'Dimension - Frozen, cannot be updated (Can only be set manually)')
GO
SET IDENTITY_INSERT [bib].[SourceSystems] ON 

GO
INSERT [bib].[SourceSystems] ([SourceSystem_Id], [SourceSystemName], [SourceSystemNotes]) VALUES (1, N'BI Builder Example Data Source', N'A placeholder used for the BI Builder examples')
GO
SET IDENTITY_INSERT [bib].[SourceSystems] OFF
GO
SET IDENTITY_INSERT [BIB].[BIB_Versions] ON 

GO
INSERT [BIB].[BIB_Versions] ([BIBVersion_Id], [MajorVersion], [MinorVersion], [Revision], [VersionType], [ReleaseNotes]) VALUES (1, 0, 1, 0, N'alpha', N'Initial Release to Codeplex')
GO
SET IDENTITY_INSERT [BIB].[BIB_Versions] OFF
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BIB].[AuditDropFromTable]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [BIB].[AuditDropFromTable]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BIB].[AuditAddToTable]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [BIB].[AuditAddToTable]
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [BIB].[AuditAddToTable]
( @SchemaName sysname, @StagingTableName sysname)
AS
/*+ Version alpha-0.1.0.1006 20141005.170752 -------------------------------------------------------------- 
Stored Procedure [bib].[AuditAddToTable]

Applies AutoAudit to a table using fixed settings.
-- -----------------------------------------------------------+*/

IF EXISTS (SELECT *
       FROM sys.objects
       WHERE object_id = OBJECT_ID( N'[Audit].[pAutoAudit]' )
         AND OBJECTPROPERTY( object_id , N'IsProcedure' ) = 1)
BEGIN

    EXECUTE bib.AuditDropFromTable @SchemaName, @StagingTableName

    DECLARE @ColumnNames varchar(max) = '<All>'
    DECLARE @StrictUserContext bit = 1
    DECLARE @LogSQL bit = 1
    DECLARE @BaseTableDDL bit = 1
    DECLARE @LogInsert tinyint = 2
    DECLARE @LogUpdate tinyint = 2
    DECLARE @LogDelete tinyint = 2 

    EXECUTE [Audit].[pAutoAudit] 
	  @SchemaName
	 ,@StagingTableName
	 ,@ColumnNames
	 ,@StrictUserContext
	 ,@LogSQL
	 ,@BaseTableDDL
	 ,@LogInsert
	 ,@LogUpdate
	 ,@LogDelete

END
ELSE
BEGIN
    PRINT 'BI BUILDER MESSAGE: You must have AutoAudit installed before it can be applied to the objects created by BI Builder'
END


GO

/****** Object:  StoredProcedure [BIB].[AuditDropFromTable]    Script Date: 16/10/2014 6:17:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [BIB].[AuditDropFromTable]
( @SchemaName sysname, @StagingTableName sysname)
AS
/*+ Version alpha-0.1.0.1010 20141005.170752 -------------------------------------------------------------- 
Stored Procedure [bib].[AuditDropFromTable]

Removes AutoAudit from a table using fixed options 
-- -----------------------------------------------------------+*/

IF EXISTS (SELECT *
       FROM sys.objects
       WHERE object_id = OBJECT_ID( N'[Audit].[pAutoAuditDrop]' )
         AND OBJECTPROPERTY( object_id , N'IsProcedure' ) = 1)
BEGIN

    DECLARE @DropBaseTableDDLColumns bit = 1
    DECLARE @DropBaseTableTriggers bit = 1
    DECLARE @DropBaseTableViews bit = 1
 

    EXECUTE [Audit].[pAutoAuditDrop] 
	  @SchemaName
	 ,@StagingTableName
	 ,@DropBaseTableDDLColumns
	 ,@DropBaseTableTriggers
	 ,@DropBaseTableViews

END
ELSE
BEGIN
    PRINT 'BI BUILDER MESSAGE: You must have AutoAudit installed before it can be applied to the objects created by BI Builder'
END


GO


-- Applying AutoAudit to BIB Tables if is it installed ****************************


EXECUTE [bib].[AuditAddToTable] 'BIB','DataStates'
EXECUTE [bib].[AuditAddToTable] 'BIB','SourceSystems'
EXECUTE [bib].[AuditAddToTable] 'BIB','BIB_Versions'
EXECUTE [bib].[AuditAddToTable] 'ETL','ETL_Batch_Logs'
EXECUTE [bib].[AuditAddToTable] 'ETL','ETL_Batch_Details'

GO
PRINT '---------------------------------------------------------------------------'
PRINT 'BI Builder version alpha-0.1.0 has been installed'

GO
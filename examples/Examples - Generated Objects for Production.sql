USE [<ProductionDatabaseName>]
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DWHUtils')
EXEC sys.sp_executesql N'CREATE SCHEMA [DWHUtils]'

GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'ETL')
EXEC sys.sp_executesql N'CREATE SCHEMA [ETL]'

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Example_Staging')
EXEC sys.sp_executesql N'CREATE SCHEMA [Example_Staging]'

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Examples')
EXEC sys.sp_executesql N'CREATE SCHEMA [Examples]'

GO


ALTER DATABASE <ProductionDatabaseName>
ADD FILEGROUP Examples
 
ALTER DATABASE <ProductionDatabaseName>
ADD FILE 
(
    NAME = '<ProductionDatabaseName>_Examples',
    FILENAME = '<Data_File_Path>\\<ProductionDatabaseName>_Examples.ndf',
    SIZE = 10MB,
    MAXSIZE = 1000MB,
    FILEGROWTH = 10MB
) TO FILEGROUP [Examples]



ALTER DATABASE <ProductionDatabaseName>
ADD FILEGROUP Example_Staging
 
ALTER DATABASE <ProductionDatabaseName>
ADD FILE 
(
    NAME = '<ProdDatabaseName_Example_Staging',
    FILENAME = '<Data_File_Path>\\<ProductionDatabaseName>_Example_Staging.ndf',
    SIZE = 10MB,
    MAXSIZE = 1000MB,
    FILEGROWTH = 10MB
) TO FILEGROUP [Example_Staging]





SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DWHUtils].[DateTimeToDateKey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [DWHUtils].[DateTimeToDateKey]
(
	@TheDate DateTime
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CodedDate int
	
	IF @TheDate IS NULL 
	BEGIN
		SET @CodedDate = -1
	END
	ELSE
	BEGIN
		SET @CodedDate = YEAR(@TheDate) * 10000 + MONTH(@TheDate) * 100 + DAY(@TheDate)
	END
	
	RETURN @CodedDate

END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DWHUtils].[DateTimeToDateTimeKey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [DWHUtils].[DateTimeToDateTimeKey]
(
	@TheDate DateTime
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CodedDate int
	DECLARE @CodedTime nvarchar(100)
	
	IF @TheDate IS NULL 
	BEGIN
		SET @CodedTime = ''''
	END
	ELSE
	BEGIN
		SET @CodedDate = YEAR(@TheDate) * 10000 + MONTH(@TheDate) * 100 + DAY(@TheDate)
		SET @CodedTime = LTRIM(@CodedDate) + ''.'' + REPLACE(REPLACE(CAST(CAST(@TheDate AS Time) AS nvarchar(8)),'':'',''''),''.'','''')
	END
	
	RETURN @CodedTime

END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DWHUtils].[DateTimeToDateTimeString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [DWHUtils].[DateTimeToDateTimeString]
(
	@TheDate DateTime
)
RETURNS nvarchar(100)
AS

/*+ Version alpha-0.1.0.0 20141005.172312 -------------------------------------------------------------- 
Scalar Function [DWHUtils].[DateTimeToDateTimeString]

Returns the datetime parameter as a string in the format yyyymmdd.hhmmss
-- -----------------------------------------------------------+*/
BEGIN
	-- Declare the return variable here
	DECLARE @CodedDate int
	DECLARE @CodedTime nvarchar(100)
	
	IF @TheDate IS NULL 
	BEGIN
		SET @CodedTime = ''''
	END
	ELSE
	BEGIN
		SET @CodedDate = YEAR(@TheDate) * 10000 + MONTH(@TheDate) * 100 + DAY(@TheDate)
		SET @CodedTime = LTRIM(@CodedDate) + ''.'' + REPLACE(REPLACE(CAST(CAST(@TheDate AS Time) AS nvarchar(8)),'':'',''''),''.'','''')
	END
	
	RETURN @CodedTime

END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DWHUtils].[DatetimeToIntegerTimestamp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [DWHUtils].[DatetimeToIntegerTimestamp] (
@DateTime DateTime
)
RETURNS integer
AS
/*+ Version alpha-0.1.0.0 20141005.170752 -------------------------------------------------------------- 
Scalar Function [DWHUtils].[DatetimeToIntegerTimestamp]

Used in an example of custom type conversion, this routine 
converts a Integer type date field (seconds since Jan 1 1970) into
a DateTime.
-- -----------------------------------------------------------+*/
BEGIN
  /* Function body */
  DECLARE @timestamp integer

  SELECT @timestamp = DateDIFF(second, {d ''1970-01-01''}, @DateTime);

  RETURN @timestamp
END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DWHUtils].[IntegerTimestampToDatetime]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [DWHUtils].[IntegerTimestampToDatetime] (
@timestamp integer
)
RETURNS datetime
AS
BEGIN
  /* Function body */
  DECLARE @return datetime

  SELECT @return = DATEADD(second, @timestamp,{d ''1970-01-01''});

  RETURN @return
END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Example_Staging].[CompositeKeyExample]') AND type in (N'U'))
BEGIN
CREATE TABLE [Example_Staging].[CompositeKeyExample](
	[CompositeKeyExample_Id] [int] NOT NULL,
	[TractorModelName] [nvarchar](100) NOT NULL,
	[Manufacturer_Id] [int] NOT NULL,
	[CountryOfManufacture_Id] [int] NOT NULL,
	[ModelFamilyName] [nvarchar](100) NULL,
	[Catalogue_Number] [int] NULL,
	[Record_Deleted] [bit] NOT NULL DEFAULT ((0)),
	[Record_Last_Updated] [datetime] NOT NULL DEFAULT (getdate()),
	[Staging_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL DEFAULT ((1)),
	[ETLBatch_Id] [bigint] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Example_Staging_CompositeKeyExample] PRIMARY KEY CLUSTERED 
(
	[Staging_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Example_Staging].[ExampleColumnNameConversion]') AND type in (N'U'))
BEGIN
CREATE TABLE [Example_Staging].[ExampleColumnNameConversion](
	[ThisKeyWontChangeName_Id] [int] NOT NULL,
	[Cust_St_Dt] [nvarchar](100) NULL,
	[ThisColumnWillEndUpWithUnderscores] [int] NULL,
	[SalesforceTypeColumnName__c] [int] NULL,
	[Record_Last_Modified] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Staging_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [bigint] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Example_Staging_ExampleColumnNameConversion] PRIMARY KEY CLUSTERED 
(
	[Staging_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Example_Staging].[ExampleOfPausingETLBuilds]') AND type in (N'U'))
BEGIN
CREATE TABLE [Example_Staging].[ExampleOfPausingETLBuilds](
	[PrimaryKey_Id] [int] NOT NULL,
	[Cust_Id] [int] NOT NULL,
	[StartDate] [nvarchar](12) NULL,
	[CustTypeCode] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
	[Staging_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL DEFAULT ((1)),
	[ETLBatch_Id] [bigint] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Example_Staging_ExampleOfPausingETLBuilds] PRIMARY KEY CLUSTERED 
(
	[Staging_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Example_Staging].[ExampleTablewith300Fields]') AND type in (N'U'))
BEGIN
CREATE TABLE [Example_Staging].[ExampleTablewith300Fields](
	[Test_Id] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL DEFAULT (getdate()),
	[Column_No_1] [nvarchar](255) NULL,
	[Column_No_2] [datetime] NULL,
	[Column_No_3] [int] NULL,
	[Column_No_4] [xml] NULL,
	[Column_No_5] [money] NULL,
	[Column_No_6] [numeric](18, 0) NULL,
	[Column_No_7] [nvarchar](max) NULL,
	[Column_No_8] [bit] NULL,
	[Column_No_9] [uniqueidentifier] NULL,
	[Column_No_10] [image] NULL,
	[Column_No_11] [nvarchar](255) NULL,
	[Column_No_12] [datetime] NULL,
	[Column_No_13] [int] NULL,
	[Column_No_14] [xml] NULL,
	[Column_No_15] [money] NULL,
	[Column_No_16] [numeric](18, 0) NULL,
	[Column_No_17] [nvarchar](max) NULL,
	[Column_No_18] [bit] NULL,
	[Column_No_19] [uniqueidentifier] NULL,
	[Column_No_20] [image] NULL,
	[Column_No_21] [nvarchar](255) NULL,
	[Column_No_22] [datetime] NULL,
	[Column_No_23] [int] NULL,
	[Column_No_24] [xml] NULL,
	[Column_No_25] [money] NULL,
	[Column_No_26] [numeric](18, 0) NULL,
	[Column_No_27] [nvarchar](max) NULL,
	[Column_No_28] [bit] NULL,
	[Column_No_29] [uniqueidentifier] NULL,
	[Column_No_30] [image] NULL,
	[Column_No_31] [nvarchar](255) NULL,
	[Column_No_32] [datetime] NULL,
	[Column_No_33] [int] NULL,
	[Column_No_34] [xml] NULL,
	[Column_No_35] [money] NULL,
	[Column_No_36] [numeric](18, 0) NULL,
	[Column_No_37] [nvarchar](max) NULL,
	[Column_No_38] [bit] NULL,
	[Column_No_39] [uniqueidentifier] NULL,
	[Column_No_40] [image] NULL,
	[Column_No_41] [nvarchar](255) NULL,
	[Column_No_42] [datetime] NULL,
	[Column_No_43] [int] NULL,
	[Column_No_44] [xml] NULL,
	[Column_No_45] [money] NULL,
	[Column_No_46] [numeric](18, 0) NULL,
	[Column_No_47] [nvarchar](max) NULL,
	[Column_No_48] [bit] NULL,
	[Column_No_49] [uniqueidentifier] NULL,
	[Column_No_50] [image] NULL,
	[Column_No_51] [nvarchar](255) NULL,
	[Column_No_52] [datetime] NULL,
	[Column_No_53] [int] NULL,
	[Column_No_54] [xml] NULL,
	[Column_No_55] [money] NULL,
	[Column_No_56] [numeric](18, 0) NULL,
	[Column_No_57] [nvarchar](max) NULL,
	[Column_No_58] [bit] NULL,
	[Column_No_59] [uniqueidentifier] NULL,
	[Column_No_60] [image] NULL,
	[Column_No_61] [nvarchar](255) NULL,
	[Column_No_62] [datetime] NULL,
	[Column_No_63] [int] NULL,
	[Column_No_64] [xml] NULL,
	[Column_No_65] [money] NULL,
	[Column_No_66] [numeric](18, 0) NULL,
	[Column_No_67] [nvarchar](max) NULL,
	[Column_No_68] [bit] NULL,
	[Column_No_69] [uniqueidentifier] NULL,
	[Column_No_70] [image] NULL,
	[Column_No_71] [nvarchar](255) NULL,
	[Column_No_72] [datetime] NULL,
	[Column_No_73] [int] NULL,
	[Column_No_74] [xml] NULL,
	[Column_No_75] [money] NULL,
	[Column_No_76] [numeric](18, 0) NULL,
	[Column_No_77] [nvarchar](max) NULL,
	[Column_No_78] [bit] NULL,
	[Column_No_79] [uniqueidentifier] NULL,
	[Column_No_80] [image] NULL,
	[Column_No_81] [nvarchar](255) NULL,
	[Column_No_82] [datetime] NULL,
	[Column_No_83] [int] NULL,
	[Column_No_84] [xml] NULL,
	[Column_No_85] [money] NULL,
	[Column_No_86] [numeric](18, 0) NULL,
	[Column_No_87] [nvarchar](max) NULL,
	[Column_No_88] [bit] NULL,
	[Column_No_89] [uniqueidentifier] NULL,
	[Column_No_90] [image] NULL,
	[Column_No_91] [nvarchar](255) NULL,
	[Column_No_92] [datetime] NULL,
	[Column_No_93] [int] NULL,
	[Column_No_94] [xml] NULL,
	[Column_No_95] [money] NULL,
	[Column_No_96] [numeric](18, 0) NULL,
	[Column_No_97] [nvarchar](max) NULL,
	[Column_No_98] [bit] NULL,
	[Column_No_99] [uniqueidentifier] NULL,
	[Column_No_100] [image] NULL,
	[Column_No_101] [nvarchar](255) NULL,
	[Column_No_102] [datetime] NULL,
	[Column_No_103] [int] NULL,
	[Column_No_104] [xml] NULL,
	[Column_No_105] [money] NULL,
	[Column_No_106] [numeric](18, 0) NULL,
	[Column_No_107] [nvarchar](max) NULL,
	[Column_No_108] [bit] NULL,
	[Column_No_109] [uniqueidentifier] NULL,
	[Column_No_110] [image] NULL,
	[Column_No_111] [nvarchar](255) NULL,
	[Column_No_112] [datetime] NULL,
	[Column_No_113] [int] NULL,
	[Column_No_114] [xml] NULL,
	[Column_No_115] [money] NULL,
	[Column_No_116] [numeric](18, 0) NULL,
	[Column_No_117] [nvarchar](max) NULL,
	[Column_No_118] [bit] NULL,
	[Column_No_119] [uniqueidentifier] NULL,
	[Column_No_120] [image] NULL,
	[Column_No_121] [nvarchar](255) NULL,
	[Column_No_122] [datetime] NULL,
	[Column_No_123] [int] NULL,
	[Column_No_124] [xml] NULL,
	[Column_No_125] [money] NULL,
	[Column_No_126] [numeric](18, 0) NULL,
	[Column_No_127] [nvarchar](max) NULL,
	[Column_No_128] [bit] NULL,
	[Column_No_129] [uniqueidentifier] NULL,
	[Column_No_130] [image] NULL,
	[Column_No_131] [nvarchar](255) NULL,
	[Column_No_132] [datetime] NULL,
	[Column_No_133] [int] NULL,
	[Column_No_134] [xml] NULL,
	[Column_No_135] [money] NULL,
	[Column_No_136] [numeric](18, 0) NULL,
	[Column_No_137] [nvarchar](max) NULL,
	[Column_No_138] [bit] NULL,
	[Column_No_139] [uniqueidentifier] NULL,
	[Column_No_140] [image] NULL,
	[Column_No_141] [nvarchar](255) NULL,
	[Column_No_142] [datetime] NULL,
	[Column_No_143] [int] NULL,
	[Column_No_144] [xml] NULL,
	[Column_No_145] [money] NULL,
	[Column_No_146] [numeric](18, 0) NULL,
	[Column_No_147] [nvarchar](max) NULL,
	[Column_No_148] [bit] NULL,
	[Column_No_149] [uniqueidentifier] NULL,
	[Column_No_150] [image] NULL,
	[Column_No_151] [nvarchar](255) NULL,
	[Column_No_152] [datetime] NULL,
	[Column_No_153] [int] NULL,
	[Column_No_154] [xml] NULL,
	[Column_No_155] [money] NULL,
	[Column_No_156] [numeric](18, 0) NULL,
	[Column_No_157] [nvarchar](max) NULL,
	[Column_No_158] [bit] NULL,
	[Column_No_159] [uniqueidentifier] NULL,
	[Column_No_160] [image] NULL,
	[Column_No_161] [nvarchar](255) NULL,
	[Column_No_162] [datetime] NULL,
	[Column_No_163] [int] NULL,
	[Column_No_164] [xml] NULL,
	[Column_No_165] [money] NULL,
	[Column_No_166] [numeric](18, 0) NULL,
	[Column_No_167] [nvarchar](max) NULL,
	[Column_No_168] [bit] NULL,
	[Column_No_169] [uniqueidentifier] NULL,
	[Column_No_170] [image] NULL,
	[Column_No_171] [nvarchar](255) NULL,
	[Column_No_172] [datetime] NULL,
	[Column_No_173] [int] NULL,
	[Column_No_174] [xml] NULL,
	[Column_No_175] [money] NULL,
	[Column_No_176] [numeric](18, 0) NULL,
	[Column_No_177] [nvarchar](max) NULL,
	[Column_No_178] [bit] NULL,
	[Column_No_179] [uniqueidentifier] NULL,
	[Column_No_180] [image] NULL,
	[Column_No_181] [nvarchar](255) NULL,
	[Column_No_182] [datetime] NULL,
	[Column_No_183] [int] NULL,
	[Column_No_184] [xml] NULL,
	[Column_No_185] [money] NULL,
	[Column_No_186] [numeric](18, 0) NULL,
	[Column_No_187] [nvarchar](max) NULL,
	[Column_No_188] [bit] NULL,
	[Column_No_189] [uniqueidentifier] NULL,
	[Column_No_190] [image] NULL,
	[Column_No_191] [nvarchar](255) NULL,
	[Column_No_192] [datetime] NULL,
	[Column_No_193] [int] NULL,
	[Column_No_194] [xml] NULL,
	[Column_No_195] [money] NULL,
	[Column_No_196] [numeric](18, 0) NULL,
	[Column_No_197] [nvarchar](max) NULL,
	[Column_No_198] [bit] NULL,
	[Column_No_199] [uniqueidentifier] NULL,
	[Column_No_200] [image] NULL,
	[Column_No_201] [nvarchar](255) NULL,
	[Column_No_202] [datetime] NULL,
	[Column_No_203] [int] NULL,
	[Column_No_204] [xml] NULL,
	[Column_No_205] [money] NULL,
	[Column_No_206] [numeric](18, 0) NULL,
	[Column_No_207] [nvarchar](max) NULL,
	[Column_No_208] [bit] NULL,
	[Column_No_209] [uniqueidentifier] NULL,
	[Column_No_210] [image] NULL,
	[Column_No_211] [nvarchar](255) NULL,
	[Column_No_212] [datetime] NULL,
	[Column_No_213] [int] NULL,
	[Column_No_214] [xml] NULL,
	[Column_No_215] [money] NULL,
	[Column_No_216] [numeric](18, 0) NULL,
	[Column_No_217] [nvarchar](max) NULL,
	[Column_No_218] [bit] NULL,
	[Column_No_219] [uniqueidentifier] NULL,
	[Column_No_220] [image] NULL,
	[Column_No_221] [nvarchar](255) NULL,
	[Column_No_222] [datetime] NULL,
	[Column_No_223] [int] NULL,
	[Column_No_224] [xml] NULL,
	[Column_No_225] [money] NULL,
	[Column_No_226] [numeric](18, 0) NULL,
	[Column_No_227] [nvarchar](max) NULL,
	[Column_No_228] [bit] NULL,
	[Column_No_229] [uniqueidentifier] NULL,
	[Column_No_230] [image] NULL,
	[Column_No_231] [nvarchar](255) NULL,
	[Column_No_232] [datetime] NULL,
	[Column_No_233] [int] NULL,
	[Column_No_234] [xml] NULL,
	[Column_No_235] [money] NULL,
	[Column_No_236] [numeric](18, 0) NULL,
	[Column_No_237] [nvarchar](max) NULL,
	[Column_No_238] [bit] NULL,
	[Column_No_239] [uniqueidentifier] NULL,
	[Column_No_240] [image] NULL,
	[Column_No_241] [nvarchar](255) NULL,
	[Column_No_242] [datetime] NULL,
	[Column_No_243] [int] NULL,
	[Column_No_244] [xml] NULL,
	[Column_No_245] [money] NULL,
	[Column_No_246] [numeric](18, 0) NULL,
	[Column_No_247] [nvarchar](max) NULL,
	[Column_No_248] [bit] NULL,
	[Column_No_249] [uniqueidentifier] NULL,
	[Column_No_250] [image] NULL,
	[Column_No_251] [nvarchar](255) NULL,
	[Column_No_252] [datetime] NULL,
	[Column_No_253] [int] NULL,
	[Column_No_254] [xml] NULL,
	[Column_No_255] [money] NULL,
	[Column_No_256] [numeric](18, 0) NULL,
	[Column_No_257] [nvarchar](max) NULL,
	[Column_No_258] [bit] NULL,
	[Column_No_259] [uniqueidentifier] NULL,
	[Column_No_260] [image] NULL,
	[Column_No_261] [nvarchar](255) NULL,
	[Column_No_262] [datetime] NULL,
	[Column_No_263] [int] NULL,
	[Column_No_264] [xml] NULL,
	[Column_No_265] [money] NULL,
	[Column_No_266] [numeric](18, 0) NULL,
	[Column_No_267] [nvarchar](max) NULL,
	[Column_No_268] [bit] NULL,
	[Column_No_269] [uniqueidentifier] NULL,
	[Column_No_270] [image] NULL,
	[Column_No_271] [nvarchar](255) NULL,
	[Column_No_272] [datetime] NULL,
	[Column_No_273] [int] NULL,
	[Column_No_274] [xml] NULL,
	[Column_No_275] [money] NULL,
	[Column_No_276] [numeric](18, 0) NULL,
	[Column_No_277] [nvarchar](max) NULL,
	[Column_No_278] [bit] NULL,
	[Column_No_279] [uniqueidentifier] NULL,
	[Column_No_280] [image] NULL,
	[Column_No_281] [nvarchar](255) NULL,
	[Column_No_282] [datetime] NULL,
	[Column_No_283] [int] NULL,
	[Column_No_284] [xml] NULL,
	[Column_No_285] [money] NULL,
	[Column_No_286] [numeric](18, 0) NULL,
	[Column_No_287] [nvarchar](max) NULL,
	[Column_No_288] [bit] NULL,
	[Column_No_289] [uniqueidentifier] NULL,
	[Column_No_290] [image] NULL,
	[Column_No_291] [nvarchar](255) NULL,
	[Column_No_292] [datetime] NULL,
	[Column_No_293] [int] NULL,
	[Column_No_294] [xml] NULL,
	[Column_No_295] [money] NULL,
	[Column_No_296] [numeric](18, 0) NULL,
	[Column_No_297] [nvarchar](max) NULL,
	[Column_No_298] [bit] NULL,
	[Column_No_299] [uniqueidentifier] NULL,
	[Column_No_300] [image] NULL,
	[IsDeleted] [bit] NOT NULL DEFAULT ((0)),
	[Staging_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL DEFAULT ((1)),
	[ETLBatch_Id] [bigint] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Example_Staging_ExampleTablewith300Fields] PRIMARY KEY CLUSTERED 
(
	[Staging_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Example_Staging].[ExampleTypeConversion]') AND type in (N'U'))
BEGIN
CREATE TABLE [Example_Staging].[ExampleTypeConversion](
	[ExampleTypeConversion_Id] [int] NOT NULL,
	[ATextField] [nvarchar](255) NOT NULL,
	[Integer_Style_Timestamp] [int] NOT NULL,
	[Staging_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL DEFAULT ((1)),
	[ETLBatch_Id] [bigint] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Example_Staging_ExampleTypeConversion] PRIMARY KEY CLUSTERED 
(
	[Staging_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Example_Staging].[Tractors]') AND type in (N'U'))
BEGIN
CREATE TABLE [Example_Staging].[Tractors](
	[Tractor_Id] [int] NOT NULL,
	[TractorModelName] [nvarchar](100) NULL,
	[Manufacturer_Id] [int] NULL,
	[CountryOfManufacture_Id] [int] NULL,
	[ModelFamilyName] [nvarchar](100) NULL,
	[Catalogue_Number] [int] NULL,
	[Record_Deleted] [bit] NOT NULL DEFAULT ((0)),
	[Record_Last_Updated] [datetime] NOT NULL DEFAULT (getdate()),
	[Staging_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL DEFAULT ((1)),
	[ETLBatch_Id] [bigint] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Example_Staging_Tractors] PRIMARY KEY CLUSTERED 
(
	[Staging_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Example_Staging].[TractorsSCDType2]') AND type in (N'U'))
BEGIN
CREATE TABLE [Example_Staging].[TractorsSCDType2](
	[Tractor_Id] [int] NOT NULL,
	[TractorModelName] [nvarchar](100) NULL,
	[Manufacturer_Id] [int] NULL,
	[CountryOfManufacture_Id] [int] NULL,
	[ModelFamilyName] [nvarchar](100) NULL,
	[Catalogue_Number] [int] NULL,
	[Record_Deleted] [bit] NOT NULL DEFAULT ((0)),
	[Record_Last_Updated] [datetime] NOT NULL DEFAULT (getdate()),
	[Staging_Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL DEFAULT ((1)),
	[ETLBatch_Id] [bigint] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Example_Staging_TractorsSCDType2] PRIMARY KEY CLUSTERED 
(
	[Staging_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[DimCompositeKeyExample]') AND type in (N'U'))
BEGIN
CREATE TABLE [Examples].[DimCompositeKeyExample](
	[DimCompositeKeyExample_did] [bigint] IDENTITY(1,1) NOT NULL,
	[Catalogue_Number] [int] NULL,
	[CompositeKeyExample_Id] [int] NOT NULL,
	[CountryOfManufacture_Id] [int] NOT NULL,
	[Manufacturer_Id] [int] NOT NULL,
	[Model_Family_Name] [nvarchar](512) NULL,
	[Record_Deleted] [bit] NOT NULL,
	[Record_Last_Updated] [datetime] NOT NULL,
	[Tractor_Model_Name] [nvarchar](512) NOT NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [int] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Examples_DimCompositeKeyExample_DID] PRIMARY KEY CLUSTERED 
(
	[DimCompositeKeyExample_did] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Examples]
) ON [Examples]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[DimExampleColumnNameConversion]') AND type in (N'U'))
BEGIN
CREATE TABLE [Examples].[DimExampleColumnNameConversion](
	[DimExampleColumnNameConversion_did] [bigint] IDENTITY(1,1) NOT NULL,
	[Customer_Start_Date] [nvarchar](512) NULL,
	[Is_Deleted] [bit] NOT NULL,
	[Record_Last_Modified] [datetime] NOT NULL,
	[Salesforce_Type_Column_Name] [int] NULL,
	[This_Column_Will_End_Up_With_Underscores] [int] NULL,
	[ThisKeyWontChangeName_Id] [int] NOT NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [int] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Examples_DimExampleColumnNameConversion_DID] PRIMARY KEY CLUSTERED 
(
	[DimExampleColumnNameConversion_did] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Examples]
) ON [Examples]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[DimExampleOfPausingETLBuilds]') AND type in (N'U'))
BEGIN
CREATE TABLE [Examples].[DimExampleOfPausingETLBuilds](
	[DimExampleOfPausingETLBuilds_did] [bigint] IDENTITY(1,1) NOT NULL,
	[Cust_Id] [int] NOT NULL,
	[Cust_Type_Code] [int] NULL,
	[Is_Deleted] [bit] NOT NULL,
	[PrimaryKey_Id] [int] NOT NULL,
	[Start_Date] [datetime] NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [int] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Examples_DimExampleOfPausingETLBuilds_DID] PRIMARY KEY CLUSTERED 
(
	[DimExampleOfPausingETLBuilds_did] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Examples]
) ON [Examples]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[DimExampleTablewith300Fields]') AND type in (N'U'))
BEGIN
CREATE TABLE [Examples].[DimExampleTablewith300Fields](
	[DimExampleTablewith300Fields_did] [bigint] IDENTITY(1,1) NOT NULL,
	[Column_No_1] [nvarchar](512) NULL,
	[Column_No_10] [image] NULL,
	[Column_No_100] [image] NULL,
	[Column_No_101] [nvarchar](512) NULL,
	[Column_No_102] [datetime] NULL,
	[Column_No_103] [int] NULL,
	[Column_No_104] [xml] NULL,
	[Column_No_105] [money] NULL,
	[Column_No_106] [numeric](18, 0) NULL,
	[Column_No_107] [nvarchar](max) NULL,
	[Column_No_108] [bit] NULL,
	[Column_No_109] [uniqueidentifier] NULL,
	[Column_No_11] [nvarchar](512) NULL,
	[Column_No_110] [image] NULL,
	[Column_No_111] [nvarchar](512) NULL,
	[Column_No_112] [datetime] NULL,
	[Column_No_113] [int] NULL,
	[Column_No_114] [xml] NULL,
	[Column_No_115] [money] NULL,
	[Column_No_116] [numeric](18, 0) NULL,
	[Column_No_117] [nvarchar](max) NULL,
	[Column_No_118] [bit] NULL,
	[Column_No_119] [uniqueidentifier] NULL,
	[Column_No_12] [datetime] NULL,
	[Column_No_120] [image] NULL,
	[Column_No_121] [nvarchar](512) NULL,
	[Column_No_122] [datetime] NULL,
	[Column_No_123] [int] NULL,
	[Column_No_124] [xml] NULL,
	[Column_No_125] [money] NULL,
	[Column_No_126] [numeric](18, 0) NULL,
	[Column_No_127] [nvarchar](max) NULL,
	[Column_No_128] [bit] NULL,
	[Column_No_129] [uniqueidentifier] NULL,
	[Column_No_13] [int] NULL,
	[Column_No_130] [image] NULL,
	[Column_No_131] [nvarchar](512) NULL,
	[Column_No_132] [datetime] NULL,
	[Column_No_133] [int] NULL,
	[Column_No_134] [xml] NULL,
	[Column_No_135] [money] NULL,
	[Column_No_136] [numeric](18, 0) NULL,
	[Column_No_137] [nvarchar](max) NULL,
	[Column_No_138] [bit] NULL,
	[Column_No_139] [uniqueidentifier] NULL,
	[Column_No_14] [xml] NULL,
	[Column_No_140] [image] NULL,
	[Column_No_141] [nvarchar](512) NULL,
	[Column_No_142] [datetime] NULL,
	[Column_No_143] [int] NULL,
	[Column_No_144] [xml] NULL,
	[Column_No_145] [money] NULL,
	[Column_No_146] [numeric](18, 0) NULL,
	[Column_No_147] [nvarchar](max) NULL,
	[Column_No_148] [bit] NULL,
	[Column_No_149] [uniqueidentifier] NULL,
	[Column_No_15] [money] NULL,
	[Column_No_150] [image] NULL,
	[Column_No_151] [nvarchar](512) NULL,
	[Column_No_152] [datetime] NULL,
	[Column_No_153] [int] NULL,
	[Column_No_154] [xml] NULL,
	[Column_No_155] [money] NULL,
	[Column_No_156] [numeric](18, 0) NULL,
	[Column_No_157] [nvarchar](max) NULL,
	[Column_No_158] [bit] NULL,
	[Column_No_159] [uniqueidentifier] NULL,
	[Column_No_16] [numeric](18, 0) NULL,
	[Column_No_160] [image] NULL,
	[Column_No_161] [nvarchar](512) NULL,
	[Column_No_162] [datetime] NULL,
	[Column_No_163] [int] NULL,
	[Column_No_164] [xml] NULL,
	[Column_No_165] [money] NULL,
	[Column_No_166] [numeric](18, 0) NULL,
	[Column_No_167] [nvarchar](max) NULL,
	[Column_No_168] [bit] NULL,
	[Column_No_169] [uniqueidentifier] NULL,
	[Column_No_17] [nvarchar](max) NULL,
	[Column_No_170] [image] NULL,
	[Column_No_171] [nvarchar](512) NULL,
	[Column_No_172] [datetime] NULL,
	[Column_No_173] [int] NULL,
	[Column_No_174] [xml] NULL,
	[Column_No_175] [money] NULL,
	[Column_No_176] [numeric](18, 0) NULL,
	[Column_No_177] [nvarchar](max) NULL,
	[Column_No_178] [bit] NULL,
	[Column_No_179] [uniqueidentifier] NULL,
	[Column_No_18] [bit] NULL,
	[Column_No_180] [image] NULL,
	[Column_No_181] [nvarchar](512) NULL,
	[Column_No_182] [datetime] NULL,
	[Column_No_183] [int] NULL,
	[Column_No_184] [xml] NULL,
	[Column_No_185] [money] NULL,
	[Column_No_186] [numeric](18, 0) NULL,
	[Column_No_187] [nvarchar](max) NULL,
	[Column_No_188] [bit] NULL,
	[Column_No_189] [uniqueidentifier] NULL,
	[Column_No_19] [uniqueidentifier] NULL,
	[Column_No_190] [image] NULL,
	[Column_No_191] [nvarchar](512) NULL,
	[Column_No_192] [datetime] NULL,
	[Column_No_193] [int] NULL,
	[Column_No_194] [xml] NULL,
	[Column_No_195] [money] NULL,
	[Column_No_196] [numeric](18, 0) NULL,
	[Column_No_197] [nvarchar](max) NULL,
	[Column_No_198] [bit] NULL,
	[Column_No_199] [uniqueidentifier] NULL,
	[Column_No_2] [datetime] NULL,
	[Column_No_20] [image] NULL,
	[Column_No_200] [image] NULL,
	[Column_No_201] [nvarchar](512) NULL,
	[Column_No_202] [datetime] NULL,
	[Column_No_203] [int] NULL,
	[Column_No_204] [xml] NULL,
	[Column_No_205] [money] NULL,
	[Column_No_206] [numeric](18, 0) NULL,
	[Column_No_207] [nvarchar](max) NULL,
	[Column_No_208] [bit] NULL,
	[Column_No_209] [uniqueidentifier] NULL,
	[Column_No_21] [nvarchar](512) NULL,
	[Column_No_210] [image] NULL,
	[Column_No_211] [nvarchar](512) NULL,
	[Column_No_212] [datetime] NULL,
	[Column_No_213] [int] NULL,
	[Column_No_214] [xml] NULL,
	[Column_No_215] [money] NULL,
	[Column_No_216] [numeric](18, 0) NULL,
	[Column_No_217] [nvarchar](max) NULL,
	[Column_No_218] [bit] NULL,
	[Column_No_219] [uniqueidentifier] NULL,
	[Column_No_22] [datetime] NULL,
	[Column_No_220] [image] NULL,
	[Column_No_221] [nvarchar](512) NULL,
	[Column_No_222] [datetime] NULL,
	[Column_No_223] [int] NULL,
	[Column_No_224] [xml] NULL,
	[Column_No_225] [money] NULL,
	[Column_No_226] [numeric](18, 0) NULL,
	[Column_No_227] [nvarchar](max) NULL,
	[Column_No_228] [bit] NULL,
	[Column_No_229] [uniqueidentifier] NULL,
	[Column_No_23] [int] NULL,
	[Column_No_230] [image] NULL,
	[Column_No_231] [nvarchar](512) NULL,
	[Column_No_232] [datetime] NULL,
	[Column_No_233] [int] NULL,
	[Column_No_234] [xml] NULL,
	[Column_No_235] [money] NULL,
	[Column_No_236] [numeric](18, 0) NULL,
	[Column_No_237] [nvarchar](max) NULL,
	[Column_No_238] [bit] NULL,
	[Column_No_239] [uniqueidentifier] NULL,
	[Column_No_24] [xml] NULL,
	[Column_No_240] [image] NULL,
	[Column_No_241] [nvarchar](512) NULL,
	[Column_No_242] [datetime] NULL,
	[Column_No_243] [int] NULL,
	[Column_No_244] [xml] NULL,
	[Column_No_245] [money] NULL,
	[Column_No_246] [numeric](18, 0) NULL,
	[Column_No_247] [nvarchar](max) NULL,
	[Column_No_248] [bit] NULL,
	[Column_No_249] [uniqueidentifier] NULL,
	[Column_No_25] [money] NULL,
	[Column_No_250] [image] NULL,
	[Column_No_251] [nvarchar](512) NULL,
	[Column_No_252] [datetime] NULL,
	[Column_No_253] [int] NULL,
	[Column_No_254] [xml] NULL,
	[Column_No_255] [money] NULL,
	[Column_No_256] [numeric](18, 0) NULL,
	[Column_No_257] [nvarchar](max) NULL,
	[Column_No_258] [bit] NULL,
	[Column_No_259] [uniqueidentifier] NULL,
	[Column_No_26] [numeric](18, 0) NULL,
	[Column_No_260] [image] NULL,
	[Column_No_261] [nvarchar](512) NULL,
	[Column_No_262] [datetime] NULL,
	[Column_No_263] [int] NULL,
	[Column_No_264] [xml] NULL,
	[Column_No_265] [money] NULL,
	[Column_No_266] [numeric](18, 0) NULL,
	[Column_No_267] [nvarchar](max) NULL,
	[Column_No_268] [bit] NULL,
	[Column_No_269] [uniqueidentifier] NULL,
	[Column_No_27] [nvarchar](max) NULL,
	[Column_No_270] [image] NULL,
	[Column_No_271] [nvarchar](512) NULL,
	[Column_No_272] [datetime] NULL,
	[Column_No_273] [int] NULL,
	[Column_No_274] [xml] NULL,
	[Column_No_275] [money] NULL,
	[Column_No_276] [numeric](18, 0) NULL,
	[Column_No_277] [nvarchar](max) NULL,
	[Column_No_278] [bit] NULL,
	[Column_No_279] [uniqueidentifier] NULL,
	[Column_No_28] [bit] NULL,
	[Column_No_280] [image] NULL,
	[Column_No_281] [nvarchar](512) NULL,
	[Column_No_282] [datetime] NULL,
	[Column_No_283] [int] NULL,
	[Column_No_284] [xml] NULL,
	[Column_No_285] [money] NULL,
	[Column_No_286] [numeric](18, 0) NULL,
	[Column_No_287] [nvarchar](max) NULL,
	[Column_No_288] [bit] NULL,
	[Column_No_289] [uniqueidentifier] NULL,
	[Column_No_29] [uniqueidentifier] NULL,
	[Column_No_290] [image] NULL,
	[Column_No_291] [nvarchar](512) NULL,
	[Column_No_292] [datetime] NULL,
	[Column_No_293] [int] NULL,
	[Column_No_294] [xml] NULL,
	[Column_No_295] [money] NULL,
	[Column_No_296] [numeric](18, 0) NULL,
	[Column_No_297] [nvarchar](max) NULL,
	[Column_No_298] [bit] NULL,
	[Column_No_299] [uniqueidentifier] NULL,
	[Column_No_3] [int] NULL,
	[Column_No_30] [image] NULL,
	[Column_No_300] [image] NULL,
	[Column_No_31] [nvarchar](512) NULL,
	[Column_No_32] [datetime] NULL,
	[Column_No_33] [int] NULL,
	[Column_No_34] [xml] NULL,
	[Column_No_35] [money] NULL,
	[Column_No_36] [numeric](18, 0) NULL,
	[Column_No_37] [nvarchar](max) NULL,
	[Column_No_38] [bit] NULL,
	[Column_No_39] [uniqueidentifier] NULL,
	[Column_No_4] [xml] NULL,
	[Column_No_40] [image] NULL,
	[Column_No_41] [nvarchar](512) NULL,
	[Column_No_42] [datetime] NULL,
	[Column_No_43] [int] NULL,
	[Column_No_44] [xml] NULL,
	[Column_No_45] [money] NULL,
	[Column_No_46] [numeric](18, 0) NULL,
	[Column_No_47] [nvarchar](max) NULL,
	[Column_No_48] [bit] NULL,
	[Column_No_49] [uniqueidentifier] NULL,
	[Column_No_5] [money] NULL,
	[Column_No_50] [image] NULL,
	[Column_No_51] [nvarchar](512) NULL,
	[Column_No_52] [datetime] NULL,
	[Column_No_53] [int] NULL,
	[Column_No_54] [xml] NULL,
	[Column_No_55] [money] NULL,
	[Column_No_56] [numeric](18, 0) NULL,
	[Column_No_57] [nvarchar](max) NULL,
	[Column_No_58] [bit] NULL,
	[Column_No_59] [uniqueidentifier] NULL,
	[Column_No_6] [numeric](18, 0) NULL,
	[Column_No_60] [image] NULL,
	[Column_No_61] [nvarchar](512) NULL,
	[Column_No_62] [datetime] NULL,
	[Column_No_63] [int] NULL,
	[Column_No_64] [xml] NULL,
	[Column_No_65] [money] NULL,
	[Column_No_66] [numeric](18, 0) NULL,
	[Column_No_67] [nvarchar](max) NULL,
	[Column_No_68] [bit] NULL,
	[Column_No_69] [uniqueidentifier] NULL,
	[Column_No_7] [nvarchar](max) NULL,
	[Column_No_70] [image] NULL,
	[Column_No_71] [nvarchar](512) NULL,
	[Column_No_72] [datetime] NULL,
	[Column_No_73] [int] NULL,
	[Column_No_74] [xml] NULL,
	[Column_No_75] [money] NULL,
	[Column_No_76] [numeric](18, 0) NULL,
	[Column_No_77] [nvarchar](max) NULL,
	[Column_No_78] [bit] NULL,
	[Column_No_79] [uniqueidentifier] NULL,
	[Column_No_8] [bit] NULL,
	[Column_No_80] [image] NULL,
	[Column_No_81] [nvarchar](512) NULL,
	[Column_No_82] [datetime] NULL,
	[Column_No_83] [int] NULL,
	[Column_No_84] [xml] NULL,
	[Column_No_85] [money] NULL,
	[Column_No_86] [numeric](18, 0) NULL,
	[Column_No_87] [nvarchar](max) NULL,
	[Column_No_88] [bit] NULL,
	[Column_No_89] [uniqueidentifier] NULL,
	[Column_No_9] [uniqueidentifier] NULL,
	[Column_No_90] [image] NULL,
	[Column_No_91] [nvarchar](512) NULL,
	[Column_No_92] [datetime] NULL,
	[Column_No_93] [int] NULL,
	[Column_No_94] [xml] NULL,
	[Column_No_95] [money] NULL,
	[Column_No_96] [numeric](18, 0) NULL,
	[Column_No_97] [nvarchar](max) NULL,
	[Column_No_98] [bit] NULL,
	[Column_No_99] [uniqueidentifier] NULL,
	[Is_Deleted] [bit] NOT NULL,
	[Modified_Date] [datetime] NOT NULL,
	[Test_Id] [int] NOT NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [int] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Examples_DimExampleTablewith300Fields_DID] PRIMARY KEY CLUSTERED 
(
	[DimExampleTablewith300Fields_did] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Examples]
) ON [Examples] TEXTIMAGE_ON [Examples]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[DimExampleTypeConversion]') AND type in (N'U'))
BEGIN
CREATE TABLE [Examples].[DimExampleTypeConversion](
	[DimExampleTypeConversion_did] [bigint] IDENTITY(1,1) NOT NULL,
	[A_Text_Field] [nvarchar](512) NOT NULL,
	[ExampleTypeConversion_Id] [int] NOT NULL,
	[Integer_Style_Timestamp] [datetime] NOT NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [int] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Examples_DimExampleTypeConversion_DID] PRIMARY KEY CLUSTERED 
(
	[DimExampleTypeConversion_did] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Examples]
) ON [Examples]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[DimTractors]') AND type in (N'U'))
BEGIN
CREATE TABLE [Examples].[DimTractors](
	[DimTractors_did] [bigint] IDENTITY(1,1) NOT NULL,
	[Catalogue_Number] [int] NULL,
	[CountryOfManufacture_Id] [int] NULL,
	[Manufacturer_Id] [int] NULL,
	[Model_Family_Name] [nvarchar](512) NULL,
	[Record_Deleted] [bit] NOT NULL,
	[Record_Last_Updated] [datetime] NOT NULL,
	[Tractor_Id] [int] NOT NULL,
	[Tractor_Model_Name] [nvarchar](512) NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [int] NULL,
	[DataState_Id] [int] NULL,
 CONSTRAINT [PK_Examples_DimTractors_DID] PRIMARY KEY CLUSTERED 
(
	[DimTractors_did] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Examples]
) ON [Examples]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[DimTractorsSCDType2]') AND type in (N'U'))
BEGIN
CREATE TABLE [Examples].[DimTractorsSCDType2](
	[DimTractorsSCDType2_did] [bigint] IDENTITY(1,1) NOT NULL,
	[Catalogue_Number] [int] NULL,
	[CountryOfManufacture_Id] [int] NULL,
	[Manufacturer_Id] [int] NULL,
	[Model_Family_Name] [nvarchar](512) NULL,
	[Record_Deleted] [bit] NOT NULL,
	[Record_Last_Updated] [datetime] NOT NULL,
	[Tractor_Id] [int] NOT NULL,
	[Tractor_Model_Name] [nvarchar](512) NULL,
	[SourceSystem_Id] [int] NOT NULL,
	[ETLBatch_Id] [int] NULL,
	[DataState_Id] [int] NULL,
	[EffectiveStart] [datetime] NOT NULL,
	[EffectiveFinish] [datetime] NULL,
	[ActiveRecord] [bit] NOT NULL,
 CONSTRAINT [PK_Examples_DimTractorsSCDType2_DID] PRIMARY KEY CLUSTERED 
(
	[DimTractorsSCDType2_did] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Examples]
) ON [Examples]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Example_Staging].[DF__ExampleCo__Sourc__56B3DD81]') AND type = 'D')
BEGIN
ALTER TABLE [Example_Staging].[ExampleColumnNameConversion] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimCompos__Recor__40C49C62]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimCompositeKeyExample] ADD  DEFAULT ((0)) FOR [Record_Deleted]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimCompos__Recor__41B8C09B]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimCompositeKeyExample] ADD  DEFAULT (getdate()) FOR [Record_Last_Updated]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimCompos__Sourc__42ACE4D4]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimCompositeKeyExample] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimExampl__Sourc__59904A2C]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimExampleColumnNameConversion] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimExampl__Sourc__74444068]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimExampleOfPausingETLBuilds] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimExampl__Is_De__66EA454A]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimExampleTablewith300Fields] ADD  DEFAULT ((0)) FOR [Is_Deleted]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimExampl__Modif__67DE6983]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimExampleTablewith300Fields] ADD  DEFAULT (getdate()) FOR [Modified_Date]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimExampl__Sourc__68D28DBC]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimExampleTablewith300Fields] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimExampl__Sourc__4E1E9780]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimExampleTypeConversion] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Recor__2057CCD0]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractors] ADD  DEFAULT ((0)) FOR [Record_Deleted]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Recor__214BF109]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractors] ADD  DEFAULT (getdate()) FOR [Record_Last_Updated]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Sourc__22401542]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractors] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Recor__2F9A1060]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractorsSCDType2] ADD  DEFAULT ((0)) FOR [Record_Deleted]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Recor__308E3499]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractorsSCDType2] ADD  DEFAULT (getdate()) FOR [Record_Last_Updated]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Sourc__318258D2]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractorsSCDType2] ADD  DEFAULT ((1)) FOR [SourceSystem_Id]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Effec__32767D0B]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractorsSCDType2] ADD  DEFAULT (getdate()) FOR [EffectiveStart]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[Examples].[DF__DimTracto__Activ__336AA144]') AND type = 'D')
BEGIN
ALTER TABLE [Examples].[DimTractorsSCDType2] ADD  DEFAULT ((1)) FOR [ActiveRecord]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimCompositeKeyExample]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimCompositeKeyExample] AS' 
END
GO
 
/*
--=====================================================================================================================
-- MANUAL TESTING UTILITY ROUTINES FOR [Examples].[Load_DimCompositeKeyExample]
------------------------------------------------------------------------
-- Records in Dimension
SELECT * FROM	    [Examples].[DimCompositeKeyExample]
SELECT COUNT(*) FROM [Examples].[DimCompositeKeyExample]

-- Records in Staging
SELECT * FROM	     [Example_Staging].[CompositeKeyExample]
SELECT COUNT(*) FROM  [Example_Staging].[CompositeKeyExample]

-- To start from absolute scratch with no pre-existing logs, restaged records in the staging table and an empty dimension table
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 1,1,1,1,1

-- See the logs of previous ETL runs
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,0,0,1

-- Clear the logs for this dimension
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 1,0,0,0,0

-- Clear the logs, restage the test data and truncate the dimension
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 1,1,1,0,0

-- To restage data in the staging table 
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,1,0,0

-- To run process on whatever is in the staging table and show log
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,0,1,1

-- To Rerun the process on restaged data in the staging table 
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,1,1,1

-- To Rerun the process on previously ingested data in the staging table 
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,1,1,1 -- refill staging and run load routine again, show log, should be updaes but no new records
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,0,1,1 -- try reingesting staged data again - staging should be empty of records and log should show no change since last run

-- To test deletions
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,1,0,0 -- restage the data
UPDATE   [Example_Staging].[CompositeKeyExample] 
    SET [Record_Deleted] = 1 WHERE Staging_Id < 3 -- flag the first 2 records as deleted
EXECUTE  [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE   [Examples].[Load_DimCompositeKeyExample_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, then in one batch there were 2 deletions and ModelTableSampleRows-2 updates
SELECT * FROM	    [Examples].[DimCompositeKeyExample] -- checkout the records in the dimension to ensure the flagged record(s) have been deleted



--===================================================================================================================== 
*/

ALTER PROCEDURE [Examples].[Load_DimCompositeKeyExample]
AS 
BEGIN
--***************************************************************************************
-- This is an ETL routine that conducts data (new or updated or deleted as well as possibly stale/redundant)  
-- from the staging table [Example_Staging].[CompositeKeyExample] to the 
-- dimension table [Examples].[DimCompositeKeyExample]
-----------------------------------------------------------------------------------------

SET NOCOUNT ON
-- (Uncomment if required) SET DATEFORMAT dmy 

-- Ensure that the dimension has an unknown "-1" key record holding default values
-- for when the fact table has no proper key into the dimension
DECLARE @ErrorCode int 
SET @ErrorCode = 0 
EXECUTE @ErrorCode = [Examples].[Load_DimCompositeKeyExample_SetDefaultValues]
IF @ErrorCode <> 0
BEGIN
    RETURN
END
   
DECLARE @UnloadedCount int
SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[CompositeKeyExample] WHERE ETLBatch_Id IS NULL)
WHILE @UnloadedCount > 0
    BEGIN 

	   DECLARE @Batch_ID bigint  
	   DECLARE @Step_ID bigint  
	   DECLARE @ETLLoadStatus_Id int  
	   DECLARE @ProcessName varchar(50)
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit

	    SET @ProcessName = '[Examples].[Load_DimCompositeKeyExample]'
	    EXECUTE @Batch_ID = [ETL].[InitiateETLBatch] @ProcessName	
	
	   
	    EXECUTE [Examples].[Load_DimCompositeKeyExample_Flag_Records_For_Loading] @Batch_ID

	    SET @ETLLoadStatus_Id = 3

	    EXECUTE [Examples].[Load_DimCompositeKeyExample_HandleDeletedRecords] @Batch_ID

	   -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [ETL].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Inserting New Records into Dimension' , NULL;

	    BEGIN TRY 


				INSERT INTO [Examples].[DimCompositeKeyExample](
					  [CompositeKeyExample_Id]
					   , [CountryOfManufacture_Id]
					   , [Manufacturer_Id]
					   , [Record_Deleted]
					   , [Record_Last_Updated]
					   , [Tractor_Model_Name]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  ,[DataState_Id]
				)

				SELECT 
					  [CompositeKeyExample_Id]
					   , [CountryOfManufacture_Id]
					   , [Manufacturer_Id]
					   , [Record_Deleted]
					   , [Record_Last_Updated]
					   , [TractorModelName]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  , 4
				FROM
					   [Example_Staging].[CompositeKeyExample]

				WHERE 				
				    [Example_Staging].[CompositeKeyExample].[ETLBatch_Id] = @Batch_ID
				    AND
				   [Example_Staging].[CompositeKeyExample].[Record_Deleted] = 0
				    AND
				    [Example_Staging].[CompositeKeyExample].[Staging_ID] NOT IN 
					(
						SELECT src.[Staging_ID]
						FROM [Example_Staging].[CompositeKeyExample] src
						INNER JOIN [Examples].[DimCompositeKeyExample] dest 
						ON dest.[CompositeKeyExample_Id] =  src.[CompositeKeyExample_Id]
						  AND dest.[CountryOfManufacture_Id] =  src.[CountryOfManufacture_Id]
						  AND dest.[Manufacturer_Id] =  src.[Manufacturer_Id]
						  AND dest.[Tractor_Model_Name] =  src.[TractorModelName]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
						WHERE
						    src.[ETLBatch_Id] = @Batch_ID		
						    AND
						    src.[DataState_Id] = 1
						    AND  src.[Record_Deleted] = 0

	)



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Inserting new records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode
			 --------------------------------------------------------------------

		 END TRY
		  BEGIN CATCH

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [Example_Staging].[CompositeKeyExample] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH


	    SET @ETLLoadStatus_Id = 4

	    -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Updating dimension records from staging data' , NULL;
	    BEGIN TRY



				    UPDATE dest
					  SET 
						 dest.[Catalogue_Number] = src.[Catalogue_Number]
					   , dest.[Model_Family_Name] = src.[ModelFamilyName]
					   , dest.[Record_Deleted] = src.[Record_Deleted]
					   , dest.[Record_Last_Updated] = src.[Record_Last_Updated]
					   , dest.[ETLBatch_Id] = src.[ETLBatch_Id]
						 , [DataState_Id] = 5
					 FROM 
						  [Examples].[DimCompositeKeyExample] dest
					 INNER JOIN  [Example_Staging].[CompositeKeyExample] src  
					 ON  
					 dest.[CompositeKeyExample_Id] =  src.[CompositeKeyExample_Id]
						  AND dest.[CountryOfManufacture_Id] =  src.[CountryOfManufacture_Id]
						  AND dest.[Manufacturer_Id] =  src.[Manufacturer_Id]
						  AND dest.[Tractor_Model_Name] =  src.[TractorModelName]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
					   WHERE
					  dest.[Record_Last_Updated] <=  src.[Record_Last_Updated] AND 
					  
					   src.[ETLBatch_Id] = @Batch_ID		
					   AND
					   src.DataState_Id = 1
					   AND  src.[Record_Deleted] = 0



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Updating records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode

			 --------------------------------------------------------------------	
			  
			 -- Records have been ingested, can delete them from staging.
			 DELETE
			 FROM [Example_Staging].[CompositeKeyExample]  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1

			 
			 

	   END TRY
		  BEGIN CATCH
  		 
			  -- ON-ERROR CLEANUP OF BATCH RECORDS ------------------------------
		   		  
			  -- The new records had their non-nullable fields inserted successfully 
			  -- in the earlier INSERT TRY-CATCH section 
			  -- BUT there was a major problem with the fields being UPDATED,
			  -- we need to remove the new key records until the problem is resolved

			  -- AS the UPDATE has been rolled back, all records with the current ETLBatch_ID
			  -- must be new records

			  DELETE FROM [Examples].[DimCompositeKeyExample]
			   WHERE [ETLBatch_Id] = @Batch_ID 		  

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [dbo].[TestTable_NoModifiedDatePresent] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH
 

	   SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[CompositeKeyExample] WHERE ETLBatch_Id IS NULL)
    END
END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimCompositeKeyExample_Flag_Records_For_Loading]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimCompositeKeyExample_Flag_Records_For_Loading] AS' 
END
GO
/* -- DEBUGGING UTILITY TO RESET DATA IN STAGING -----------------------------------
UPDATE [Example_Staging].[CompositeKeyExample]
               SET 	 [ETLBatch_Id] = NULL
			, DataState_Id  = NULL 
*/

ALTER PROCEDURE  [Examples].[Load_DimCompositeKeyExample_Flag_Records_For_Loading]
( @Batch_ID bigint )
AS
BEGIN

    BEGIN TRY

	   DECLARE @StepId int
	   DECLARE @ETLLoadStatusId int
	   SET @ETLLoadStatusId = 2    /* = "Identifying Batch Records In Staging"*/
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit
	   DECLARE @ErrorCode int

	   SET @Message = 'Flagging operation failed'
	   SET  @RecordsAffected = 0
	   SET @Success = 0
	   SET @ErrorCode = NULL

	   EXECUTE @StepId = [etl].[AddETLBatchStepStatus] @Batch_ID , 2 , 'Flagging Started ...' , NULL;
	    ;WITH CandidateRecords
		  AS (
		  SELECT TOP 10000 Staging_ID
			    FROM [Example_Staging].[CompositeKeyExample]
			    WHERE
				[ETLBatch_Id] IS NULL
			    ORDER BY Staging_ID ASC
		  )
		  UPDATE s
		  SET [ETLBatch_Id]	  = @Batch_ID ,
			 [DataState_Id]  = 1
			 FROM Example_Staging.CompositeKeyExample s
				 INNER JOIN   CandidateRecords c ON c.Staging_Id = s.Staging_Id

		  SET @RecordsAffected = @@ROWCOUNT

		  SET @Message = 'Flagging operation succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
		  @StepId
		  , @ETLLoadStatusId
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode

    END TRY
    BEGIN CATCH	 
			 
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()    
			 			
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @StepId
			 , @ETLLoadStatusId
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode ;
			
			RAISERROR(@Message,16,1)
    END CATCH
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimCompositeKeyExample_HandleDeletedRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimCompositeKeyExample_HandleDeletedRecords] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimCompositeKeyExample_HandleDeletedRecords]
(@Batch_Id bigint)
AS
BEGIN
    DECLARE @Message nvarchar( 255 )
    DECLARE @RecordsAffected int
    DECLARE @Success bit
    DECLARE @ErrorCode int 
    DECLARE @Step_ID bigint  
    DECLARE @ETLLoadStatus_Id int 
    
    SET @ETLLoadStatus_Id = 4 

     EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Deleting flagged records from dimension' , NULL;
    BEGIN TRY 

		  ;WITH StagedDeletedRecords AS
		  (
			 SELECT
			 DimCompositeKeyExample_DID
				   FROM
					   [Example_Staging].[CompositeKeyExample] src
					   INNER JOIN [Examples].[DimCompositeKeyExample] dest 
						  ON 
							 dest.[CompositeKeyExample_Id] =  src.[CompositeKeyExample_Id]
						  AND dest.[CountryOfManufacture_Id] =  src.[CountryOfManufacture_Id]
						  AND dest.[Manufacturer_Id] =  src.[Manufacturer_Id]
						  AND dest.[Tractor_Model_Name] =  src.[TractorModelName]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
				   WHERE
				   src.Record_Deleted  = 1
				   AND
				   src.[DataState_Id] = 1
				   AND
				   src.ETLBatch_Id = @Batch_Id     
		  )
		  DELETE FROM [Examples].[DimCompositeKeyExample]
			WHERE		 DimCompositeKeyExample_DID IN
			( SELECT DimCompositeKeyExample_DID
				    FROM StagedDeletedRecords )
				    
 
	
		  -- SUCCESS LOGGING -------------------------------------------------
		  SET @RecordsAffected = @@ROWCOUNT
		  SET @Message = 'Deleting flagged records succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL 
		  
		  UPDATE  [Example_Staging].[CompositeKeyExample]
		  SET DataState_Id = 2
		  FROM   [Example_Staging].[CompositeKeyExample]
				   WHERE
				   [Record_Deleted]  = 1
				   AND
				   [DataState_Id] = 1
				   AND
				   ETLBatch_Id = @Batch_Id    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
			 @Step_Id
		  , @ETLLoadStatus_Id
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode
		  --------------------------------------------------------------------
	   END TRY
	   BEGIN CATCH

		  -- FAILURE LOGGING -------------------------------------------------		  	  
		  SET @RecordsAffected = -1
		  SET @Message = ERROR_MESSAGE()
		  SET @Success = 0
		  SET @ErrorCode = ERROR_NUMBER()
		  
		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
					   @Step_Id
				    , @ETLLoadStatus_Id
				    , @Message
				    , @RecordsAffected
				    , @Success
				    , @ErrorCode   ;
		  --------------------------------------------------------------------

		 RAISERROR(@Message, 16, 1);
	   END CATCH
END	  
		  

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimCompositeKeyExample_SetDefaultValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimCompositeKeyExample_SetDefaultValues] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimCompositeKeyExample_SetDefaultValues]
AS 
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @Message nvarchar(1024)
BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM [Examples].[DimCompositeKeyExample] WHERE [DimCompositeKeyExample_DID] = -1)
    BEGIN

    SET IDENTITY_INSERT [Examples].[DimCompositeKeyExample] ON

    INSERT INTO [Examples].[DimCompositeKeyExample](
		 [DimCompositeKeyExample_did]
    , [Catalogue_Number]
    , [CompositeKeyExample_Id]
    , [CountryOfManufacture_Id]
    , [Manufacturer_Id]
    , [Model_Family_Name]
    , [Record_Deleted]
    , [Record_Last_Updated]
    , [Tractor_Model_Name]
    , [SourceSystem_Id]
    , [ETLBatch_Id]
    , [DataState_Id]
    )

    SELECT 
		 -1
	    , NULL
,0
,0
,0
,NULL
,0
,'Jan 1 1900'
,'N/A'
,0
,0
,6

    SET IDENTITY_INSERT [Examples].[DimCompositeKeyExample] OFF
	RETURN 0
    END 

END TRY
BEGIN CATCH
   
     SET @Message = '
-- ### BI BUILDER ERROR MESSAGE ####################################################################################################
ERROR:  [Examples].[Load_DimCompositeKeyExample_SetDefaultValues] has attempted to insert a record that violates a CHECK CONSTRAINT.
			 
Take a look at the routine [Sales].[Load_DimSalesOrderDetails_SetDefaultValues] and edit it so it inserts the default record OK.

ERROR MESSAGE FROM SQL SERVER: '+ERROR_MESSAGE()+'
-- ###############################################################################################################################
'
    RAISERROR(@Message, 16,1)    
    
END CATCH

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleColumnNameConversion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleColumnNameConversion] AS' 
END
GO
 
/*
--=====================================================================================================================
-- MANUAL TESTING UTILITY ROUTINES FOR [Examples].[Load_DimExampleColumnNameConversion]
------------------------------------------------------------------------
-- Records in Dimension
SELECT * FROM	    [Examples].[DimExampleColumnNameConversion]
SELECT COUNT(*) FROM [Examples].[DimExampleColumnNameConversion]

-- Records in Staging
SELECT * FROM	     [Example_Staging].[ExampleColumnNameConversion]
SELECT COUNT(*) FROM  [Example_Staging].[ExampleColumnNameConversion]

-- To start from absolute scratch with no pre-existing logs, restaged records in the staging table and an empty dimension table
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 1,1,1,1,1

-- See the logs of previous ETL runs
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,0,0,1

-- Clear the logs for this dimension
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 1,0,0,0,0

-- Clear the logs, restage the test data and truncate the dimension
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 1,1,1,0,0

-- To restage data in the staging table 
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,1,0,0

-- To run process on whatever is in the staging table and show log
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,0,1,1

-- To Rerun the process on restaged data in the staging table 
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,1,1,1

-- To Rerun the process on previously ingested data in the staging table 
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,1,1,1 -- refill staging and run load routine again, show log, should be updaes but no new records
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,0,1,1 -- try reingesting staged data again - staging should be empty of records and log should show no change since last run

-- To test deletions
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,1,0,0 -- restage the data
UPDATE   [Example_Staging].[ExampleColumnNameConversion] 
    SET [IsDeleted] = 1 WHERE Staging_Id < 3 -- flag the first 2 records as deleted
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE   [Examples].[Load_DimExampleColumnNameConversion_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, then in one batch there were 2 deletions and ModelTableSampleRows-2 updates
SELECT * FROM	    [Examples].[DimExampleColumnNameConversion] -- checkout the records in the dimension to ensure the flagged record(s) have been deleted



--===================================================================================================================== 
*/

ALTER PROCEDURE [Examples].[Load_DimExampleColumnNameConversion]
AS 
BEGIN
--***************************************************************************************
-- This is an ETL routine that conducts data (new or updated or deleted as well as possibly stale/redundant)  
-- from the staging table [Example_Staging].[ExampleColumnNameConversion] to the 
-- dimension table [Examples].[DimExampleColumnNameConversion]
-----------------------------------------------------------------------------------------

SET NOCOUNT ON
-- (Uncomment if required) SET DATEFORMAT dmy 

-- Ensure that the dimension has an unknown "-1" key record holding default values
-- for when the fact table has no proper key into the dimension
DECLARE @ErrorCode int 
SET @ErrorCode = 0 
EXECUTE @ErrorCode = [Examples].[Load_DimExampleColumnNameConversion_SetDefaultValues]
IF @ErrorCode <> 0
BEGIN
    RETURN
END
   
DECLARE @UnloadedCount int
SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleColumnNameConversion] WHERE ETLBatch_Id IS NULL)
WHILE @UnloadedCount > 0
    BEGIN 

	   DECLARE @Batch_ID bigint  
	   DECLARE @Step_ID bigint  
	   DECLARE @ETLLoadStatus_Id int  
	   DECLARE @ProcessName varchar(50)
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit

	    SET @ProcessName = '[Examples].[Load_DimExampleColumnNameConversion]'
	    EXECUTE @Batch_ID = [ETL].[InitiateETLBatch] @ProcessName	
	
	   
	    EXECUTE [Examples].[Load_DimExampleColumnNameConversion_Flag_Records_For_Loading] @Batch_ID

	    SET @ETLLoadStatus_Id = 3

	    EXECUTE [Examples].[Load_DimExampleColumnNameConversion_HandleDeletedRecords] @Batch_ID

	   -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [ETL].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Inserting New Records into Dimension' , NULL;

	    BEGIN TRY 


				INSERT INTO [Examples].[DimExampleColumnNameConversion](
					  [Is_Deleted]
					   , [Record_Last_Modified]
					   , [ThisKeyWontChangeName_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  ,[DataState_Id]
				)

				SELECT 
					  [IsDeleted]
					   , [Record_Last_Modified]
					   , [ThisKeyWontChangeName_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  , 4
				FROM
					   [Example_Staging].[ExampleColumnNameConversion]

				WHERE 				
				    [Example_Staging].[ExampleColumnNameConversion].[ETLBatch_Id] = @Batch_ID
				    AND
				   [Example_Staging].[ExampleColumnNameConversion].[IsDeleted] = 0
				    AND
				    [Example_Staging].[ExampleColumnNameConversion].[Staging_ID] NOT IN 
					(
						SELECT src.[Staging_ID]
						FROM [Example_Staging].[ExampleColumnNameConversion] src
						INNER JOIN [Examples].[DimExampleColumnNameConversion] dest 
						ON dest.[ThisKeyWontChangeName_Id] =  src.[ThisKeyWontChangeName_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
						WHERE
						    src.[ETLBatch_Id] = @Batch_ID		
						    AND
						    src.[DataState_Id] = 1
						    AND  src.[IsDeleted] = 0

	)



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Inserting new records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode
			 --------------------------------------------------------------------

		 END TRY
		  BEGIN CATCH

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [Example_Staging].[ExampleColumnNameConversion] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH


	    SET @ETLLoadStatus_Id = 4

	    -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Updating dimension records from staging data' , NULL;
	    BEGIN TRY



				    UPDATE dest
					  SET 
						 dest.[Customer_Start_Date] = src.[Cust_St_Dt]
					   , dest.[Is_Deleted] = src.[IsDeleted]
					   , dest.[Record_Last_Modified] = src.[Record_Last_Modified]
					   , dest.[Salesforce_Type_Column_Name] = src.[SalesforceTypeColumnName__c]
					   , dest.[This_Column_Will_End_Up_With_Underscores] = src.[ThisColumnWillEndUpWithUnderscores]
					   , dest.[ETLBatch_Id] = src.[ETLBatch_Id]
						 , [DataState_Id] = 5
					 FROM 
						  [Examples].[DimExampleColumnNameConversion] dest
					 INNER JOIN  [Example_Staging].[ExampleColumnNameConversion] src  
					 ON  
					 dest.[ThisKeyWontChangeName_Id] =  src.[ThisKeyWontChangeName_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
					   WHERE
					  dest.[Record_Last_Modified] <=  src.[Record_Last_Modified] AND 
					  
					   src.[ETLBatch_Id] = @Batch_ID		
					   AND
					   src.DataState_Id = 1
					   AND  src.[IsDeleted] = 0



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Updating records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode

			 --------------------------------------------------------------------	
			  
			 -- Records have been ingested, can delete them from staging.
			 DELETE
			 FROM [Example_Staging].[ExampleColumnNameConversion]  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1

			 
			 

	   END TRY
		  BEGIN CATCH
  		 
			  -- ON-ERROR CLEANUP OF BATCH RECORDS ------------------------------
		   		  
			  -- The new records had their non-nullable fields inserted successfully 
			  -- in the earlier INSERT TRY-CATCH section 
			  -- BUT there was a major problem with the fields being UPDATED,
			  -- we need to remove the new key records until the problem is resolved

			  -- AS the UPDATE has been rolled back, all records with the current ETLBatch_ID
			  -- must be new records

			  DELETE FROM [Examples].[DimExampleColumnNameConversion]
			   WHERE [ETLBatch_Id] = @Batch_ID 		  

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [dbo].[TestTable_NoModifiedDatePresent] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH
 

	   SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleColumnNameConversion] WHERE ETLBatch_Id IS NULL)
    END
END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleColumnNameConversion_Flag_Records_For_Loading]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleColumnNameConversion_Flag_Records_For_Loading] AS' 
END
GO
/* -- DEBUGGING UTILITY TO RESET DATA IN STAGING -----------------------------------
UPDATE [Example_Staging].[ExampleColumnNameConversion]
               SET 	 [ETLBatch_Id] = NULL
			, DataState_Id  = NULL 
*/

ALTER PROCEDURE  [Examples].[Load_DimExampleColumnNameConversion_Flag_Records_For_Loading]
( @Batch_ID bigint )
AS
BEGIN

    BEGIN TRY

	   DECLARE @StepId int
	   DECLARE @ETLLoadStatusId int
	   SET @ETLLoadStatusId = 2    /* = "Identifying Batch Records In Staging"*/
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit
	   DECLARE @ErrorCode int

	   SET @Message = 'Flagging operation failed'
	   SET  @RecordsAffected = 0
	   SET @Success = 0
	   SET @ErrorCode = NULL

	   EXECUTE @StepId = [etl].[AddETLBatchStepStatus] @Batch_ID , 2 , 'Flagging Started ...' , NULL;
	    ;WITH CandidateRecords
		  AS (
		  SELECT TOP 10000 Staging_ID
			    FROM [Example_Staging].[ExampleColumnNameConversion]
			    WHERE
				[ETLBatch_Id] IS NULL
			    ORDER BY Staging_ID ASC
		  )
		  UPDATE s
		  SET [ETLBatch_Id]	  = @Batch_ID ,
			 [DataState_Id]  = 1
			 FROM Example_Staging.ExampleColumnNameConversion s
				 INNER JOIN   CandidateRecords c ON c.Staging_Id = s.Staging_Id

		  SET @RecordsAffected = @@ROWCOUNT

		  SET @Message = 'Flagging operation succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
		  @StepId
		  , @ETLLoadStatusId
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode

    END TRY
    BEGIN CATCH	 
			 
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()    
			 			
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @StepId
			 , @ETLLoadStatusId
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode ;
			
			RAISERROR(@Message,16,1)
    END CATCH
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleColumnNameConversion_HandleDeletedRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleColumnNameConversion_HandleDeletedRecords] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleColumnNameConversion_HandleDeletedRecords]
(@Batch_Id bigint)
AS
BEGIN
    DECLARE @Message nvarchar( 255 )
    DECLARE @RecordsAffected int
    DECLARE @Success bit
    DECLARE @ErrorCode int 
    DECLARE @Step_ID bigint  
    DECLARE @ETLLoadStatus_Id int 
    
    SET @ETLLoadStatus_Id = 4 

     EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Deleting flagged records from dimension' , NULL;
    BEGIN TRY 

		  ;WITH StagedDeletedRecords AS
		  (
			 SELECT
			 DimExampleColumnNameConversion_DID
				   FROM
					   [Example_Staging].[ExampleColumnNameConversion] src
					   INNER JOIN [Examples].[DimExampleColumnNameConversion] dest 
						  ON 
							 dest.[ThisKeyWontChangeName_Id] =  src.[ThisKeyWontChangeName_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
				   WHERE
				   src.IsDeleted  = 1
				   AND
				   src.[DataState_Id] = 1
				   AND
				   src.ETLBatch_Id = @Batch_Id     
		  )
		  DELETE FROM [Examples].[DimExampleColumnNameConversion]
			WHERE		 DimExampleColumnNameConversion_DID IN
			( SELECT DimExampleColumnNameConversion_DID
				    FROM StagedDeletedRecords )
				    
 
	
		  -- SUCCESS LOGGING -------------------------------------------------
		  SET @RecordsAffected = @@ROWCOUNT
		  SET @Message = 'Deleting flagged records succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL 
		  
		  UPDATE  [Example_Staging].[ExampleColumnNameConversion]
		  SET DataState_Id = 2
		  FROM   [Example_Staging].[ExampleColumnNameConversion]
				   WHERE
				   [IsDeleted]  = 1
				   AND
				   [DataState_Id] = 1
				   AND
				   ETLBatch_Id = @Batch_Id    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
			 @Step_Id
		  , @ETLLoadStatus_Id
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode
		  --------------------------------------------------------------------
	   END TRY
	   BEGIN CATCH

		  -- FAILURE LOGGING -------------------------------------------------		  	  
		  SET @RecordsAffected = -1
		  SET @Message = ERROR_MESSAGE()
		  SET @Success = 0
		  SET @ErrorCode = ERROR_NUMBER()
		  
		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
					   @Step_Id
				    , @ETLLoadStatus_Id
				    , @Message
				    , @RecordsAffected
				    , @Success
				    , @ErrorCode   ;
		  --------------------------------------------------------------------

		 RAISERROR(@Message, 16, 1);
	   END CATCH
END	  
		  

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleColumnNameConversion_SetDefaultValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleColumnNameConversion_SetDefaultValues] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleColumnNameConversion_SetDefaultValues]
AS 
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @Message nvarchar(1024)
BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM [Examples].[DimExampleColumnNameConversion] WHERE [DimExampleColumnNameConversion_DID] = -1)
    BEGIN

    SET IDENTITY_INSERT [Examples].[DimExampleColumnNameConversion] ON

    INSERT INTO [Examples].[DimExampleColumnNameConversion](
		 [DimExampleColumnNameConversion_did]
    , [Customer_Start_Date]
    , [Is_Deleted]
    , [Record_Last_Modified]
    , [Salesforce_Type_Column_Name]
    , [This_Column_Will_End_Up_With_Underscores]
    , [ThisKeyWontChangeName_Id]
    , [SourceSystem_Id]
    , [ETLBatch_Id]
    , [DataState_Id]
    )

    SELECT 
		 -1
	    , NULL
,0
,'Jan 1 1900'
,NULL
,NULL
,0
,0
,0
,6

    SET IDENTITY_INSERT [Examples].[DimExampleColumnNameConversion] OFF
	RETURN 0
    END 

END TRY
BEGIN CATCH
   
     SET @Message = '
-- ### BI BUILDER ERROR MESSAGE ####################################################################################################
ERROR:  [Examples].[Load_DimExampleColumnNameConversion_SetDefaultValues] has attempted to insert a record that violates a CHECK CONSTRAINT.
			 
Take a look at the routine [Sales].[Load_DimSalesOrderDetails_SetDefaultValues] and edit it so it inserts the default record OK.

ERROR MESSAGE FROM SQL SERVER: '+ERROR_MESSAGE()+'
-- ###############################################################################################################################
'
    RAISERROR(@Message, 16,1)    
    
END CATCH

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleOfPausingETLBuilds]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleOfPausingETLBuilds] AS' 
END
GO
 
/*
--=====================================================================================================================
-- MANUAL TESTING UTILITY ROUTINES FOR [Examples].[Load_DimExampleOfPausingETLBuilds]
------------------------------------------------------------------------
-- Records in Dimension
SELECT * FROM	    [Examples].[DimExampleOfPausingETLBuilds]
SELECT COUNT(*) FROM [Examples].[DimExampleOfPausingETLBuilds]

-- Records in Staging
SELECT * FROM	     [Example_Staging].[ExampleOfPausingETLBuilds]
SELECT COUNT(*) FROM  [Example_Staging].[ExampleOfPausingETLBuilds]

-- To start from absolute scratch with no pre-existing logs, restaged records in the staging table and an empty dimension table
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 1,1,1,1,1

-- See the logs of previous ETL runs
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,0,0,1

-- Clear the logs for this dimension
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 1,0,0,0,0

-- Clear the logs, restage the test data and truncate the dimension
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 1,1,1,0,0

-- To restage data in the staging table 
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,1,0,0

-- To run process on whatever is in the staging table and show log
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,0,1,1

-- To Rerun the process on restaged data in the staging table 
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,1,1,1

-- To Rerun the process on previously ingested data in the staging table 
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,1,1,1 -- refill staging and run load routine again, show log, should be updaes but no new records
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,0,1,1 -- try reingesting staged data again - staging should be empty of records and log should show no change since last run

-- To test deletions
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,1,0,0 -- restage the data
UPDATE   [Example_Staging].[ExampleOfPausingETLBuilds] 
    SET [IsDeleted] = 1 WHERE Staging_Id < 3 -- flag the first 2 records as deleted
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE   [Examples].[Load_DimExampleOfPausingETLBuilds_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, then in one batch there were 2 deletions and ModelTableSampleRows-2 updates
SELECT * FROM	    [Examples].[DimExampleOfPausingETLBuilds] -- checkout the records in the dimension to ensure the flagged record(s) have been deleted



--===================================================================================================================== 
*/

ALTER PROCEDURE [Examples].[Load_DimExampleOfPausingETLBuilds]
AS 
BEGIN
--***************************************************************************************
-- This is an ETL routine that conducts data (new or updated or deleted as well as possibly stale/redundant)  
-- from the staging table [Example_Staging].[ExampleOfPausingETLBuilds] to the 
-- dimension table [Examples].[DimExampleOfPausingETLBuilds]
-----------------------------------------------------------------------------------------

SET NOCOUNT ON
-- (Uncomment if required) SET DATEFORMAT dmy 

-- Ensure that the dimension has an unknown "-1" key record holding default values
-- for when the fact table has no proper key into the dimension
DECLARE @ErrorCode int 
SET @ErrorCode = 0 
EXECUTE @ErrorCode = [Examples].[Load_DimExampleOfPausingETLBuilds_SetDefaultValues]
IF @ErrorCode <> 0
BEGIN
    RETURN
END
   
DECLARE @UnloadedCount int
SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleOfPausingETLBuilds] WHERE ETLBatch_Id IS NULL)
WHILE @UnloadedCount > 0
    BEGIN 

	   DECLARE @Batch_ID bigint  
	   DECLARE @Step_ID bigint  
	   DECLARE @ETLLoadStatus_Id int  
	   DECLARE @ProcessName varchar(50)
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit

	    SET @ProcessName = '[Examples].[Load_DimExampleOfPausingETLBuilds]'
	    EXECUTE @Batch_ID = [ETL].[InitiateETLBatch] @ProcessName	
	
	   
	    EXECUTE [Examples].[Load_DimExampleOfPausingETLBuilds_Flag_Records_For_Loading] @Batch_ID

	    SET @ETLLoadStatus_Id = 3

	    EXECUTE [Examples].[Load_DimExampleOfPausingETLBuilds_HandleDeletedRecords] @Batch_ID

	   -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [ETL].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Inserting New Records into Dimension' , NULL;

	    BEGIN TRY 


				INSERT INTO [Examples].[DimExampleOfPausingETLBuilds](
					  [Cust_Id]
					   , [Is_Deleted]
					   , [PrimaryKey_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  ,[DataState_Id]
				)

				SELECT 
					  [Cust_Id]
					   , [IsDeleted]
					   , [PrimaryKey_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  , 4
				FROM
					   [Example_Staging].[ExampleOfPausingETLBuilds]

				WHERE 				
				    [Example_Staging].[ExampleOfPausingETLBuilds].[ETLBatch_Id] = @Batch_ID
				    AND
				   [Example_Staging].[ExampleOfPausingETLBuilds].[IsDeleted] = 0
				    AND
				    [Example_Staging].[ExampleOfPausingETLBuilds].[Staging_ID] NOT IN 
					(
						SELECT src.[Staging_ID]
						FROM [Example_Staging].[ExampleOfPausingETLBuilds] src
						INNER JOIN [Examples].[DimExampleOfPausingETLBuilds] dest 
						ON dest.[PrimaryKey_Id] =  src.[PrimaryKey_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
						WHERE
						    src.[ETLBatch_Id] = @Batch_ID		
						    AND
						    src.[DataState_Id] = 1
						    AND  src.[IsDeleted] = 0

	)



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Inserting new records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode
			 --------------------------------------------------------------------

		 END TRY
		  BEGIN CATCH

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [Example_Staging].[ExampleOfPausingETLBuilds] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH


	    SET @ETLLoadStatus_Id = 4

	    -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Updating dimension records from staging data' , NULL;
	    BEGIN TRY



				    UPDATE dest
					  SET 
						 dest.[Cust_Id] = src.[Cust_Id]
					   , dest.[Cust_Type_Code] = src.[CustTypeCode]
					   , dest.[Is_Deleted] = src.[IsDeleted]
					   , dest.[Start_Date] = CAST(src.[StartDate] as DateTime)
					   , dest.[ETLBatch_Id] = src.[ETLBatch_Id]
						 , [DataState_Id] = 5
					 FROM 
						  [Examples].[DimExampleOfPausingETLBuilds] dest
					 INNER JOIN  [Example_Staging].[ExampleOfPausingETLBuilds] src  
					 ON  
					 dest.[PrimaryKey_Id] =  src.[PrimaryKey_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
					   WHERE
					  
					  
					   src.[ETLBatch_Id] = @Batch_ID		
					   AND
					   src.DataState_Id = 1
					   AND  src.[IsDeleted] = 0



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Updating records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode

			 --------------------------------------------------------------------	
			  
			 -- Records have been ingested, can delete them from staging.
			 DELETE
			 FROM [Example_Staging].[ExampleOfPausingETLBuilds]  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1

			 
			 

	   END TRY
		  BEGIN CATCH
  		 
			  -- ON-ERROR CLEANUP OF BATCH RECORDS ------------------------------
		   		  
			  -- The new records had their non-nullable fields inserted successfully 
			  -- in the earlier INSERT TRY-CATCH section 
			  -- BUT there was a major problem with the fields being UPDATED,
			  -- we need to remove the new key records until the problem is resolved

			  -- AS the UPDATE has been rolled back, all records with the current ETLBatch_ID
			  -- must be new records

			  DELETE FROM [Examples].[DimExampleOfPausingETLBuilds]
			   WHERE [ETLBatch_Id] = @Batch_ID 		  

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [dbo].[TestTable_NoModifiedDatePresent] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH
 

	   SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleOfPausingETLBuilds] WHERE ETLBatch_Id IS NULL)
    END
END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleOfPausingETLBuilds_Flag_Records_For_Loading]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleOfPausingETLBuilds_Flag_Records_For_Loading] AS' 
END
GO
/* -- DEBUGGING UTILITY TO RESET DATA IN STAGING -----------------------------------
UPDATE [Example_Staging].[ExampleOfPausingETLBuilds]
               SET 	 [ETLBatch_Id] = NULL
			, DataState_Id  = NULL 
*/

ALTER PROCEDURE  [Examples].[Load_DimExampleOfPausingETLBuilds_Flag_Records_For_Loading]
( @Batch_ID bigint )
AS
BEGIN

    BEGIN TRY

	   DECLARE @StepId int
	   DECLARE @ETLLoadStatusId int
	   SET @ETLLoadStatusId = 2    /* = "Identifying Batch Records In Staging"*/
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit
	   DECLARE @ErrorCode int

	   SET @Message = 'Flagging operation failed'
	   SET  @RecordsAffected = 0
	   SET @Success = 0
	   SET @ErrorCode = NULL

	   EXECUTE @StepId = [etl].[AddETLBatchStepStatus] @Batch_ID , 2 , 'Flagging Started ...' , NULL;
	    ;WITH CandidateRecords
		  AS (
		  SELECT TOP 10000 Staging_ID
			    FROM [Example_Staging].[ExampleOfPausingETLBuilds]
			    WHERE
				[ETLBatch_Id] IS NULL
			    ORDER BY Staging_ID ASC
		  )
		  UPDATE s
		  SET [ETLBatch_Id]	  = @Batch_ID ,
			 [DataState_Id]  = 1
			 FROM Example_Staging.ExampleOfPausingETLBuilds s
				 INNER JOIN   CandidateRecords c ON c.Staging_Id = s.Staging_Id

		  SET @RecordsAffected = @@ROWCOUNT

		  SET @Message = 'Flagging operation succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
		  @StepId
		  , @ETLLoadStatusId
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode

    END TRY
    BEGIN CATCH	 
			 
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()    
			 			
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @StepId
			 , @ETLLoadStatusId
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode ;
			
			RAISERROR(@Message,16,1)
    END CATCH
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleOfPausingETLBuilds_HandleDeletedRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleOfPausingETLBuilds_HandleDeletedRecords] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleOfPausingETLBuilds_HandleDeletedRecords]
(@Batch_Id bigint)
AS
BEGIN
    DECLARE @Message nvarchar( 255 )
    DECLARE @RecordsAffected int
    DECLARE @Success bit
    DECLARE @ErrorCode int 
    DECLARE @Step_ID bigint  
    DECLARE @ETLLoadStatus_Id int 
    
    SET @ETLLoadStatus_Id = 4 

     EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Deleting flagged records from dimension' , NULL;
    BEGIN TRY 

		  ;WITH StagedDeletedRecords AS
		  (
			 SELECT
			 DimExampleOfPausingETLBuilds_DID
				   FROM
					   [Example_Staging].[ExampleOfPausingETLBuilds] src
					   INNER JOIN [Examples].[DimExampleOfPausingETLBuilds] dest 
						  ON 
							 dest.[PrimaryKey_Id] =  src.[PrimaryKey_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
				   WHERE
				   src.IsDeleted  = 1
				   AND
				   src.[DataState_Id] = 1
				   AND
				   src.ETLBatch_Id = @Batch_Id     
		  )
		  DELETE FROM [Examples].[DimExampleOfPausingETLBuilds]
			WHERE		 DimExampleOfPausingETLBuilds_DID IN
			( SELECT DimExampleOfPausingETLBuilds_DID
				    FROM StagedDeletedRecords )
				    
 
	
		  -- SUCCESS LOGGING -------------------------------------------------
		  SET @RecordsAffected = @@ROWCOUNT
		  SET @Message = 'Deleting flagged records succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL 
		  
		  UPDATE  [Example_Staging].[ExampleOfPausingETLBuilds]
		  SET DataState_Id = 2
		  FROM   [Example_Staging].[ExampleOfPausingETLBuilds]
				   WHERE
				   [IsDeleted]  = 1
				   AND
				   [DataState_Id] = 1
				   AND
				   ETLBatch_Id = @Batch_Id    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
			 @Step_Id
		  , @ETLLoadStatus_Id
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode
		  --------------------------------------------------------------------
	   END TRY
	   BEGIN CATCH

		  -- FAILURE LOGGING -------------------------------------------------		  	  
		  SET @RecordsAffected = -1
		  SET @Message = ERROR_MESSAGE()
		  SET @Success = 0
		  SET @ErrorCode = ERROR_NUMBER()
		  
		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
					   @Step_Id
				    , @ETLLoadStatus_Id
				    , @Message
				    , @RecordsAffected
				    , @Success
				    , @ErrorCode   ;
		  --------------------------------------------------------------------

		 RAISERROR(@Message, 16, 1);
	   END CATCH
END	  
		  

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleOfPausingETLBuilds_SetDefaultValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleOfPausingETLBuilds_SetDefaultValues] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleOfPausingETLBuilds_SetDefaultValues]
AS 
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @Message nvarchar(1024)
BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM [Examples].[DimExampleOfPausingETLBuilds] WHERE [DimExampleOfPausingETLBuilds_DID] = -1)
    BEGIN

    SET IDENTITY_INSERT [Examples].[DimExampleOfPausingETLBuilds] ON

    INSERT INTO [Examples].[DimExampleOfPausingETLBuilds](
		 [DimExampleOfPausingETLBuilds_did]
    , [Cust_Id]
    , [Cust_Type_Code]
    , [Is_Deleted]
    , [PrimaryKey_Id]
    , [Start_Date]
    , [SourceSystem_Id]
    , [ETLBatch_Id]
    , [DataState_Id]
    )

    SELECT 
		 -1
	    , 0
,NULL
,0
,0
,NULL
,0
,0
,6

    SET IDENTITY_INSERT [Examples].[DimExampleOfPausingETLBuilds] OFF
	RETURN 0
    END 

END TRY
BEGIN CATCH
   
     SET @Message = '
-- ### BI BUILDER ERROR MESSAGE ####################################################################################################
ERROR:  [Examples].[Load_DimExampleOfPausingETLBuilds_SetDefaultValues] has attempted to insert a record that violates a CHECK CONSTRAINT.
			 
Take a look at the routine [Sales].[Load_DimSalesOrderDetails_SetDefaultValues] and edit it so it inserts the default record OK.

ERROR MESSAGE FROM SQL SERVER: '+ERROR_MESSAGE()+'
-- ###############################################################################################################################
'
    RAISERROR(@Message, 16,1)    
    
END CATCH

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTablewith300Fields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTablewith300Fields] AS' 
END
GO
 
/*
--=====================================================================================================================
-- MANUAL TESTING UTILITY ROUTINES FOR [Examples].[Load_DimExampleTablewith300Fields]
------------------------------------------------------------------------
-- Records in Dimension
SELECT * FROM	    [Examples].[DimExampleTablewith300Fields]
SELECT COUNT(*) FROM [Examples].[DimExampleTablewith300Fields]

-- Records in Staging
SELECT * FROM	     [Example_Staging].[ExampleTablewith300Fields]
SELECT COUNT(*) FROM  [Example_Staging].[ExampleTablewith300Fields]

-- To start from absolute scratch with no pre-existing logs, restaged records in the staging table and an empty dimension table
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 1,1,1,1,1

-- See the logs of previous ETL runs
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,0,0,1

-- Clear the logs for this dimension
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 1,0,0,0,0

-- Clear the logs, restage the test data and truncate the dimension
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 1,1,1,0,0

-- To restage data in the staging table 
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,1,0,0

-- To run process on whatever is in the staging table and show log
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,0,1,1

-- To Rerun the process on restaged data in the staging table 
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,1,1,1

-- To Rerun the process on previously ingested data in the staging table 
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,1,1,1 -- refill staging and run load routine again, show log, should be updaes but no new records
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,0,1,1 -- try reingesting staged data again - staging should be empty of records and log should show no change since last run

-- To test deletions
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,1,0,0 -- restage the data
UPDATE   [Example_Staging].[ExampleTablewith300Fields] 
    SET [IsDeleted] = 1 WHERE Staging_Id < 3 -- flag the first 2 records as deleted
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE   [Examples].[Load_DimExampleTablewith300Fields_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, then in one batch there were 2 deletions and ModelTableSampleRows-2 updates
SELECT * FROM	    [Examples].[DimExampleTablewith300Fields] -- checkout the records in the dimension to ensure the flagged record(s) have been deleted



--===================================================================================================================== 
*/

ALTER PROCEDURE [Examples].[Load_DimExampleTablewith300Fields]
AS 
BEGIN
--***************************************************************************************
-- This is an ETL routine that conducts data (new or updated or deleted as well as possibly stale/redundant)  
-- from the staging table [Example_Staging].[ExampleTablewith300Fields] to the 
-- dimension table [Examples].[DimExampleTablewith300Fields]
-----------------------------------------------------------------------------------------

SET NOCOUNT ON
-- (Uncomment if required) SET DATEFORMAT dmy 

-- Ensure that the dimension has an unknown "-1" key record holding default values
-- for when the fact table has no proper key into the dimension
DECLARE @ErrorCode int 
SET @ErrorCode = 0 
EXECUTE @ErrorCode = [Examples].[Load_DimExampleTablewith300Fields_SetDefaultValues]
IF @ErrorCode <> 0
BEGIN
    RETURN
END
   
DECLARE @UnloadedCount int
SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleTablewith300Fields] WHERE ETLBatch_Id IS NULL)
WHILE @UnloadedCount > 0
    BEGIN 

	   DECLARE @Batch_ID bigint  
	   DECLARE @Step_ID bigint  
	   DECLARE @ETLLoadStatus_Id int  
	   DECLARE @ProcessName varchar(50)
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit

	    SET @ProcessName = '[Examples].[Load_DimExampleTablewith300Fields]'
	    EXECUTE @Batch_ID = [ETL].[InitiateETLBatch] @ProcessName	
	
	   
	    EXECUTE [Examples].[Load_DimExampleTablewith300Fields_Flag_Records_For_Loading] @Batch_ID

	    SET @ETLLoadStatus_Id = 3

	    EXECUTE [Examples].[Load_DimExampleTablewith300Fields_HandleDeletedRecords] @Batch_ID

	   -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [ETL].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Inserting New Records into Dimension' , NULL;

	    BEGIN TRY 


				INSERT INTO [Examples].[DimExampleTablewith300Fields](
					  [Is_Deleted]
					   , [Modified_Date]
					   , [Test_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  ,[DataState_Id]
				)

				SELECT 
					  [IsDeleted]
					   , [ModifiedDate]
					   , [Test_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  , 4
				FROM
					   [Example_Staging].[ExampleTablewith300Fields]

				WHERE 				
				    [Example_Staging].[ExampleTablewith300Fields].[ETLBatch_Id] = @Batch_ID
				    AND
				   [Example_Staging].[ExampleTablewith300Fields].[IsDeleted] = 0
				    AND
				    [Example_Staging].[ExampleTablewith300Fields].[Staging_ID] NOT IN 
					(
						SELECT src.[Staging_ID]
						FROM [Example_Staging].[ExampleTablewith300Fields] src
						INNER JOIN [Examples].[DimExampleTablewith300Fields] dest 
						ON dest.[Test_Id] =  src.[Test_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
						WHERE
						    src.[ETLBatch_Id] = @Batch_ID		
						    AND
						    src.[DataState_Id] = 1
						    AND  src.[IsDeleted] = 0

	)



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Inserting new records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode
			 --------------------------------------------------------------------

		 END TRY
		  BEGIN CATCH

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [Example_Staging].[ExampleTablewith300Fields] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH


	    SET @ETLLoadStatus_Id = 4

	    -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Updating dimension records from staging data' , NULL;
	    BEGIN TRY



				    UPDATE dest
					  SET 
						 dest.[Column_No_1] = src.[Column_No_1]
					   , dest.[Column_No_10] = src.[Column_No_10]
					   , dest.[Column_No_100] = src.[Column_No_100]
					   , dest.[Column_No_101] = src.[Column_No_101]
					   , dest.[Column_No_102] = src.[Column_No_102]
					   , dest.[Column_No_103] = src.[Column_No_103]
					   , dest.[Column_No_104] = src.[Column_No_104]
					   , dest.[Column_No_105] = src.[Column_No_105]
					   , dest.[Column_No_106] = src.[Column_No_106]
					   , dest.[Column_No_107] = src.[Column_No_107]
					   , dest.[Column_No_108] = src.[Column_No_108]
					   , dest.[Column_No_109] = src.[Column_No_109]
					   , dest.[Column_No_11] = src.[Column_No_11]
					   , dest.[Column_No_110] = src.[Column_No_110]
					   , dest.[Column_No_111] = src.[Column_No_111]
					   , dest.[Column_No_112] = src.[Column_No_112]
					   , dest.[Column_No_113] = src.[Column_No_113]
					   , dest.[Column_No_114] = src.[Column_No_114]
					   , dest.[Column_No_115] = src.[Column_No_115]
					   , dest.[Column_No_116] = src.[Column_No_116]
					   , dest.[Column_No_117] = src.[Column_No_117]
					   , dest.[Column_No_118] = src.[Column_No_118]
					   , dest.[Column_No_119] = src.[Column_No_119]
					   , dest.[Column_No_12] = src.[Column_No_12]
					   , dest.[Column_No_120] = src.[Column_No_120]
					   , dest.[Column_No_121] = src.[Column_No_121]
					   , dest.[Column_No_122] = src.[Column_No_122]
					   , dest.[Column_No_123] = src.[Column_No_123]
					   , dest.[Column_No_124] = src.[Column_No_124]
					   , dest.[Column_No_125] = src.[Column_No_125]
					   , dest.[Column_No_126] = src.[Column_No_126]
					   , dest.[Column_No_127] = src.[Column_No_127]
					   , dest.[Column_No_128] = src.[Column_No_128]
					   , dest.[Column_No_129] = src.[Column_No_129]
					   , dest.[Column_No_13] = src.[Column_No_13]
					   , dest.[Column_No_130] = src.[Column_No_130]
					   , dest.[Column_No_131] = src.[Column_No_131]
					   , dest.[Column_No_132] = src.[Column_No_132]
					   , dest.[Column_No_133] = src.[Column_No_133]
					   , dest.[Column_No_134] = src.[Column_No_134]
					   , dest.[Column_No_135] = src.[Column_No_135]
					   , dest.[Column_No_136] = src.[Column_No_136]
					   , dest.[Column_No_137] = src.[Column_No_137]
					   , dest.[Column_No_138] = src.[Column_No_138]
					   , dest.[Column_No_139] = src.[Column_No_139]
					   , dest.[Column_No_14] = src.[Column_No_14]
					   , dest.[Column_No_140] = src.[Column_No_140]
					   , dest.[Column_No_141] = src.[Column_No_141]
					   , dest.[Column_No_142] = src.[Column_No_142]
					   , dest.[Column_No_143] = src.[Column_No_143]
					   , dest.[Column_No_144] = src.[Column_No_144]
					   , dest.[Column_No_145] = src.[Column_No_145]
					   , dest.[Column_No_146] = src.[Column_No_146]
					   , dest.[Column_No_147] = src.[Column_No_147]
					   , dest.[Column_No_148] = src.[Column_No_148]
					   , dest.[Column_No_149] = src.[Column_No_149]
					   , dest.[Column_No_15] = src.[Column_No_15]
					   , dest.[Column_No_150] = src.[Column_No_150]
					   , dest.[Column_No_151] = src.[Column_No_151]
					   , dest.[Column_No_152] = src.[Column_No_152]
					   , dest.[Column_No_153] = src.[Column_No_153]
					   , dest.[Column_No_154] = src.[Column_No_154]
					   , dest.[Column_No_155] = src.[Column_No_155]
					   , dest.[Column_No_156] = src.[Column_No_156]
					   , dest.[Column_No_157] = src.[Column_No_157]
					   , dest.[Column_No_158] = src.[Column_No_158]
					   , dest.[Column_No_159] = src.[Column_No_159]
					   , dest.[Column_No_16] = src.[Column_No_16]
					   , dest.[Column_No_160] = src.[Column_No_160]
					   , dest.[Column_No_161] = src.[Column_No_161]
					   , dest.[Column_No_162] = src.[Column_No_162]
					   , dest.[Column_No_163] = src.[Column_No_163]
					   , dest.[Column_No_164] = src.[Column_No_164]
					   , dest.[Column_No_165] = src.[Column_No_165]
					   , dest.[Column_No_166] = src.[Column_No_166]
					   , dest.[Column_No_167] = src.[Column_No_167]
					   , dest.[Column_No_168] = src.[Column_No_168]
					   , dest.[Column_No_169] = src.[Column_No_169]
					   , dest.[Column_No_17] = src.[Column_No_17]
					   , dest.[Column_No_170] = src.[Column_No_170]
					   , dest.[Column_No_171] = src.[Column_No_171]
					   , dest.[Column_No_172] = src.[Column_No_172]
					   , dest.[Column_No_173] = src.[Column_No_173]
					   , dest.[Column_No_174] = src.[Column_No_174]
					   , dest.[Column_No_175] = src.[Column_No_175]
					   , dest.[Column_No_176] = src.[Column_No_176]
					   , dest.[Column_No_177] = src.[Column_No_177]
					   , dest.[Column_No_178] = src.[Column_No_178]
					   , dest.[Column_No_179] = src.[Column_No_179]
					   , dest.[Column_No_18] = src.[Column_No_18]
					   , dest.[Column_No_180] = src.[Column_No_180]
					   , dest.[Column_No_181] = src.[Column_No_181]
					   , dest.[Column_No_182] = src.[Column_No_182]
					   , dest.[Column_No_183] = src.[Column_No_183]
					   , dest.[Column_No_184] = src.[Column_No_184]
					   , dest.[Column_No_185] = src.[Column_No_185]
					   , dest.[Column_No_186] = src.[Column_No_186]
					   , dest.[Column_No_187] = src.[Column_No_187]
					   , dest.[Column_No_188] = src.[Column_No_188]
					   , dest.[Column_No_189] = src.[Column_No_189]
					   , dest.[Column_No_19] = src.[Column_No_19]
					   , dest.[Column_No_190] = src.[Column_No_190]
					   , dest.[Column_No_191] = src.[Column_No_191]
					   , dest.[Column_No_192] = src.[Column_No_192]
					   , dest.[Column_No_193] = src.[Column_No_193]
					   , dest.[Column_No_194] = src.[Column_No_194]
					   , dest.[Column_No_195] = src.[Column_No_195]
					   , dest.[Column_No_196] = src.[Column_No_196]
					   , dest.[Column_No_197] = src.[Column_No_197]
					   , dest.[Column_No_198] = src.[Column_No_198]
					   , dest.[Column_No_199] = src.[Column_No_199]
					   , dest.[Column_No_2] = src.[Column_No_2]
					   , dest.[Column_No_20] = src.[Column_No_20]
					   , dest.[Column_No_200] = src.[Column_No_200]
					   , dest.[Column_No_201] = src.[Column_No_201]
					   , dest.[Column_No_202] = src.[Column_No_202]
					   , dest.[Column_No_203] = src.[Column_No_203]
					   , dest.[Column_No_204] = src.[Column_No_204]
					   , dest.[Column_No_205] = src.[Column_No_205]
					   , dest.[Column_No_206] = src.[Column_No_206]
					   , dest.[Column_No_207] = src.[Column_No_207]
					   , dest.[Column_No_208] = src.[Column_No_208]
					   , dest.[Column_No_209] = src.[Column_No_209]
					   , dest.[Column_No_21] = src.[Column_No_21]
					   , dest.[Column_No_210] = src.[Column_No_210]
					   , dest.[Column_No_211] = src.[Column_No_211]
					   , dest.[Column_No_212] = src.[Column_No_212]
					   , dest.[Column_No_213] = src.[Column_No_213]
					   , dest.[Column_No_214] = src.[Column_No_214]
					   , dest.[Column_No_215] = src.[Column_No_215]
					   , dest.[Column_No_216] = src.[Column_No_216]
					   , dest.[Column_No_217] = src.[Column_No_217]
					   , dest.[Column_No_218] = src.[Column_No_218]
					   , dest.[Column_No_219] = src.[Column_No_219]
					   , dest.[Column_No_22] = src.[Column_No_22]
					   , dest.[Column_No_220] = src.[Column_No_220]
					   , dest.[Column_No_221] = src.[Column_No_221]
					   , dest.[Column_No_222] = src.[Column_No_222]
					   , dest.[Column_No_223] = src.[Column_No_223]
					   , dest.[Column_No_224] = src.[Column_No_224]
					   , dest.[Column_No_225] = src.[Column_No_225]
					   , dest.[Column_No_226] = src.[Column_No_226]
					   , dest.[Column_No_227] = src.[Column_No_227]
					   , dest.[Column_No_228] = src.[Column_No_228]
					   , dest.[Column_No_229] = src.[Column_No_229]
					   , dest.[Column_No_23] = src.[Column_No_23]
					   , dest.[Column_No_230] = src.[Column_No_230]
					   , dest.[Column_No_231] = src.[Column_No_231]
					   , dest.[Column_No_232] = src.[Column_No_232]
					   , dest.[Column_No_233] = src.[Column_No_233]
					   , dest.[Column_No_234] = src.[Column_No_234]
					   , dest.[Column_No_235] = src.[Column_No_235]
					   , dest.[Column_No_236] = src.[Column_No_236]
					   , dest.[Column_No_237] = src.[Column_No_237]
					   , dest.[Column_No_238] = src.[Column_No_238]
					   , dest.[Column_No_239] = src.[Column_No_239]
					   , dest.[Column_No_24] = src.[Column_No_24]
					   , dest.[Column_No_240] = src.[Column_No_240]
					   , dest.[Column_No_241] = src.[Column_No_241]
					   , dest.[Column_No_242] = src.[Column_No_242]
					   , dest.[Column_No_243] = src.[Column_No_243]
					   , dest.[Column_No_244] = src.[Column_No_244]
					   , dest.[Column_No_245] = src.[Column_No_245]
					   , dest.[Column_No_246] = src.[Column_No_246]
					   , dest.[Column_No_247] = src.[Column_No_247]
					   , dest.[Column_No_248] = src.[Column_No_248]
					   , dest.[Column_No_249] = src.[Column_No_249]
					   , dest.[Column_No_25] = src.[Column_No_25]
					   , dest.[Column_No_250] = src.[Column_No_250]
					   , dest.[Column_No_251] = src.[Column_No_251]
					   , dest.[Column_No_252] = src.[Column_No_252]
					   , dest.[Column_No_253] = src.[Column_No_253]
					   , dest.[Column_No_254] = src.[Column_No_254]
					   , dest.[Column_No_255] = src.[Column_No_255]
					   , dest.[Column_No_256] = src.[Column_No_256]
					   , dest.[Column_No_257] = src.[Column_No_257]
					   , dest.[Column_No_258] = src.[Column_No_258]
					   , dest.[Column_No_259] = src.[Column_No_259]
					   , dest.[Column_No_26] = src.[Column_No_26]
					   , dest.[Column_No_260] = src.[Column_No_260]
					   , dest.[Column_No_261] = src.[Column_No_261]
					   , dest.[Column_No_262] = src.[Column_No_262]
					   , dest.[Column_No_263] = src.[Column_No_263]
					   , dest.[Column_No_264] = src.[Column_No_264]
					   , dest.[Column_No_265] = src.[Column_No_265]
					   , dest.[Column_No_266] = src.[Column_No_266]
					   , dest.[Column_No_267] = src.[Column_No_267]
					   , dest.[Column_No_268] = src.[Column_No_268]
					   , dest.[Column_No_269] = src.[Column_No_269]
					   , dest.[Column_No_27] = src.[Column_No_27]
					   , dest.[Column_No_270] = src.[Column_No_270]
					   , dest.[Column_No_271] = src.[Column_No_271]
					   , dest.[Column_No_272] = src.[Column_No_272]
					   , dest.[Column_No_273] = src.[Column_No_273]
					   , dest.[Column_No_274] = src.[Column_No_274]
					   , dest.[Column_No_275] = src.[Column_No_275]
					   , dest.[Column_No_276] = src.[Column_No_276]
					   , dest.[Column_No_277] = src.[Column_No_277]
					   , dest.[Column_No_278] = src.[Column_No_278]
					   , dest.[Column_No_279] = src.[Column_No_279]
					   , dest.[Column_No_28] = src.[Column_No_28]
					   , dest.[Column_No_280] = src.[Column_No_280]
					   , dest.[Column_No_281] = src.[Column_No_281]
					   , dest.[Column_No_282] = src.[Column_No_282]
					   , dest.[Column_No_283] = src.[Column_No_283]
					   , dest.[Column_No_284] = src.[Column_No_284]
					   , dest.[Column_No_285] = src.[Column_No_285]
					   , dest.[Column_No_286] = src.[Column_No_286]
					   , dest.[Column_No_287] = src.[Column_No_287]
					   , dest.[Column_No_288] = src.[Column_No_288]
					   , dest.[Column_No_289] = src.[Column_No_289]
					   , dest.[Column_No_29] = src.[Column_No_29]
					   , dest.[Column_No_290] = src.[Column_No_290]
					   , dest.[Column_No_291] = src.[Column_No_291]
					   , dest.[Column_No_292] = src.[Column_No_292]
					   , dest.[Column_No_293] = src.[Column_No_293]
					   , dest.[Column_No_294] = src.[Column_No_294]
					   , dest.[Column_No_295] = src.[Column_No_295]
					   , dest.[Column_No_296] = src.[Column_No_296]
					   , dest.[Column_No_297] = src.[Column_No_297]
					   , dest.[Column_No_298] = src.[Column_No_298]
					   , dest.[Column_No_299] = src.[Column_No_299]
					   , dest.[Column_No_3] = src.[Column_No_3]
					   , dest.[Column_No_30] = src.[Column_No_30]
					   , dest.[Column_No_300] = src.[Column_No_300]
					   , dest.[Column_No_31] = src.[Column_No_31]
					   , dest.[Column_No_32] = src.[Column_No_32]
					   , dest.[Column_No_33] = src.[Column_No_33]
					   , dest.[Column_No_34] = src.[Column_No_34]
					   , dest.[Column_No_35] = src.[Column_No_35]
					   , dest.[Column_No_36] = src.[Column_No_36]
					   , dest.[Column_No_37] = src.[Column_No_37]
					   , dest.[Column_No_38] = src.[Column_No_38]
					   , dest.[Column_No_39] = src.[Column_No_39]
					   , dest.[Column_No_4] = src.[Column_No_4]
					   , dest.[Column_No_40] = src.[Column_No_40]
					   , dest.[Column_No_41] = src.[Column_No_41]
					   , dest.[Column_No_42] = src.[Column_No_42]
					   , dest.[Column_No_43] = src.[Column_No_43]
					   , dest.[Column_No_44] = src.[Column_No_44]
					   , dest.[Column_No_45] = src.[Column_No_45]
					   , dest.[Column_No_46] = src.[Column_No_46]
					   , dest.[Column_No_47] = src.[Column_No_47]
					   , dest.[Column_No_48] = src.[Column_No_48]
					   , dest.[Column_No_49] = src.[Column_No_49]
					   , dest.[Column_No_5] = src.[Column_No_5]
					   , dest.[Column_No_50] = src.[Column_No_50]
					   , dest.[Column_No_51] = src.[Column_No_51]
					   , dest.[Column_No_52] = src.[Column_No_52]
					   , dest.[Column_No_53] = src.[Column_No_53]
					   , dest.[Column_No_54] = src.[Column_No_54]
					   , dest.[Column_No_55] = src.[Column_No_55]
					   , dest.[Column_No_56] = src.[Column_No_56]
					   , dest.[Column_No_57] = src.[Column_No_57]
					   , dest.[Column_No_58] = src.[Column_No_58]
					   , dest.[Column_No_59] = src.[Column_No_59]
					   , dest.[Column_No_6] = src.[Column_No_6]
					   , dest.[Column_No_60] = src.[Column_No_60]
					   , dest.[Column_No_61] = src.[Column_No_61]
					   , dest.[Column_No_62] = src.[Column_No_62]
					   , dest.[Column_No_63] = src.[Column_No_63]
					   , dest.[Column_No_64] = src.[Column_No_64]
					   , dest.[Column_No_65] = src.[Column_No_65]
					   , dest.[Column_No_66] = src.[Column_No_66]
					   , dest.[Column_No_67] = src.[Column_No_67]
					   , dest.[Column_No_68] = src.[Column_No_68]
					   , dest.[Column_No_69] = src.[Column_No_69]
					   , dest.[Column_No_7] = src.[Column_No_7]
					   , dest.[Column_No_70] = src.[Column_No_70]
					   , dest.[Column_No_71] = src.[Column_No_71]
					   , dest.[Column_No_72] = src.[Column_No_72]
					   , dest.[Column_No_73] = src.[Column_No_73]
					   , dest.[Column_No_74] = src.[Column_No_74]
					   , dest.[Column_No_75] = src.[Column_No_75]
					   , dest.[Column_No_76] = src.[Column_No_76]
					   , dest.[Column_No_77] = src.[Column_No_77]
					   , dest.[Column_No_78] = src.[Column_No_78]
					   , dest.[Column_No_79] = src.[Column_No_79]
					   , dest.[Column_No_8] = src.[Column_No_8]
					   , dest.[Column_No_80] = src.[Column_No_80]
					   , dest.[Column_No_81] = src.[Column_No_81]
					   , dest.[Column_No_82] = src.[Column_No_82]
					   , dest.[Column_No_83] = src.[Column_No_83]
					   , dest.[Column_No_84] = src.[Column_No_84]
					   , dest.[Column_No_85] = src.[Column_No_85]
					   , dest.[Column_No_86] = src.[Column_No_86]
					   , dest.[Column_No_87] = src.[Column_No_87]
					   , dest.[Column_No_88] = src.[Column_No_88]
					   , dest.[Column_No_89] = src.[Column_No_89]
					   , dest.[Column_No_9] = src.[Column_No_9]
					   , dest.[Column_No_90] = src.[Column_No_90]
					   , dest.[Column_No_91] = src.[Column_No_91]
					   , dest.[Column_No_92] = src.[Column_No_92]
					   , dest.[Column_No_93] = src.[Column_No_93]
					   , dest.[Column_No_94] = src.[Column_No_94]
					   , dest.[Column_No_95] = src.[Column_No_95]
					   , dest.[Column_No_96] = src.[Column_No_96]
					   , dest.[Column_No_97] = src.[Column_No_97]
					   , dest.[Column_No_98] = src.[Column_No_98]
					   , dest.[Column_No_99] = src.[Column_No_99]
					   , dest.[Is_Deleted] = src.[IsDeleted]
					   , dest.[Modified_Date] = src.[ModifiedDate]
					   , dest.[ETLBatch_Id] = src.[ETLBatch_Id]
						 , [DataState_Id] = 5
					 FROM 
						  [Examples].[DimExampleTablewith300Fields] dest
					 INNER JOIN  [Example_Staging].[ExampleTablewith300Fields] src  
					 ON  
					 dest.[Test_Id] =  src.[Test_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
					   WHERE
					  dest.[Modified_Date] <=  src.[ModifiedDate] AND 
					  
					   src.[ETLBatch_Id] = @Batch_ID		
					   AND
					   src.DataState_Id = 1
					   AND  src.[IsDeleted] = 0



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Updating records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode

			 --------------------------------------------------------------------	
			  
			 -- Records have been ingested, can delete them from staging.
			 DELETE
			 FROM [Example_Staging].[ExampleTablewith300Fields]  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1

			 
			 

	   END TRY
		  BEGIN CATCH
  		 
			  -- ON-ERROR CLEANUP OF BATCH RECORDS ------------------------------
		   		  
			  -- The new records had their non-nullable fields inserted successfully 
			  -- in the earlier INSERT TRY-CATCH section 
			  -- BUT there was a major problem with the fields being UPDATED,
			  -- we need to remove the new key records until the problem is resolved

			  -- AS the UPDATE has been rolled back, all records with the current ETLBatch_ID
			  -- must be new records

			  DELETE FROM [Examples].[DimExampleTablewith300Fields]
			   WHERE [ETLBatch_Id] = @Batch_ID 		  

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [dbo].[TestTable_NoModifiedDatePresent] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH
 

	   SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleTablewith300Fields] WHERE ETLBatch_Id IS NULL)
    END
END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTablewith300Fields_Flag_Records_For_Loading]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTablewith300Fields_Flag_Records_For_Loading] AS' 
END
GO
/* -- DEBUGGING UTILITY TO RESET DATA IN STAGING -----------------------------------
UPDATE [Example_Staging].[ExampleTablewith300Fields]
               SET 	 [ETLBatch_Id] = NULL
			, DataState_Id  = NULL 
*/

ALTER PROCEDURE  [Examples].[Load_DimExampleTablewith300Fields_Flag_Records_For_Loading]
( @Batch_ID bigint )
AS
BEGIN

    BEGIN TRY

	   DECLARE @StepId int
	   DECLARE @ETLLoadStatusId int
	   SET @ETLLoadStatusId = 2    /* = "Identifying Batch Records In Staging"*/
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit
	   DECLARE @ErrorCode int

	   SET @Message = 'Flagging operation failed'
	   SET  @RecordsAffected = 0
	   SET @Success = 0
	   SET @ErrorCode = NULL

	   EXECUTE @StepId = [etl].[AddETLBatchStepStatus] @Batch_ID , 2 , 'Flagging Started ...' , NULL;
	    ;WITH CandidateRecords
		  AS (
		  SELECT TOP 10000 Staging_ID
			    FROM [Example_Staging].[ExampleTablewith300Fields]
			    WHERE
				[ETLBatch_Id] IS NULL
			    ORDER BY Staging_ID ASC
		  )
		  UPDATE s
		  SET [ETLBatch_Id]	  = @Batch_ID ,
			 [DataState_Id]  = 1
			 FROM Example_Staging.ExampleTablewith300Fields s
				 INNER JOIN   CandidateRecords c ON c.Staging_Id = s.Staging_Id

		  SET @RecordsAffected = @@ROWCOUNT

		  SET @Message = 'Flagging operation succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
		  @StepId
		  , @ETLLoadStatusId
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode

    END TRY
    BEGIN CATCH	 
			 
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()    
			 			
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @StepId
			 , @ETLLoadStatusId
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode ;
			
			RAISERROR(@Message,16,1)
    END CATCH
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTablewith300Fields_HandleDeletedRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTablewith300Fields_HandleDeletedRecords] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleTablewith300Fields_HandleDeletedRecords]
(@Batch_Id bigint)
AS
BEGIN
    DECLARE @Message nvarchar( 255 )
    DECLARE @RecordsAffected int
    DECLARE @Success bit
    DECLARE @ErrorCode int 
    DECLARE @Step_ID bigint  
    DECLARE @ETLLoadStatus_Id int 
    
    SET @ETLLoadStatus_Id = 4 

     EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Deleting flagged records from dimension' , NULL;
    BEGIN TRY 

		  ;WITH StagedDeletedRecords AS
		  (
			 SELECT
			 DimExampleTablewith300Fields_DID
				   FROM
					   [Example_Staging].[ExampleTablewith300Fields] src
					   INNER JOIN [Examples].[DimExampleTablewith300Fields] dest 
						  ON 
							 dest.[Test_Id] =  src.[Test_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
				   WHERE
				   src.IsDeleted  = 1
				   AND
				   src.[DataState_Id] = 1
				   AND
				   src.ETLBatch_Id = @Batch_Id     
		  )
		  DELETE FROM [Examples].[DimExampleTablewith300Fields]
			WHERE		 DimExampleTablewith300Fields_DID IN
			( SELECT DimExampleTablewith300Fields_DID
				    FROM StagedDeletedRecords )
				    
 
	
		  -- SUCCESS LOGGING -------------------------------------------------
		  SET @RecordsAffected = @@ROWCOUNT
		  SET @Message = 'Deleting flagged records succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL 
		  
		  UPDATE  [Example_Staging].[ExampleTablewith300Fields]
		  SET DataState_Id = 2
		  FROM   [Example_Staging].[ExampleTablewith300Fields]
				   WHERE
				   [IsDeleted]  = 1
				   AND
				   [DataState_Id] = 1
				   AND
				   ETLBatch_Id = @Batch_Id    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
			 @Step_Id
		  , @ETLLoadStatus_Id
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode
		  --------------------------------------------------------------------
	   END TRY
	   BEGIN CATCH

		  -- FAILURE LOGGING -------------------------------------------------		  	  
		  SET @RecordsAffected = -1
		  SET @Message = ERROR_MESSAGE()
		  SET @Success = 0
		  SET @ErrorCode = ERROR_NUMBER()
		  
		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
					   @Step_Id
				    , @ETLLoadStatus_Id
				    , @Message
				    , @RecordsAffected
				    , @Success
				    , @ErrorCode   ;
		  --------------------------------------------------------------------

		 RAISERROR(@Message, 16, 1);
	   END CATCH
END	  
		  

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTablewith300Fields_SetDefaultValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTablewith300Fields_SetDefaultValues] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleTablewith300Fields_SetDefaultValues]
AS 
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @Message nvarchar(1024)
BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM [Examples].[DimExampleTablewith300Fields] WHERE [DimExampleTablewith300Fields_DID] = -1)
    BEGIN

    SET IDENTITY_INSERT [Examples].[DimExampleTablewith300Fields] ON

    INSERT INTO [Examples].[DimExampleTablewith300Fields](
		 [DimExampleTablewith300Fields_did]
    , [Column_No_1]
    , [Column_No_10]
    , [Column_No_100]
    , [Column_No_101]
    , [Column_No_102]
    , [Column_No_103]
    , [Column_No_104]
    , [Column_No_105]
    , [Column_No_106]
    , [Column_No_107]
    , [Column_No_108]
    , [Column_No_109]
    , [Column_No_11]
    , [Column_No_110]
    , [Column_No_111]
    , [Column_No_112]
    , [Column_No_113]
    , [Column_No_114]
    , [Column_No_115]
    , [Column_No_116]
    , [Column_No_117]
    , [Column_No_118]
    , [Column_No_119]
    , [Column_No_12]
    , [Column_No_120]
    , [Column_No_121]
    , [Column_No_122]
    , [Column_No_123]
    , [Column_No_124]
    , [Column_No_125]
    , [Column_No_126]
    , [Column_No_127]
    , [Column_No_128]
    , [Column_No_129]
    , [Column_No_13]
    , [Column_No_130]
    , [Column_No_131]
    , [Column_No_132]
    , [Column_No_133]
    , [Column_No_134]
    , [Column_No_135]
    , [Column_No_136]
    , [Column_No_137]
    , [Column_No_138]
    , [Column_No_139]
    , [Column_No_14]
    , [Column_No_140]
    , [Column_No_141]
    , [Column_No_142]
    , [Column_No_143]
    , [Column_No_144]
    , [Column_No_145]
    , [Column_No_146]
    , [Column_No_147]
    , [Column_No_148]
    , [Column_No_149]
    , [Column_No_15]
    , [Column_No_150]
    , [Column_No_151]
    , [Column_No_152]
    , [Column_No_153]
    , [Column_No_154]
    , [Column_No_155]
    , [Column_No_156]
    , [Column_No_157]
    , [Column_No_158]
    , [Column_No_159]
    , [Column_No_16]
    , [Column_No_160]
    , [Column_No_161]
    , [Column_No_162]
    , [Column_No_163]
    , [Column_No_164]
    , [Column_No_165]
    , [Column_No_166]
    , [Column_No_167]
    , [Column_No_168]
    , [Column_No_169]
    , [Column_No_17]
    , [Column_No_170]
    , [Column_No_171]
    , [Column_No_172]
    , [Column_No_173]
    , [Column_No_174]
    , [Column_No_175]
    , [Column_No_176]
    , [Column_No_177]
    , [Column_No_178]
    , [Column_No_179]
    , [Column_No_18]
    , [Column_No_180]
    , [Column_No_181]
    , [Column_No_182]
    , [Column_No_183]
    , [Column_No_184]
    , [Column_No_185]
    , [Column_No_186]
    , [Column_No_187]
    , [Column_No_188]
    , [Column_No_189]
    , [Column_No_19]
    , [Column_No_190]
    , [Column_No_191]
    , [Column_No_192]
    , [Column_No_193]
    , [Column_No_194]
    , [Column_No_195]
    , [Column_No_196]
    , [Column_No_197]
    , [Column_No_198]
    , [Column_No_199]
    , [Column_No_2]
    , [Column_No_20]
    , [Column_No_200]
    , [Column_No_201]
    , [Column_No_202]
    , [Column_No_203]
    , [Column_No_204]
    , [Column_No_205]
    , [Column_No_206]
    , [Column_No_207]
    , [Column_No_208]
    , [Column_No_209]
    , [Column_No_21]
    , [Column_No_210]
    , [Column_No_211]
    , [Column_No_212]
    , [Column_No_213]
    , [Column_No_214]
    , [Column_No_215]
    , [Column_No_216]
    , [Column_No_217]
    , [Column_No_218]
    , [Column_No_219]
    , [Column_No_22]
    , [Column_No_220]
    , [Column_No_221]
    , [Column_No_222]
    , [Column_No_223]
    , [Column_No_224]
    , [Column_No_225]
    , [Column_No_226]
    , [Column_No_227]
    , [Column_No_228]
    , [Column_No_229]
    , [Column_No_23]
    , [Column_No_230]
    , [Column_No_231]
    , [Column_No_232]
    , [Column_No_233]
    , [Column_No_234]
    , [Column_No_235]
    , [Column_No_236]
    , [Column_No_237]
    , [Column_No_238]
    , [Column_No_239]
    , [Column_No_24]
    , [Column_No_240]
    , [Column_No_241]
    , [Column_No_242]
    , [Column_No_243]
    , [Column_No_244]
    , [Column_No_245]
    , [Column_No_246]
    , [Column_No_247]
    , [Column_No_248]
    , [Column_No_249]
    , [Column_No_25]
    , [Column_No_250]
    , [Column_No_251]
    , [Column_No_252]
    , [Column_No_253]
    , [Column_No_254]
    , [Column_No_255]
    , [Column_No_256]
    , [Column_No_257]
    , [Column_No_258]
    , [Column_No_259]
    , [Column_No_26]
    , [Column_No_260]
    , [Column_No_261]
    , [Column_No_262]
    , [Column_No_263]
    , [Column_No_264]
    , [Column_No_265]
    , [Column_No_266]
    , [Column_No_267]
    , [Column_No_268]
    , [Column_No_269]
    , [Column_No_27]
    , [Column_No_270]
    , [Column_No_271]
    , [Column_No_272]
    , [Column_No_273]
    , [Column_No_274]
    , [Column_No_275]
    , [Column_No_276]
    , [Column_No_277]
    , [Column_No_278]
    , [Column_No_279]
    , [Column_No_28]
    , [Column_No_280]
    , [Column_No_281]
    , [Column_No_282]
    , [Column_No_283]
    , [Column_No_284]
    , [Column_No_285]
    , [Column_No_286]
    , [Column_No_287]
    , [Column_No_288]
    , [Column_No_289]
    , [Column_No_29]
    , [Column_No_290]
    , [Column_No_291]
    , [Column_No_292]
    , [Column_No_293]
    , [Column_No_294]
    , [Column_No_295]
    , [Column_No_296]
    , [Column_No_297]
    , [Column_No_298]
    , [Column_No_299]
    , [Column_No_3]
    , [Column_No_30]
    , [Column_No_300]
    , [Column_No_31]
    , [Column_No_32]
    , [Column_No_33]
    , [Column_No_34]
    , [Column_No_35]
    , [Column_No_36]
    , [Column_No_37]
    , [Column_No_38]
    , [Column_No_39]
    , [Column_No_4]
    , [Column_No_40]
    , [Column_No_41]
    , [Column_No_42]
    , [Column_No_43]
    , [Column_No_44]
    , [Column_No_45]
    , [Column_No_46]
    , [Column_No_47]
    , [Column_No_48]
    , [Column_No_49]
    , [Column_No_5]
    , [Column_No_50]
    , [Column_No_51]
    , [Column_No_52]
    , [Column_No_53]
    , [Column_No_54]
    , [Column_No_55]
    , [Column_No_56]
    , [Column_No_57]
    , [Column_No_58]
    , [Column_No_59]
    , [Column_No_6]
    , [Column_No_60]
    , [Column_No_61]
    , [Column_No_62]
    , [Column_No_63]
    , [Column_No_64]
    , [Column_No_65]
    , [Column_No_66]
    , [Column_No_67]
    , [Column_No_68]
    , [Column_No_69]
    , [Column_No_7]
    , [Column_No_70]
    , [Column_No_71]
    , [Column_No_72]
    , [Column_No_73]
    , [Column_No_74]
    , [Column_No_75]
    , [Column_No_76]
    , [Column_No_77]
    , [Column_No_78]
    , [Column_No_79]
    , [Column_No_8]
    , [Column_No_80]
    , [Column_No_81]
    , [Column_No_82]
    , [Column_No_83]
    , [Column_No_84]
    , [Column_No_85]
    , [Column_No_86]
    , [Column_No_87]
    , [Column_No_88]
    , [Column_No_89]
    , [Column_No_9]
    , [Column_No_90]
    , [Column_No_91]
    , [Column_No_92]
    , [Column_No_93]
    , [Column_No_94]
    , [Column_No_95]
    , [Column_No_96]
    , [Column_No_97]
    , [Column_No_98]
    , [Column_No_99]
    , [Is_Deleted]
    , [Modified_Date]
    , [Test_Id]
    , [SourceSystem_Id]
    , [ETLBatch_Id]
    , [DataState_Id]
    )

    SELECT 
		 -1
	    , NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,NULL
,0
,'Jan 1 1900'
,0
,0
,0
,6

    SET IDENTITY_INSERT [Examples].[DimExampleTablewith300Fields] OFF
	RETURN 0
    END 

END TRY
BEGIN CATCH
   
     SET @Message = '
-- ### BI BUILDER ERROR MESSAGE ####################################################################################################
ERROR:  [Examples].[Load_DimExampleTablewith300Fields_SetDefaultValues] has attempted to insert a record that violates a CHECK CONSTRAINT.
			 
Take a look at the routine [Sales].[Load_DimSalesOrderDetails_SetDefaultValues] and edit it so it inserts the default record OK.

ERROR MESSAGE FROM SQL SERVER: '+ERROR_MESSAGE()+'
-- ###############################################################################################################################
'
    RAISERROR(@Message, 16,1)    
    
END CATCH

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTypeConversion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTypeConversion] AS' 
END
GO
 
/*
--=====================================================================================================================
-- MANUAL TESTING UTILITY ROUTINES FOR [Examples].[Load_DimExampleTypeConversion]
------------------------------------------------------------------------
-- Records in Dimension
SELECT * FROM	    [Examples].[DimExampleTypeConversion]
SELECT COUNT(*) FROM [Examples].[DimExampleTypeConversion]

-- Records in Staging
SELECT * FROM	     [Example_Staging].[ExampleTypeConversion]
SELECT COUNT(*) FROM  [Example_Staging].[ExampleTypeConversion]

-- To start from absolute scratch with no pre-existing logs, restaged records in the staging table and an empty dimension table
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 1,1,1,1,1

-- See the logs of previous ETL runs
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,0,0,1

-- Clear the logs for this dimension
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 1,0,0,0,0

-- Clear the logs, restage the test data and truncate the dimension
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 1,1,1,0,0

-- To restage data in the staging table 
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,1,0,0

-- To run process on whatever is in the staging table and show log
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,0,1,1

-- To Rerun the process on restaged data in the staging table 
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,1,1,1

-- To Rerun the process on previously ingested data in the staging table 
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,1,1,1 -- refill staging and run load routine again, show log, should be updaes but no new records
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,0,1,1 -- try reingesting staged data again - staging should be empty of records and log should show no change since last run

-- To test deletions
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,1,0,0 -- restage the data
UPDATE   [Example_Staging].[ExampleTypeConversion] 
    SET [*PUT DELETION FLAG COLUMN NAME HERE*] = 1 WHERE Staging_Id < 3 -- flag the first 2 records as deleted
EXECUTE  [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE   [Examples].[Load_DimExampleTypeConversion_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, then in one batch there were 2 deletions and ModelTableSampleRows-2 updates
SELECT * FROM	    [Examples].[DimExampleTypeConversion] -- checkout the records in the dimension to ensure the flagged record(s) have been deleted



--===================================================================================================================== 
*/

ALTER PROCEDURE [Examples].[Load_DimExampleTypeConversion]
AS 
BEGIN
--***************************************************************************************
-- This is an ETL routine that conducts data (new or updated or deleted as well as possibly stale/redundant)  
-- from the staging table [Example_Staging].[ExampleTypeConversion] to the 
-- dimension table [Examples].[DimExampleTypeConversion]
-----------------------------------------------------------------------------------------

SET NOCOUNT ON
-- (Uncomment if required) SET DATEFORMAT dmy 

-- Ensure that the dimension has an unknown "-1" key record holding default values
-- for when the fact table has no proper key into the dimension
DECLARE @ErrorCode int 
SET @ErrorCode = 0 
EXECUTE @ErrorCode = [Examples].[Load_DimExampleTypeConversion_SetDefaultValues]
IF @ErrorCode <> 0
BEGIN
    RETURN
END
   
DECLARE @UnloadedCount int
SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleTypeConversion] WHERE ETLBatch_Id IS NULL)
WHILE @UnloadedCount > 0
    BEGIN 

	   DECLARE @Batch_ID bigint  
	   DECLARE @Step_ID bigint  
	   DECLARE @ETLLoadStatus_Id int  
	   DECLARE @ProcessName varchar(50)
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit

	    SET @ProcessName = '[Examples].[Load_DimExampleTypeConversion]'
	    EXECUTE @Batch_ID = [ETL].[InitiateETLBatch] @ProcessName	
	
	   
	    EXECUTE [Examples].[Load_DimExampleTypeConversion_Flag_Records_For_Loading] @Batch_ID

	    SET @ETLLoadStatus_Id = 3

	    EXECUTE [Examples].[Load_DimExampleTypeConversion_HandleDeletedRecords] @Batch_ID

	   -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [ETL].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Inserting New Records into Dimension' , NULL;

	    BEGIN TRY 


				INSERT INTO [Examples].[DimExampleTypeConversion](
					  [A_Text_Field]
					   , [ExampleTypeConversion_Id]
					   , [Integer_Style_Timestamp]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  ,[DataState_Id]
				)

				SELECT 
					  [ATextField]
					   , [ExampleTypeConversion_Id]
					   , [DWHUtils].[IntegerTimestampToDatetime]([Integer_Style_Timestamp])
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  , 4
				FROM
					   [Example_Staging].[ExampleTypeConversion]

				WHERE 				
				    [Example_Staging].[ExampleTypeConversion].[ETLBatch_Id] = @Batch_ID
				   
				    AND
				    [Example_Staging].[ExampleTypeConversion].[Staging_ID] NOT IN 
					(
						SELECT src.[Staging_ID]
						FROM [Example_Staging].[ExampleTypeConversion] src
						INNER JOIN [Examples].[DimExampleTypeConversion] dest 
						ON dest.[ExampleTypeConversion_Id] =  src.[ExampleTypeConversion_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
						WHERE
						    src.[ETLBatch_Id] = @Batch_ID		
						    AND
						    src.[DataState_Id] = 1
						    
	)



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Inserting new records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode
			 --------------------------------------------------------------------

		 END TRY
		  BEGIN CATCH

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [Example_Staging].[ExampleTypeConversion] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH


	    SET @ETLLoadStatus_Id = 4

	    -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Updating dimension records from staging data' , NULL;
	    BEGIN TRY



				    UPDATE dest
					  SET 
						 dest.[A_Text_Field] = src.[ATextField]
					   , dest.[Integer_Style_Timestamp] = [DWHUtils].[IntegerTimestampToDatetime](src.[Integer_Style_Timestamp])
					   , dest.[ETLBatch_Id] = src.[ETLBatch_Id]
						 , [DataState_Id] = 5
					 FROM 
						  [Examples].[DimExampleTypeConversion] dest
					 INNER JOIN  [Example_Staging].[ExampleTypeConversion] src  
					 ON  
					 dest.[ExampleTypeConversion_Id] =  src.[ExampleTypeConversion_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
					   WHERE
					  dest.[Integer_Style_Timestamp] <=  [DWHUtils].[IntegerTimestampToDatetime](src.[Integer_Style_Timestamp]) AND 
					  
					   src.[ETLBatch_Id] = @Batch_ID		
					   AND
					   src.DataState_Id = 1
					   


			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Updating records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode

			 --------------------------------------------------------------------	
			  
			 -- Records have been ingested, can delete them from staging.
			 DELETE
			 FROM [Example_Staging].[ExampleTypeConversion]  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1

			 
			 

	   END TRY
		  BEGIN CATCH
  		 
			  -- ON-ERROR CLEANUP OF BATCH RECORDS ------------------------------
		   		  
			  -- The new records had their non-nullable fields inserted successfully 
			  -- in the earlier INSERT TRY-CATCH section 
			  -- BUT there was a major problem with the fields being UPDATED,
			  -- we need to remove the new key records until the problem is resolved

			  -- AS the UPDATE has been rolled back, all records with the current ETLBatch_ID
			  -- must be new records

			  DELETE FROM [Examples].[DimExampleTypeConversion]
			   WHERE [ETLBatch_Id] = @Batch_ID 		  

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [dbo].[TestTable_NoModifiedDatePresent] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH
 

	   SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[ExampleTypeConversion] WHERE ETLBatch_Id IS NULL)
    END
END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTypeConversion_Flag_Records_For_Loading]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTypeConversion_Flag_Records_For_Loading] AS' 
END
GO
/* -- DEBUGGING UTILITY TO RESET DATA IN STAGING -----------------------------------
UPDATE [Example_Staging].[ExampleTypeConversion]
               SET 	 [ETLBatch_Id] = NULL
			, DataState_Id  = NULL 
*/

ALTER PROCEDURE  [Examples].[Load_DimExampleTypeConversion_Flag_Records_For_Loading]
( @Batch_ID bigint )
AS
BEGIN

    BEGIN TRY

	   DECLARE @StepId int
	   DECLARE @ETLLoadStatusId int
	   SET @ETLLoadStatusId = 2    /* = "Identifying Batch Records In Staging"*/
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit
	   DECLARE @ErrorCode int

	   SET @Message = 'Flagging operation failed'
	   SET  @RecordsAffected = 0
	   SET @Success = 0
	   SET @ErrorCode = NULL

	   EXECUTE @StepId = [etl].[AddETLBatchStepStatus] @Batch_ID , 2 , 'Flagging Started ...' , NULL;
	    ;WITH CandidateRecords
		  AS (
		  SELECT TOP 10000 Staging_ID
			    FROM [Example_Staging].[ExampleTypeConversion]
			    WHERE
				[ETLBatch_Id] IS NULL
			    ORDER BY Staging_ID ASC
		  )
		  UPDATE s
		  SET [ETLBatch_Id]	  = @Batch_ID ,
			 [DataState_Id]  = 1
			 FROM Example_Staging.ExampleTypeConversion s
				 INNER JOIN   CandidateRecords c ON c.Staging_Id = s.Staging_Id

		  SET @RecordsAffected = @@ROWCOUNT

		  SET @Message = 'Flagging operation succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
		  @StepId
		  , @ETLLoadStatusId
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode

    END TRY
    BEGIN CATCH	 
			 
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()    
			 			
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @StepId
			 , @ETLLoadStatusId
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode ;
			
			RAISERROR(@Message,16,1)
    END CATCH
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTypeConversion_HandleDeletedRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTypeConversion_HandleDeletedRecords] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleTypeConversion_HandleDeletedRecords]
(@Batch_Id bigint)
AS
BEGIN

    /* ===================================================================================================================
     BI BUILDER COULD NOT DETECT A COLUMN IN [Example_Staging].[ExampleTypeConversion] 
	TO USE FOR GENERATING DELETION LOGIC.

	This procedure is currently a placeholder awaiting development of a mechanism to delete records from the dimension.

     There is no column in the [Example_Staging].[ExampleTypeConversion] table
     that could be detected through metadata as a "Deleted Record Flag" field.

     Note: Detection takes place in the following stored procedure:
     EXECUTE [bib].[FlagDeletedBitFieldInStagingTable]	'Example_Staging','ExampleTypeConversion'

	You can modify that routine so it does detect the column(s) commonly used in your data sources to mark deleted records.
    
     If there is no column to mark deleted records in the  [Example_Staging].[ExampleTypeConversion] table,
     you will need to develop a strategy to remove deleted records from the 
     dimension table [Examples].[DimExampleTypeConversion].

	That might involve downloading all non-deleted keys from the source system and comparing that list
	to the keys you are storing in the data warehouse.

     You may not need to delete records at all - it depends of course on the nature of the source system. 
	If the source table has a column to flag soft deletes and you simply want to pass those records 
	through intact to the dimension, that should happen when you run the [bib][Main] routine to build the ETL.

     You may also have requirements to store deleted records as soft deletes in the dimension with a 
     view to report on those separately.
     This could be the case if the DWH is used for fraud detection of if the definition of "deleted record" in your requirements is different
     to "a record that should no longer be in the dimension at all".
    --=================================================================================================================== */

    PRINT ' ** Development Note: -------------------------------------------------------------------------------
This procedure  [Examples].[Load_DimExampleTypeConversion_HandleDeletedRecords] is currently 
a placeholder awaiting development of a system to delete records from the dimension.

Look at the notes inside this placeholder procedure.
----------------------------------------------------------------------------------------------------------
'

END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimExampleTypeConversion_SetDefaultValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimExampleTypeConversion_SetDefaultValues] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimExampleTypeConversion_SetDefaultValues]
AS 
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @Message nvarchar(1024)
BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM [Examples].[DimExampleTypeConversion] WHERE [DimExampleTypeConversion_DID] = -1)
    BEGIN

    SET IDENTITY_INSERT [Examples].[DimExampleTypeConversion] ON

    INSERT INTO [Examples].[DimExampleTypeConversion](
		 [DimExampleTypeConversion_did]
    , [A_Text_Field]
    , [ExampleTypeConversion_Id]
    , [Integer_Style_Timestamp]
    , [SourceSystem_Id]
    , [ETLBatch_Id]
    , [DataState_Id]
    )

    SELECT 
		 -1
	    , 'N/A'
,0
,'Jan 1 1900'
,0
,0
,6

    SET IDENTITY_INSERT [Examples].[DimExampleTypeConversion] OFF
	RETURN 0
    END 

END TRY
BEGIN CATCH
   
     SET @Message = '
-- ### BI BUILDER ERROR MESSAGE ####################################################################################################
ERROR:  [Examples].[Load_DimExampleTypeConversion_SetDefaultValues] has attempted to insert a record that violates a CHECK CONSTRAINT.
			 
Take a look at the routine [Sales].[Load_DimSalesOrderDetails_SetDefaultValues] and edit it so it inserts the default record OK.

ERROR MESSAGE FROM SQL SERVER: '+ERROR_MESSAGE()+'
-- ###############################################################################################################################
'
    RAISERROR(@Message, 16,1)    
    
END CATCH

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractors]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractors] AS' 
END
GO
 
/*
--=====================================================================================================================
-- MANUAL TESTING UTILITY ROUTINES FOR [Examples].[Load_DimTractors]
------------------------------------------------------------------------
-- Records in Dimension
SELECT * FROM	    [Examples].[DimTractors]
SELECT COUNT(*) FROM [Examples].[DimTractors]

-- Records in Staging
SELECT * FROM	     [Example_Staging].[Tractors]
SELECT COUNT(*) FROM  [Example_Staging].[Tractors]

-- To start from absolute scratch with no pre-existing logs, restaged records in the staging table and an empty dimension table
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 1,1,1,1,1

-- See the logs of previous ETL runs
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,0,0,1

-- Clear the logs for this dimension
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 1,0,0,0,0

-- Clear the logs, restage the test data and truncate the dimension
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 1,1,1,0,0

-- To restage data in the staging table 
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,1,0,0

-- To run process on whatever is in the staging table and show log
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,0,1,1

-- To Rerun the process on restaged data in the staging table 
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,1,1,1

-- To Rerun the process on previously ingested data in the staging table 
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,1,1,1 -- refill staging and run load routine again, show log, should be updaes but no new records
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,0,1,1 -- try reingesting staged data again - staging should be empty of records and log should show no change since last run

-- To test deletions
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,1,0,0 -- restage the data
UPDATE   [Example_Staging].[Tractors] 
    SET [Record_Deleted] = 1 WHERE Staging_Id < 3 -- flag the first 2 records as deleted
EXECUTE  [Examples].[Load_DimTractors_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE   [Examples].[Load_DimTractors_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, then in one batch there were 2 deletions and ModelTableSampleRows-2 updates
SELECT * FROM	    [Examples].[DimTractors] -- checkout the records in the dimension to ensure the flagged record(s) have been deleted



--===================================================================================================================== 
*/

ALTER PROCEDURE [Examples].[Load_DimTractors]
AS 
BEGIN
--***************************************************************************************
-- This is an ETL routine that conducts data (new or updated or deleted as well as possibly stale/redundant)  
-- from the staging table [Example_Staging].[Tractors] to the 
-- dimension table [Examples].[DimTractors]
-----------------------------------------------------------------------------------------

SET NOCOUNT ON
-- (Uncomment if required) SET DATEFORMAT dmy 

-- Ensure that the dimension has an unknown "-1" key record holding default values
-- for when the fact table has no proper key into the dimension
DECLARE @ErrorCode int 
SET @ErrorCode = 0 
EXECUTE @ErrorCode = [Examples].[Load_DimTractors_SetDefaultValues]
IF @ErrorCode <> 0
BEGIN
    RETURN
END
   
DECLARE @UnloadedCount int
SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[Tractors] WHERE ETLBatch_Id IS NULL)
WHILE @UnloadedCount > 0
    BEGIN 

	   DECLARE @Batch_ID bigint  
	   DECLARE @Step_ID bigint  
	   DECLARE @ETLLoadStatus_Id int  
	   DECLARE @ProcessName varchar(50)
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit

	    SET @ProcessName = '[Examples].[Load_DimTractors]'
	    EXECUTE @Batch_ID = [ETL].[InitiateETLBatch] @ProcessName	
	
	   
	    EXECUTE [Examples].[Load_DimTractors_Flag_Records_For_Loading] @Batch_ID

	    SET @ETLLoadStatus_Id = 3

	    EXECUTE [Examples].[Load_DimTractors_HandleDeletedRecords] @Batch_ID

	   -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [ETL].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Inserting New Records into Dimension' , NULL;

	    BEGIN TRY 


				INSERT INTO [Examples].[DimTractors](
					  [Record_Deleted]
					   , [Record_Last_Updated]
					   , [Tractor_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  ,[DataState_Id]
				)

				SELECT 
					  [Record_Deleted]
					   , [Record_Last_Updated]
					   , [Tractor_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  , 4
				FROM
					   [Example_Staging].[Tractors]

				WHERE 				
				    [Example_Staging].[Tractors].[ETLBatch_Id] = @Batch_ID
				    AND
				   [Example_Staging].[Tractors].[Record_Deleted] = 0
				    AND
				    [Example_Staging].[Tractors].[Staging_ID] NOT IN 
					(
						SELECT src.[Staging_ID]
						FROM [Example_Staging].[Tractors] src
						INNER JOIN [Examples].[DimTractors] dest 
						ON dest.[Tractor_Id] =  src.[Tractor_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
						WHERE
						    src.[ETLBatch_Id] = @Batch_ID		
						    AND
						    src.[DataState_Id] = 1
						    AND  src.[Record_Deleted] = 0

	)



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Inserting new records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode
			 --------------------------------------------------------------------

		 END TRY
		  BEGIN CATCH

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [Example_Staging].[Tractors] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH


	    SET @ETLLoadStatus_Id = 4

	    -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Updating dimension records from staging data' , NULL;
	    BEGIN TRY



				    UPDATE dest
					  SET 
						 dest.[Catalogue_Number] = src.[Catalogue_Number]
					   , dest.[CountryOfManufacture_Id] = src.[CountryOfManufacture_Id]
					   , dest.[Manufacturer_Id] = src.[Manufacturer_Id]
					   , dest.[Model_Family_Name] = src.[ModelFamilyName]
					   , dest.[Record_Deleted] = src.[Record_Deleted]
					   , dest.[Record_Last_Updated] = src.[Record_Last_Updated]
					   , dest.[Tractor_Model_Name] = src.[TractorModelName]
					   , dest.[ETLBatch_Id] = src.[ETLBatch_Id]
						 , [DataState_Id] = 5
					 FROM 
						  [Examples].[DimTractors] dest
					 INNER JOIN  [Example_Staging].[Tractors] src  
					 ON  
					 dest.[Tractor_Id] =  src.[Tractor_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
					   WHERE
					  dest.[Record_Last_Updated] <=  src.[Record_Last_Updated] AND 
					  
					   src.[ETLBatch_Id] = @Batch_ID		
					   AND
					   src.DataState_Id = 1
					   AND  src.[Record_Deleted] = 0



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Updating records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode

			 --------------------------------------------------------------------	
			  
			 -- Records have been ingested, can delete them from staging.
			 DELETE
			 FROM [Example_Staging].[Tractors]  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1

			 
			 

	   END TRY
		  BEGIN CATCH
  		 
			  -- ON-ERROR CLEANUP OF BATCH RECORDS ------------------------------
		   		  
			  -- The new records had their non-nullable fields inserted successfully 
			  -- in the earlier INSERT TRY-CATCH section 
			  -- BUT there was a major problem with the fields being UPDATED,
			  -- we need to remove the new key records until the problem is resolved

			  -- AS the UPDATE has been rolled back, all records with the current ETLBatch_ID
			  -- must be new records

			  DELETE FROM [Examples].[DimTractors]
			   WHERE [ETLBatch_Id] = @Batch_ID 		  

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [dbo].[TestTable_NoModifiedDatePresent] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH
 

	   SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[Tractors] WHERE ETLBatch_Id IS NULL)
    END
END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractors_Flag_Records_For_Loading]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractors_Flag_Records_For_Loading] AS' 
END
GO
/* -- DEBUGGING UTILITY TO RESET DATA IN STAGING -----------------------------------
UPDATE [Example_Staging].[Tractors]
               SET 	 [ETLBatch_Id] = NULL
			, DataState_Id  = NULL 
*/

ALTER PROCEDURE  [Examples].[Load_DimTractors_Flag_Records_For_Loading]
( @Batch_ID bigint )
AS
BEGIN

    BEGIN TRY

	   DECLARE @StepId int
	   DECLARE @ETLLoadStatusId int
	   SET @ETLLoadStatusId = 2    /* = "Identifying Batch Records In Staging"*/
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit
	   DECLARE @ErrorCode int

	   SET @Message = 'Flagging operation failed'
	   SET  @RecordsAffected = 0
	   SET @Success = 0
	   SET @ErrorCode = NULL

	   EXECUTE @StepId = [etl].[AddETLBatchStepStatus] @Batch_ID , 2 , 'Flagging Started ...' , NULL;
	    ;WITH CandidateRecords
		  AS (
		  SELECT TOP 10000 Staging_ID
			    FROM [Example_Staging].[Tractors]
			    WHERE
				[ETLBatch_Id] IS NULL
			    ORDER BY Staging_ID ASC
		  )
		  UPDATE s
		  SET [ETLBatch_Id]	  = @Batch_ID ,
			 [DataState_Id]  = 1
			 FROM Example_Staging.Tractors s
				 INNER JOIN   CandidateRecords c ON c.Staging_Id = s.Staging_Id

		  SET @RecordsAffected = @@ROWCOUNT

		  SET @Message = 'Flagging operation succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
		  @StepId
		  , @ETLLoadStatusId
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode

    END TRY
    BEGIN CATCH	 
			 
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()    
			 			
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @StepId
			 , @ETLLoadStatusId
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode ;
			
			RAISERROR(@Message,16,1)
    END CATCH
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractors_HandleDeletedRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractors_HandleDeletedRecords] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimTractors_HandleDeletedRecords]
(@Batch_Id bigint)
AS
BEGIN
    DECLARE @Message nvarchar( 255 )
    DECLARE @RecordsAffected int
    DECLARE @Success bit
    DECLARE @ErrorCode int 
    DECLARE @Step_ID bigint  
    DECLARE @ETLLoadStatus_Id int 
    
    SET @ETLLoadStatus_Id = 4 

     EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Deleting flagged records from dimension' , NULL;
    BEGIN TRY 

		  ;WITH StagedDeletedRecords AS
		  (
			 SELECT
			 DimTractors_DID
				   FROM
					   [Example_Staging].[Tractors] src
					   INNER JOIN [Examples].[DimTractors] dest 
						  ON 
							 dest.[Tractor_Id] =  src.[Tractor_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
				   WHERE
				   src.Record_Deleted  = 1
				   AND
				   src.[DataState_Id] = 1
				   AND
				   src.ETLBatch_Id = @Batch_Id     
		  )
		  DELETE FROM [Examples].[DimTractors]
			WHERE		 DimTractors_DID IN
			( SELECT DimTractors_DID
				    FROM StagedDeletedRecords )
				    
 
	
		  -- SUCCESS LOGGING -------------------------------------------------
		  SET @RecordsAffected = @@ROWCOUNT
		  SET @Message = 'Deleting flagged records succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL 
		  
		  UPDATE  [Example_Staging].[Tractors]
		  SET DataState_Id = 2
		  FROM   [Example_Staging].[Tractors]
				   WHERE
				   [Record_Deleted]  = 1
				   AND
				   [DataState_Id] = 1
				   AND
				   ETLBatch_Id = @Batch_Id    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
			 @Step_Id
		  , @ETLLoadStatus_Id
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode
		  --------------------------------------------------------------------
	   END TRY
	   BEGIN CATCH

		  -- FAILURE LOGGING -------------------------------------------------		  	  
		  SET @RecordsAffected = -1
		  SET @Message = ERROR_MESSAGE()
		  SET @Success = 0
		  SET @ErrorCode = ERROR_NUMBER()
		  
		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
					   @Step_Id
				    , @ETLLoadStatus_Id
				    , @Message
				    , @RecordsAffected
				    , @Success
				    , @ErrorCode   ;
		  --------------------------------------------------------------------

		 RAISERROR(@Message, 16, 1);
	   END CATCH
END	  
		  

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractors_SetDefaultValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractors_SetDefaultValues] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimTractors_SetDefaultValues]
AS 
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @Message nvarchar(1024)
BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM [Examples].[DimTractors] WHERE [DimTractors_DID] = -1)
    BEGIN

    SET IDENTITY_INSERT [Examples].[DimTractors] ON

    INSERT INTO [Examples].[DimTractors](
		 [DimTractors_did]
    , [Catalogue_Number]
    , [CountryOfManufacture_Id]
    , [Manufacturer_Id]
    , [Model_Family_Name]
    , [Record_Deleted]
    , [Record_Last_Updated]
    , [Tractor_Id]
    , [Tractor_Model_Name]
    , [SourceSystem_Id]
    , [ETLBatch_Id]
    , [DataState_Id]
    )

    SELECT 
		 -1
	    , NULL
,NULL
,NULL
,NULL
,0
,'Jan 1 1900'
,0
,NULL
,0
,0
,6

    SET IDENTITY_INSERT [Examples].[DimTractors] OFF
	RETURN 0
    END 

END TRY
BEGIN CATCH
   
     SET @Message = '
-- ### BI BUILDER ERROR MESSAGE ####################################################################################################
ERROR:  [Examples].[Load_DimTractors_SetDefaultValues] has attempted to insert a record that violates a CHECK CONSTRAINT.
			 
Take a look at the routine [Sales].[Load_DimSalesOrderDetails_SetDefaultValues] and edit it so it inserts the default record OK.

ERROR MESSAGE FROM SQL SERVER: '+ERROR_MESSAGE()+'
-- ###############################################################################################################################
'
    RAISERROR(@Message, 16,1)    
    
END CATCH

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractorsSCDType2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractorsSCDType2] AS' 
END
GO
 
/*
--=====================================================================================================================
-- MANUAL TESTING UTILITY ROUTINES FOR [Examples].[Load_DimTractorsSCDType2]
------------------------------------------------------------------------
-- Records in Dimension
SELECT * FROM	    [Examples].[DimTractorsSCDType2]
SELECT COUNT(*) FROM [Examples].[DimTractorsSCDType2]

-- Records in Staging
SELECT * FROM	     [Example_Staging].[TractorsSCDType2]
SELECT COUNT(*) FROM  [Example_Staging].[TractorsSCDType2]

-- To start from absolute scratch with no pre-existing logs, restaged records in the staging table and an empty dimension table
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 1,1,1,1,1

-- See the logs of previous ETL runs
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,0,0,1

-- Clear the logs for this dimension
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 1,0,0,0,0

-- Clear the logs, restage the test data and truncate the dimension
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 1,1,1,0,0

-- To restage data in the staging table 
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,1,0,0

-- To run process on whatever is in the staging table and show log
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,0,1,1

-- To Rerun the process on restaged data in the staging table 
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,1,1,1

-- To Rerun the process on previously ingested data in the staging table 
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,1,1,1 -- refill staging and run load routine again, show log, should be updaes but no new records
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,0,1,1 -- try reingesting staged data again - staging should be empty of records and log should show no change since last run

-- To test deletions
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,1,0,0 -- restage the data
UPDATE   [Example_Staging].[TractorsSCDType2] 
    SET [Record_Deleted] = 1 WHERE Staging_Id < 3 -- flag the first 2 records as deleted
EXECUTE  [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE   [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, then in one batch there were 2 deletions and ModelTableSampleRows-2 updates
SELECT * FROM	    [Examples].[DimTractorsSCDType2] -- checkout the records in the dimension to ensure the flagged record(s) have been deleted


-- To test SCD functionality
EXECUTE   [Examples].[Load_DimTractorsSCDType2_ManualTesting] 1,1,1,1,0 -- reset and run first, no log report
EXECUTE   [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,1,0,0 -- restage the data
-- Adjust one of the SCD columns
UPDATE   [Example_Staging].[TractorsSCDType2] 
    SET [Manufacturer_Id] = *PUT NEW VALUE HERE* -- to trigger a new record created in the dimension when loaded
	   , [Record_Last_Updated] = GETDATE()
    FROM    [Example_Staging].[TractorsSCDType2]     
    WHERE Staging_Id = 1
EXECUTE   [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,0,1,0 -- run the load
EXECUTE    [Examples].[Load_DimTractorsSCDType2_ManualTesting] 0,0,0,0,1 -- check the logs to see that records were inserted and updated, should be 1 insert and 1 update
SELECT * FROM	    [Examples].[DimTractorsSCDType2] -- check out the records to ensure the the EffectiveFinish date and Active record flags have been set correctly


--===================================================================================================================== 
*/

ALTER PROCEDURE [Examples].[Load_DimTractorsSCDType2]
AS 
BEGIN
--***************************************************************************************
-- This is an ETL routine that conducts data (new or updated or deleted as well as possibly stale/redundant)  
-- from the staging table [Example_Staging].[TractorsSCDType2] to the 
-- dimension table [Examples].[DimTractorsSCDType2]
-----------------------------------------------------------------------------------------

SET NOCOUNT ON
-- (Uncomment if required) SET DATEFORMAT dmy 

-- Ensure that the dimension has an unknown "-1" key record holding default values
-- for when the fact table has no proper key into the dimension
DECLARE @ErrorCode int 
SET @ErrorCode = 0 
EXECUTE @ErrorCode = [Examples].[Load_DimTractorsSCDType2_SetDefaultValues]
IF @ErrorCode <> 0
BEGIN
    RETURN
END
   
DECLARE @UnloadedCount int
SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[TractorsSCDType2] WHERE ETLBatch_Id IS NULL)
WHILE @UnloadedCount > 0
    BEGIN 

	   DECLARE @Batch_ID bigint  
	   DECLARE @Step_ID bigint  
	   DECLARE @ETLLoadStatus_Id int  
	   DECLARE @ProcessName varchar(50)
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit

	    SET @ProcessName = '[Examples].[Load_DimTractorsSCDType2]'
	    EXECUTE @Batch_ID = [ETL].[InitiateETLBatch] @ProcessName	
	
	   
	    EXECUTE [Examples].[Load_DimTractorsSCDType2_Flag_Records_For_Loading] @Batch_ID

	    SET @ETLLoadStatus_Id = 3

	    EXECUTE [Examples].[Load_DimTractorsSCDType2_HandleDeletedRecords] @Batch_ID

	   -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [ETL].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Inserting New Records into Dimension' , NULL;

	    BEGIN TRY 


				INSERT INTO [Examples].[DimTractorsSCDType2](
					  [CountryOfManufacture_Id]
					   , [Manufacturer_Id]
					   , [Record_Deleted]
					   , [Record_Last_Updated]
					   , [Tractor_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  ,[DataState_Id]
				)

				SELECT 
					  [CountryOfManufacture_Id]
					   , [Manufacturer_Id]
					   , [Record_Deleted]
					   , [Record_Last_Updated]
					   , [Tractor_Id]
					   , [SourceSystem_Id]
					   , [ETLBatch_Id]
					  , 4
				FROM
					   [Example_Staging].[TractorsSCDType2]

				WHERE 				
				    [Example_Staging].[TractorsSCDType2].[ETLBatch_Id] = @Batch_ID
				    AND
				   [Example_Staging].[TractorsSCDType2].[Record_Deleted] = 0
				    AND
				    [Example_Staging].[TractorsSCDType2].[Staging_ID] NOT IN 
					(
						SELECT src.[Staging_ID]
						FROM [Example_Staging].[TractorsSCDType2] src
						INNER JOIN [Examples].[DimTractorsSCDType2] dest 
						ON dest.[CountryOfManufacture_Id] =  src.[CountryOfManufacture_Id]
						  AND dest.[Manufacturer_Id] =  src.[Manufacturer_Id]
						  AND dest.[Tractor_Id] =  src.[Tractor_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
						WHERE
						    src.[ETLBatch_Id] = @Batch_ID		
						    AND
						    src.[DataState_Id] = 1
						    AND  src.[Record_Deleted] = 0

	)



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Inserting new records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode
			 --------------------------------------------------------------------

		 END TRY
		  BEGIN CATCH

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [Example_Staging].[TractorsSCDType2] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH


	    SET @ETLLoadStatus_Id = 4

	    -- Insert the key fields and non-nullable fields for any new records
	    EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Updating dimension records from staging data' , NULL;
	    BEGIN TRY



				    UPDATE dest
					  SET 
						 dest.[Catalogue_Number] = src.[Catalogue_Number]
					   , dest.[CountryOfManufacture_Id] = src.[CountryOfManufacture_Id]
					   , dest.[Manufacturer_Id] = src.[Manufacturer_Id]
					   , dest.[Model_Family_Name] = src.[ModelFamilyName]
					   , dest.[Record_Deleted] = src.[Record_Deleted]
					   , dest.[Record_Last_Updated] = src.[Record_Last_Updated]
					   , dest.[Tractor_Model_Name] = src.[TractorModelName]
					   , dest.[ETLBatch_Id] = src.[ETLBatch_Id]
						 , [DataState_Id] = 5
					 FROM 
						  [Examples].[DimTractorsSCDType2] dest
					 INNER JOIN  [Example_Staging].[TractorsSCDType2] src  
					 ON  
					 dest.[CountryOfManufacture_Id] =  src.[CountryOfManufacture_Id]
						  AND dest.[Manufacturer_Id] =  src.[Manufacturer_Id]
						  AND dest.[Tractor_Id] =  src.[Tractor_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
					   WHERE
					  dest.[Record_Last_Updated] <=  src.[Record_Last_Updated] AND 
					  
					   src.[ETLBatch_Id] = @Batch_ID		
					   AND
					   src.DataState_Id = 1
					   AND  src.[Record_Deleted] = 0



			 -- SUCCESS LOGGING -------------------------------------------------
			 SET @RecordsAffected = @@ROWCOUNT
			 SET @Message = 'Updating records succeeded'
			 SET @Success = 1
			 SET @ErrorCode = NULL    

			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @Step_Id
			 , @ETLLoadStatus_Id
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode

			 --------------------------------------------------------------------	
			  
			 -- Records have been ingested, can delete them from staging.
			 DELETE
			 FROM [Example_Staging].[TractorsSCDType2]  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1

			 
			 			 -- Dimension is SCD type 2 - must zero out active flags from superceeded records
			 ;WITH MostRecentlyUpdated AS
			 (
			 SELECT        
				  [Tractor_Id]
					   , [SourceSystem_Id]
				 , MAX ( EffectiveStart )  AS EffectiveStart
			 FROM  [Examples].[DimTractorsSCDType2]
			 WHERE  ActiveRecord = 1 AND DataState_Id = 5
			 GROUP BY 
				 [Tractor_Id]
					   , [SourceSystem_Id] 
			 )
			 UPDATE  [Examples].[DimTractorsSCDType2]
			 SET	   ActiveRecord = 0
			 FROM  [Examples].[DimTractorsSCDType2]
			 WHERE 
			 [Examples].[DimTractorsSCDType2].[DimTractorsSCDType2_did] > -1
			 AND
			 [Examples].[DimTractorsSCDType2].ActiveRecord = 1 AND [Examples].[DimTractorsSCDType2].DataState_Id = 5
			 AND
			 [Examples].[DimTractorsSCDType2].[DimTractorsSCDType2_did] NOT IN
			 (SELECT [Examples].[DimTractorsSCDType2].[DimTractorsSCDType2_did]
			 FROM  [Examples].[DimTractorsSCDType2]
			 INNER JOIN MostRecentlyUpdated ON 
				MostRecentlyUpdated.EffectiveStart = [Examples].[DimTractorsSCDType2].EffectiveStart 
				AND
					MostRecentlyUpdated.Tractor_Id =  [Examples].[DimTractorsSCDType2].[Tractor_Id]
AND
	MostRecentlyUpdated.SourceSystem_Id =  [Examples].[DimTractorsSCDType2].[SourceSystem_Id]
			 )

			 -- then set effective finish for records superceeded in this batch
			 
			 ;WITH ActiveSCDRecords AS
			 (
			 SELECT        
				   [Tractor_Id]
					   , [SourceSystem_Id] 
				 , MAX ( EffectiveStart )  AS EffectiveStart
			 FROM   [Examples].[DimTractorsSCDType2]
			 WHERE  ActiveRecord = 1 AND DataState_Id = 5
			 GROUP BY 
				 [Tractor_Id]
					   , [SourceSystem_Id] 

			 )
			 UPDATE   [Examples].[DimTractorsSCDType2]
			 SET	   EffectiveFinish = DATEADD(ms, -1, ActiveSCDRecords.EffectiveStart)
			 FROM   [Examples].[DimTractorsSCDType2]
			  INNER JOIN ActiveSCDRecords ON 				
					ActiveSCDRecords.Tractor_Id =  [Examples].[DimTractorsSCDType2].[Tractor_Id]
AND
	ActiveSCDRecords.SourceSystem_Id =  [Examples].[DimTractorsSCDType2].[SourceSystem_Id]
			 WHERE 
			  [Examples].[DimTractorsSCDType2].[DimTractorsSCDType2_did] > -1
			 AND
			  [Examples].[DimTractorsSCDType2].ActiveRecord = 0
			 AND
			  [Examples].[DimTractorsSCDType2].EffectiveFinish IS NULL			  
			 AND  [Examples].[DimTractorsSCDType2].DataState_Id = 5


	   END TRY
		  BEGIN CATCH
  		 
			  -- ON-ERROR CLEANUP OF BATCH RECORDS ------------------------------
		   		  
			  -- The new records had their non-nullable fields inserted successfully 
			  -- in the earlier INSERT TRY-CATCH section 
			  -- BUT there was a major problem with the fields being UPDATED,
			  -- we need to remove the new key records until the problem is resolved

			  -- AS the UPDATE has been rolled back, all records with the current ETLBatch_ID
			  -- must be new records

			  DELETE FROM [Examples].[DimTractorsSCDType2]
			   WHERE [ETLBatch_Id] = @Batch_ID 		  

			 -- FAILURE LOGGING -------------------------------------------------		  	  
			 SET @RecordsAffected = -1
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()
		  
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
						@Step_Id
					   , @ETLLoadStatus_Id
					   , @Message
					   , @RecordsAffected
					   , @Success
					   , @ErrorCode   ;
			 --------------------------------------------------------------------
			  UPDATE src
				SET DataState_Id = 3 -- indicating there was an error loading this batch of staged records
			 FROM [dbo].[TestTable_NoModifiedDatePresent] src  
			 WHERE
				ETLBatch_Id = @Batch_ID
				AND
				DataState_Id = 1;

			 RAISERROR(@Message, 16, 1);
		  END CATCH
 

	   SET @UnloadedCount = (SELECT COUNT(*) FROM [Example_Staging].[TractorsSCDType2] WHERE ETLBatch_Id IS NULL)
    END
END 

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractorsSCDType2_Flag_Records_For_Loading]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractorsSCDType2_Flag_Records_For_Loading] AS' 
END
GO
/* -- DEBUGGING UTILITY TO RESET DATA IN STAGING -----------------------------------
UPDATE [Example_Staging].[TractorsSCDType2]
               SET 	 [ETLBatch_Id] = NULL
			, DataState_Id  = NULL 
*/

ALTER PROCEDURE  [Examples].[Load_DimTractorsSCDType2_Flag_Records_For_Loading]
( @Batch_ID bigint )
AS
BEGIN

    BEGIN TRY

	   DECLARE @StepId int
	   DECLARE @ETLLoadStatusId int
	   SET @ETLLoadStatusId = 2    /* = "Identifying Batch Records In Staging"*/
	   DECLARE @Message nvarchar( 255 )
	   DECLARE @RecordsAffected int
	   DECLARE @Success bit
	   DECLARE @ErrorCode int

	   SET @Message = 'Flagging operation failed'
	   SET  @RecordsAffected = 0
	   SET @Success = 0
	   SET @ErrorCode = NULL

	   EXECUTE @StepId = [etl].[AddETLBatchStepStatus] @Batch_ID , 2 , 'Flagging Started ...' , NULL;
	    ;WITH CandidateRecords
		  AS (
		  SELECT TOP 10000 Staging_ID
			    FROM [Example_Staging].[TractorsSCDType2]
			    WHERE
				[ETLBatch_Id] IS NULL
			    ORDER BY Staging_ID ASC
		  )
		  UPDATE s
		  SET [ETLBatch_Id]	  = @Batch_ID ,
			 [DataState_Id]  = 1
			 FROM Example_Staging.TractorsSCDType2 s
				 INNER JOIN   CandidateRecords c ON c.Staging_Id = s.Staging_Id

		  SET @RecordsAffected = @@ROWCOUNT

		  SET @Message = 'Flagging operation succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
		  @StepId
		  , @ETLLoadStatusId
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode

    END TRY
    BEGIN CATCH	 
			 
			 SET @Message = ERROR_MESSAGE()
			 SET @Success = 0
			 SET @ErrorCode = ERROR_NUMBER()    
			 			
			 EXECUTE [ETL].[UpdateETLBatchStepStatus]
			   @StepId
			 , @ETLLoadStatusId
			 , @Message
			 , @RecordsAffected
			 , @Success
			 , @ErrorCode ;
			
			RAISERROR(@Message,16,1)
    END CATCH
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractorsSCDType2_HandleDeletedRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractorsSCDType2_HandleDeletedRecords] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimTractorsSCDType2_HandleDeletedRecords]
(@Batch_Id bigint)
AS
BEGIN
    DECLARE @Message nvarchar( 255 )
    DECLARE @RecordsAffected int
    DECLARE @Success bit
    DECLARE @ErrorCode int 
    DECLARE @Step_ID bigint  
    DECLARE @ETLLoadStatus_Id int 
    
    SET @ETLLoadStatus_Id = 4 

     EXECUTE @Step_Id = [etl].[AddETLBatchStepStatus] @Batch_ID , @ETLLoadStatus_Id , 'Deleting flagged records from dimension' , NULL;
    BEGIN TRY 

		  ;WITH StagedDeletedRecords AS
		  (
			 SELECT
			 DimTractorsSCDType2_DID
				   FROM
					   [Example_Staging].[TractorsSCDType2] src
					   INNER JOIN [Examples].[DimTractorsSCDType2] dest 
						  ON 
							 dest.[CountryOfManufacture_Id] =  src.[CountryOfManufacture_Id]
						  AND dest.[Manufacturer_Id] =  src.[Manufacturer_Id]
						  AND dest.[Tractor_Id] =  src.[Tractor_Id]
						  AND dest.[SourceSystem_Id] =  src.[SourceSystem_Id]
				   WHERE
				   src.Record_Deleted  = 1
				   AND
				   src.[DataState_Id] = 1
				   AND
				   src.ETLBatch_Id = @Batch_Id     
		  )
		  DELETE FROM [Examples].[DimTractorsSCDType2]
			WHERE		 DimTractorsSCDType2_DID IN
			( SELECT DimTractorsSCDType2_DID
				    FROM StagedDeletedRecords )
				    
 
	
		  -- SUCCESS LOGGING -------------------------------------------------
		  SET @RecordsAffected = @@ROWCOUNT
		  SET @Message = 'Deleting flagged records succeeded'
		  SET @Success = 1
		  SET @ErrorCode = NULL 
		  
		  UPDATE  [Example_Staging].[TractorsSCDType2]
		  SET DataState_Id = 2
		  FROM   [Example_Staging].[TractorsSCDType2]
				   WHERE
				   [Record_Deleted]  = 1
				   AND
				   [DataState_Id] = 1
				   AND
				   ETLBatch_Id = @Batch_Id    

		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
			 @Step_Id
		  , @ETLLoadStatus_Id
		  , @Message
		  , @RecordsAffected
		  , @Success
		  , @ErrorCode
		  --------------------------------------------------------------------
	   END TRY
	   BEGIN CATCH

		  -- FAILURE LOGGING -------------------------------------------------		  	  
		  SET @RecordsAffected = -1
		  SET @Message = ERROR_MESSAGE()
		  SET @Success = 0
		  SET @ErrorCode = ERROR_NUMBER()
		  
		  EXECUTE [ETL].[UpdateETLBatchStepStatus]
					   @Step_Id
				    , @ETLLoadStatus_Id
				    , @Message
				    , @RecordsAffected
				    , @Success
				    , @ErrorCode   ;
		  --------------------------------------------------------------------

		 RAISERROR(@Message, 16, 1);
	   END CATCH
END	  
		  

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Examples].[Load_DimTractorsSCDType2_SetDefaultValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Examples].[Load_DimTractorsSCDType2_SetDefaultValues] AS' 
END
GO

ALTER PROCEDURE [Examples].[Load_DimTractorsSCDType2_SetDefaultValues]
AS 
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @Message nvarchar(1024)
BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM [Examples].[DimTractorsSCDType2] WHERE [DimTractorsSCDType2_DID] = -1)
    BEGIN

    SET IDENTITY_INSERT [Examples].[DimTractorsSCDType2] ON

    INSERT INTO [Examples].[DimTractorsSCDType2](
		 [DimTractorsSCDType2_did]
    , [Catalogue_Number]
    , [CountryOfManufacture_Id]
    , [Manufacturer_Id]
    , [Model_Family_Name]
    , [Record_Deleted]
    , [Record_Last_Updated]
    , [Tractor_Id]
    , [Tractor_Model_Name]
    , [SourceSystem_Id]
    , [ETLBatch_Id]
    , [DataState_Id]
    )

    SELECT 
		 -1
	    , NULL
,NULL
,NULL
,NULL
,0
,'Jan 1 1900'
,0
,NULL
,0
,0
,6

    SET IDENTITY_INSERT [Examples].[DimTractorsSCDType2] OFF
	RETURN 0
    END 

END TRY
BEGIN CATCH
   
     SET @Message = '
-- ### BI BUILDER ERROR MESSAGE ####################################################################################################
ERROR:  [Examples].[Load_DimTractorsSCDType2_SetDefaultValues] has attempted to insert a record that violates a CHECK CONSTRAINT.
			 
Take a look at the routine [Sales].[Load_DimSalesOrderDetails_SetDefaultValues] and edit it so it inserts the default record OK.

ERROR MESSAGE FROM SQL SERVER: '+ERROR_MESSAGE()+'
-- ###############################################################################################################################
'
    RAISERROR(@Message, 16,1)    
    
END CATCH

END


GO

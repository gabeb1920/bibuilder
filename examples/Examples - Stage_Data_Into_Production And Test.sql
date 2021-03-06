USE [<ProdDatabaseName>]
GO

SET IDENTITY_INSERT [Example_Staging].[CompositeKeyExample] ON 

INSERT [Example_Staging].[CompositeKeyExample] ([CompositeKeyExample_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (1, N'Fieldmaster 6000', 1, 1, N'Fieldmaster', 1055, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 1, 1, NULL, NULL)
INSERT [Example_Staging].[CompositeKeyExample] ([CompositeKeyExample_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (2, N'Mudblaster 450X', 2, 2, N'Mudblaster', 2054, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 2, 1, NULL, NULL)
INSERT [Example_Staging].[CompositeKeyExample] ([CompositeKeyExample_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (3, N'Computracto 2N', 1, 1, N'Computracto', 766, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 3, 1, NULL, NULL)
SET IDENTITY_INSERT [Example_Staging].[CompositeKeyExample] OFF
SET IDENTITY_INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ON 

INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ([PrimaryKey_Id], [Cust_Id], [StartDate], [CustTypeCode], [IsDeleted], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (1, 1, N'Oct 14 2014 ', 1, 0, 1, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ([PrimaryKey_Id], [Cust_Id], [StartDate], [CustTypeCode], [IsDeleted], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (2, 2, N'Oct 13 2014 ', 2, 0, 2, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ([PrimaryKey_Id], [Cust_Id], [StartDate], [CustTypeCode], [IsDeleted], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (3, 3, N'Oct 12 2014 ', 1, 0, 3, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ([PrimaryKey_Id], [Cust_Id], [StartDate], [CustTypeCode], [IsDeleted], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (4, 4, N'Oct 11 2014 ', 1, 0, 4, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ([PrimaryKey_Id], [Cust_Id], [StartDate], [CustTypeCode], [IsDeleted], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (5, 5, N'Oct 10 2014 ', 1, 0, 5, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ([PrimaryKey_Id], [Cust_Id], [StartDate], [CustTypeCode], [IsDeleted], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (6, 6, N'Oct  9 2014 ', 2, 0, 6, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleOfPausingETLBuilds] ([PrimaryKey_Id], [Cust_Id], [StartDate], [CustTypeCode], [IsDeleted], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (7, 7, N'Oct  8 2014 ', 2, 0, 7, 1, NULL, NULL)
SET IDENTITY_INSERT [Example_Staging].[ExampleOfPausingETLBuilds] OFF
SET IDENTITY_INSERT [Example_Staging].[ExampleTypeConversion] ON 

INSERT [Example_Staging].[ExampleTypeConversion] ([ExampleTypeConversion_Id], [ATextField], [Integer_Style_Timestamp], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (1, N'Example Record 1', 1412080360, 1, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleTypeConversion] ([ExampleTypeConversion_Id], [ATextField], [Integer_Style_Timestamp], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (2, N'Example Record 2', 1411993961, 2, 1, NULL, NULL)
INSERT [Example_Staging].[ExampleTypeConversion] ([ExampleTypeConversion_Id], [ATextField], [Integer_Style_Timestamp], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (3, N'Example Record 3', 1411907561, 3, 1, NULL, NULL)
SET IDENTITY_INSERT [Example_Staging].[ExampleTypeConversion] OFF
SET IDENTITY_INSERT [Example_Staging].[Tractors] ON 

INSERT [Example_Staging].[Tractors] ([Tractor_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (1, N'Fieldmaster 6000', 1, 1, N'Fieldmaster', 1055, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 1, 1, NULL, NULL)
INSERT [Example_Staging].[Tractors] ([Tractor_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (2, N'Mudblaster 450X', 2, 2, N'Mudblaster', 2054, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 2, 1, NULL, NULL)
INSERT [Example_Staging].[Tractors] ([Tractor_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (3, N'Computracto 2N', 1, 1, N'Computracto', 766, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 3, 1, NULL, NULL)
SET IDENTITY_INSERT [Example_Staging].[Tractors] OFF
SET IDENTITY_INSERT [Example_Staging].[TractorsSCDType2] ON 

INSERT [Example_Staging].[TractorsSCDType2] ([Tractor_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (1, N'Fieldmaster 6000', 1, 1, N'Fieldmaster', 1055, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 1, 1, NULL, NULL)
INSERT [Example_Staging].[TractorsSCDType2] ([Tractor_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (2, N'Mudblaster 450X', 2, 2, N'Mudblaster', 2054, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 2, 1, NULL, NULL)
INSERT [Example_Staging].[TractorsSCDType2] ([Tractor_Id], [TractorModelName], [Manufacturer_Id], [CountryOfManufacture_Id], [ModelFamilyName], [Catalogue_Number], [Record_Deleted], [Record_Last_Updated], [Staging_Id], [SourceSystem_Id], [ETLBatch_Id], [DataState_Id]) VALUES (3, N'Computracto 2N', 1, 1, N'Computracto', 766, 0, CAST(N'2014-09-23 16:34:50.483' AS DateTime), 3, 1, NULL, NULL)
SET IDENTITY_INSERT [Example_Staging].[TractorsSCDType2] OFF

EXECUTE  [Examples].[Load_DimCompositeKeyExample]
EXECUTE  [Examples].[Load_DimExampleColumnNameConversion]
EXECUTE  [Examples].[Load_DimExampleOfPausingETLBuilds]
EXECUTE  [Examples].[Load_DimExampleTablewith300Fields]
EXECUTE  [Examples].[Load_DimExampleTypeConversion]
EXECUTE  [Examples].[Load_DimTractors]
EXECUTE  [Examples].[Load_DimTractorsSCDType2]
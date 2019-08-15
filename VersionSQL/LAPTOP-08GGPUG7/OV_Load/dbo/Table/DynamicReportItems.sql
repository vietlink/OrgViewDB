/****** Object:  Table [dbo].[DynamicReportItems]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DynamicReportItems](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AttributeID] [int] NOT NULL,
	[DynamicReportHeaderID] [int] NOT NULL,
	[isShowOnReport] [bit] NULL,
	[isSortBy] [bit] NULL,
	[isSum] [bit] NULL,
	[JustifyVal] [varchar](6) NULL,
	[FormatVal] [varchar](15) NULL,
	[DecimalVal] [int] NULL,
	[WidthVal] [int] NULL,
	[isPrompt] [bit] NULL,
	[RestrictionVal] [int] NULL,
	[FromVal] [varchar](max) NULL,
	[ToVal] [varchar](max) NULL,
	[ListVal] [varchar](max) NULL,
	[SortOrder] [int] NULL,
	[SortOrderVal] [varchar](4) NULL,
	[ColumnOrder] [int] NULL,
 CONSTRAINT [PK_DynamicReportItems] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


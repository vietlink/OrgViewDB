/****** Object:  Table [dbo].[Competencies]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Competencies](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Description] [varchar](500) NULL,
	[SortOrder] [int] NULL,
	[Enabled] [char](1) NULL,
	[Type] [int] NOT NULL,
	[ComplianceScoreType] [int] NOT NULL,
	[ComplianceScoreRange] [int] NULL,
	[DueToExpireDays] [int] NOT NULL,
	[DoesNotExpire] [bit] NOT NULL,
 CONSTRAINT [PK_CategoryList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Competencies] ADD  CONSTRAINT [DF_Competencies_Type]  DEFAULT ((1)) FOR [Type]
ALTER TABLE [dbo].[Competencies] ADD  CONSTRAINT [DF_Competencies_ComplianceScoreType]  DEFAULT ((1)) FOR [ComplianceScoreType]
ALTER TABLE [dbo].[Competencies] ADD  CONSTRAINT [DF_Competencies_DueToExpireDays]  DEFAULT ((0)) FOR [DueToExpireDays]
ALTER TABLE [dbo].[Competencies] ADD  CONSTRAINT [DF_Competencies_DoesNoteExpire]  DEFAULT ((0)) FOR [DoesNotExpire]

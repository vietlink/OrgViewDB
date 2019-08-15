/****** Object:  Table [dbo].[OnBoardingComplianceTemplateItems]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingComplianceTemplateItems](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OnBoardingComplianceTemplateID] [int] NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[ComplianceListID] [int] NOT NULL,
	[IsMandatory] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_OnBoardingTemplateCompliances] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


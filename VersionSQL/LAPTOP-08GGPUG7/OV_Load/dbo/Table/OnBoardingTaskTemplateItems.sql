/****** Object:  Table [dbo].[OnBoardingTaskTemplateItems]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingTaskTemplateItems](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OnBoardingTaskTemplateID] [int] NOT NULL,
	[OnBoardingTaskID] [nchar](10) NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_OnBoardingTaskTemplateItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


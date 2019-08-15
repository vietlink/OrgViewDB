/****** Object:  Table [dbo].[OnBoardingTaskTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingTaskTemplate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](256) NOT NULL,
	[OnBoardingTypeID] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_OnBoardingTaskTemplate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[OnBoardingTaskTemplate] ADD  CONSTRAINT [DF_OnBoardingTaskTemplate_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]

/****** Object:  Table [dbo].[OnBoardingTasks]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingTasks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](512) NOT NULL,
	[OnBoardingTypeID] [int] NOT NULL,
	[OnBoardingTaskCategoryID] [int] NOT NULL,
	[LeadTime] [decimal](10, 5) NOT NULL,
	[DaysBeforeAfter] [decimal](10, 5) NOT NULL,
	[DaysBeforeAfterType] [int] NOT NULL,
	[ActionByType] [int] NOT NULL,
	[ActionByID] [int] NULL,
	[NotifyToID] [int] NULL,
	[EmailTitle] [varchar](256) NULL,
	[EmailBody] [varchar](max) NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_OnBoardingTask] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[OnBoardingTasks] ADD  CONSTRAINT [DF_OnBoardingTask_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]

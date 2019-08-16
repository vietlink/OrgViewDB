/****** Object:  Table [dbo].[OnBoardingTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingTemplate](
	[ID] [int] NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[OnBoardingTypeID] [int] NOT NULL,
	[Html] [varchar](max) NULL,
 CONSTRAINT [PK_OnBoardingTemplate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


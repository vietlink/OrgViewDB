/****** Object:  Table [dbo].[OnBoardingTemplateCheckBoxes]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingTemplateCheckBoxes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](512) NOT NULL,
	[OnBoardingTemplateID] [int] NOT NULL,
	[IsMandatory] [bit] NOT NULL,
	[Code] [varchar](16) NOT NULL,
 CONSTRAINT [PK_OnBoardingTemplateCheckBoxes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[OnBoardingTemplateCheckBoxes] ADD  CONSTRAINT [DF_OnBoardingTemplateCheckBoxes_IsMandatory]  DEFAULT ((1)) FOR [IsMandatory]

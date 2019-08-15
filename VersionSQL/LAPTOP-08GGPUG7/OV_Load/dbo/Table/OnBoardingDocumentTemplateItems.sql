/****** Object:  Table [dbo].[OnBoardingDocumentTemplateItems]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingDocumentTemplateItems](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OnBoardingDocumentTemplateID] [int] NOT NULL,
	[Title] [varchar](100) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[DocumentTypeID] [int] NULL,
	[IsMandatory] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_OnBoardingTemplateDocuments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[OnBoardingDocumentTemplateItems] ADD  CONSTRAINT [DF_OnBoardingTemplateDocuments_IsMandatory]  DEFAULT ((0)) FOR [IsMandatory]

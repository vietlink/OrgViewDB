/****** Object:  Table [dbo].[OnBoardingRecord]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[OnBoardingRecord](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Reference] [varchar](100) NOT NULL,
	[PositionID] [int] NOT NULL,
	[OnBoardingTypeID] [int] NOT NULL,
	[PlannedDate] [datetime] NOT NULL,
	[RequestingManagerEmpID] [int] NOT NULL,
	[OfferTemplateID] [int] NOT NULL,
	[AcceptanceTemplateID] [int] NOT NULL,
	[OnBoardingTaskTemplateID] [int] NOT NULL,
	[OnBoardingDocumentTemplateID] [int] NULL,
	[OnBoardingComplianceTemplateID] [int] NULL,
	[OnBoardingDataEntryTemplateID] [int] NULL,
 CONSTRAINT [PK_OnBoardingRecord] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


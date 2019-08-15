/****** Object:  Table [dbo].[DocumentTypes]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DocumentTypes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Editable] [bit] NOT NULL,
	[Comments] [varchar](500) NULL,
 CONSTRAINT [PK_DocumentTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[DocumentTypes] ADD  CONSTRAINT [DF_DocumentTypes_isDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[DocumentTypes] ADD  CONSTRAINT [DF_DocumentTypes_Editable]  DEFAULT ((1)) FOR [Editable]

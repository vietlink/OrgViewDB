/****** Object:  Table [dbo].[AdminMenuAttributeModuleRelations]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AdminMenuAttributeModuleRelations](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AdminMenuItemID] [int] NULL,
	[AttributeModuleID] [int] NULL,
	[SortOrder] [int] NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_AdminMenuAttributeModuleRelations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[AdminMenuAttributeModuleRelations] ADD  CONSTRAINT [DF_AdminMenuAttributeModuleRelations_IsEnabled]  DEFAULT ((1)) FOR [IsEnabled]

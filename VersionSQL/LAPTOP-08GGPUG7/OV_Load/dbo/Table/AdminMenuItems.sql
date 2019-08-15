/****** Object:  Table [dbo].[AdminMenuItems]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AdminMenuItems](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[SortOrder] [int] NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_AdminMenuItems] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[AdminMenuItems] ADD  CONSTRAINT [DF_AdminMenuItems_IsEnabled]  DEFAULT ((1)) FOR [IsEnabled]

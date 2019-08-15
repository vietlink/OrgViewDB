/****** Object:  Table [dbo].[CountLookupTable]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CountLookupTable](
	[ID] [int] NOT NULL,
	[PositionID] [int] NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[ParentID] [int] NULL,
	[ExclFromSubordCount] [varchar](1) NULL,
	[Status] [varchar](50) NULL,
	[IsVacant] [bit] NOT NULL,
	[IsPlaceholder] [bit] NOT NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[CountLookupTable] ADD  CONSTRAINT [DF_CountLookupTable_IsVacant]  DEFAULT ((0)) FOR [IsVacant]
ALTER TABLE [dbo].[CountLookupTable] ADD  CONSTRAINT [DF_CountLookupTable_IsPlaceholder]  DEFAULT ((0)) FOR [IsPlaceholder]

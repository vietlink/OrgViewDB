/****** Object:  Table [dbo].[TimesheetSwipeEntries]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TimesheetSwipeEntries](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[Time] [datetime] NOT NULL,
	[Mode] [int] NOT NULL,
 CONSTRAINT [PK_TimesheetSwipeEntries] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TimesheetSwipeEntries] ADD  CONSTRAINT [DF_TimesheetSwipeEntries_Mode]  DEFAULT ((1)) FOR [Mode]

/****** Object:  Table [dbo].[TimesheetShiftOvertimeRates]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TimesheetShiftOvertimeRates](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TimeShiftLoadingHeaderID] [int] NOT NULL,
	[HoursFrom] [decimal](10, 5) NOT NULL,
	[HoursTo] [decimal](10, 5) NOT NULL,
	[MondayID] [int] NULL,
	[TuesdayID] [int] NULL,
	[WednesdayID] [int] NULL,
	[ThursdayID] [int] NULL,
	[FridayID] [int] NULL,
	[SaturdayID] [int] NULL,
	[SundayID] [int] NULL,
	[PublicHolidayID] [int] NULL,
 CONSTRAINT [PK_TimesheetShiftOvertimeRates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TimesheetShiftOvertimeRates] ADD  CONSTRAINT [DF_Table_1_TimeFrom]  DEFAULT ('') FOR [HoursFrom]
ALTER TABLE [dbo].[TimesheetShiftOvertimeRates] ADD  CONSTRAINT [DF_Table_1_TimeTo]  DEFAULT ('') FOR [HoursTo]

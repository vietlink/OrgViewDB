/****** Object:  Table [dbo].[TimesheetSummary]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TimesheetSummary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TimesheetHeaderID] [int] NOT NULL,
	[NormalHours] [decimal](18, 10) NOT NULL,
	[WorkedHours] [decimal](18, 10) NOT NULL,
	[PaidLeaveHours] [decimal](18, 10) NOT NULL,
	[Total] [decimal](18, 10) NOT NULL,
	[Overtime] [decimal](18, 10) NOT NULL,
	[UnpaidLeaveHours] [decimal](18, 10) NOT NULL,
	[OvertimeStartsAfter] [decimal](18, 10) NOT NULL,
	[PlannedWorkHours] [decimal](18, 10) NULL,
	[ExtraHoursWorked] [decimal](18, 10) NOT NULL,
	[Week] [int] NULL,
	[OvertimeRateID] [int] NULL,
 CONSTRAINT [PK_TimesheetSummary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TimesheetSummary] ADD  CONSTRAINT [DF_TimesheetSummary_OvertimeStartsAfter]  DEFAULT ((0)) FOR [OvertimeStartsAfter]
ALTER TABLE [dbo].[TimesheetSummary] ADD  CONSTRAINT [DF_TimesheetSummary_AccrueHours]  DEFAULT ((0)) FOR [ExtraHoursWorked]

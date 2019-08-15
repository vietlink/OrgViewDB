/****** Object:  Table [dbo].[TimeWorkProfileTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TimeWorkProfileTemplate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [varchar](100) NOT NULL,
	[Description] [varchar](255) NULL,
	[Code] [varchar](20) NULL,
	[PayRollCycle] [int] NOT NULL,
	[EnableTimesheet] [bit] NOT NULL,
	[EnableProjectTimesheet] [bit] NOT NULL,
	[EnableSwipeCard] [bit] NOT NULL,
	[TimesheetTimeMode] [int] NOT NULL,
	[ProjectTimeMode] [int] NOT NULL,
	[DefaultProjectID] [int] NULL,
	[DefaultTaskID] [int] NULL,
	[TimeWorkHoursHeaderID] [int] NOT NULL,
	[TimeShiftLoadingHeaderID] [int] NOT NULL,
	[AllowOvertime] [bit] NOT NULL,
	[NormalOvertimeRate] [int] NULL,
	[OvertimeStartsAfter] [decimal](10, 5) NULL,
	[DefaultOvertimeTo] [int] NOT NULL,
	[ApplyOvertimeOption] [int] NOT NULL,
	[StartBuffer] [decimal](10, 5) NULL,
	[FinishBuffer] [decimal](10, 5) NULL,
	[AllowAutoApproval] [bit] NOT NULL,
	[MaxToilBalance] [decimal](10, 5) NULL,
	[DefaultRecordingMethod] [int] NOT NULL,
	[StandardWorkHours] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[NoApprovalForLeave] [bit] NOT NULL,
	[NoApprovalForTimesheet] [bit] NOT NULL,
	[NoApprovalForExpense] [bit] NOT NULL,
	[PayCostCentreID] [int] NULL,
	[ExpenseCostCentreID] [int] NULL,
	[ModuleTimesheet] [bit] NOT NULL,
	[ModuleLeave] [bit] NOT NULL,
	[ModuleExpense] [bit] NOT NULL,
	[ExtraHoursPayType] [int] NOT NULL,
	[ProcessPayroll] [bit] NOT NULL,
	[DeductBreaks] [bit] NOT NULL,
	[DeductAfter] [decimal](10, 5) NOT NULL,
	[HasPublicHoliday] [bit] NULL,
 CONSTRAINT [PK_TimeWorkProfileTemplate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_EnableTimesheet]  DEFAULT ((1)) FOR [EnableTimesheet]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_EnableProjectTimesheet]  DEFAULT ((0)) FOR [EnableProjectTimesheet]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_TimesheetTimeMode]  DEFAULT ((0)) FOR [TimesheetTimeMode]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_ProjectTimeMode]  DEFAULT ((0)) FOR [ProjectTimeMode]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_Table_1_WorkHourPattern]  DEFAULT ((0)) FOR [TimeWorkHoursHeaderID]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_AllowOvertime]  DEFAULT ((1)) FOR [AllowOvertime]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_DefaultOvertimeTo]  DEFAULT ((0)) FOR [DefaultOvertimeTo]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_ApplyOvertime]  DEFAULT ((0)) FOR [ApplyOvertimeOption]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_AllowAutoApproval]  DEFAULT ((0)) FOR [AllowAutoApproval]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_StandardWorkHours]  DEFAULT ((1)) FOR [StandardWorkHours]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_NoApprovalForLeave]  DEFAULT ((0)) FOR [NoApprovalForLeave]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_NoApprovalForTimesheet]  DEFAULT ((0)) FOR [NoApprovalForTimesheet]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_NoApprovalForExpense]  DEFAULT ((0)) FOR [NoApprovalForExpense]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_ModuleTimesheet]  DEFAULT ((1)) FOR [ModuleTimesheet]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_ModuleLeave]  DEFAULT ((1)) FOR [ModuleLeave]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_ModuleExpense]  DEFAULT ((1)) FOR [ModuleExpense]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_ExtraHoursPayType]  DEFAULT ((0)) FOR [ExtraHoursPayType]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_ProcessPayroll]  DEFAULT ((1)) FOR [ProcessPayroll]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_DeductBreaks]  DEFAULT ((1)) FOR [DeductBreaks]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_DeductAfter]  DEFAULT ((5)) FOR [DeductAfter]
ALTER TABLE [dbo].[TimeWorkProfileTemplate] ADD  CONSTRAINT [DF_TimeWorkProfileTemplate_HasPublicHoliday]  DEFAULT ((0)) FOR [HasPublicHoliday]
ALTER TABLE [dbo].[TimeWorkProfileTemplate]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeWorkProfileTemplate_Tasks] FOREIGN KEY([DefaultTaskID])
REFERENCES [dbo].[Tasks] ([ID])
ALTER TABLE [dbo].[TimeWorkProfileTemplate] CHECK CONSTRAINT [FK_TimeWorkProfileTemplate_Tasks]

/****** Object:  Table [dbo].[TimeShiftLoadingRates]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TimeShiftLoadingRates](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NormalHours] [bit] NOT NULL,
	[TimeShiftLoadingHeaderID] [int] NOT NULL,
	[TimeFrom] [varchar](10) NOT NULL,
	[TimeTo] [varchar](10) NOT NULL,
	[MondayID] [int] NULL,
	[TuesdayID] [int] NULL,
	[WednesdayID] [int] NULL,
	[ThursdayID] [int] NULL,
	[FridayID] [int] NULL,
	[SaturdayID] [int] NULL,
	[SundayID] [int] NULL,
	[PublicHolidayID] [int] NULL,
 CONSTRAINT [PK_TimeShiftLoadingRates_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TimeShiftLoadingRates] ADD  CONSTRAINT [DF_TimeShiftLoadingRates_NormalHours]  DEFAULT ((0)) FOR [NormalHours]
ALTER TABLE [dbo].[TimeShiftLoadingRates] ADD  CONSTRAINT [DF_TimeShiftLoadingRates_TimeFrom]  DEFAULT ('') FOR [TimeFrom]
ALTER TABLE [dbo].[TimeShiftLoadingRates] ADD  CONSTRAINT [DF_TimeShiftLoadingRates_TimeTo]  DEFAULT ('') FOR [TimeTo]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate] FOREIGN KEY([MondayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate1] FOREIGN KEY([PublicHolidayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate1]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate2] FOREIGN KEY([SaturdayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate2]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate3] FOREIGN KEY([SundayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate3]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate4] FOREIGN KEY([ThursdayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate4]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate5] FOREIGN KEY([TuesdayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate5]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate6] FOREIGN KEY([WednesdayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate6]
ALTER TABLE [dbo].[TimeShiftLoadingRates]  WITH NOCHECK ADD  CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate7] FOREIGN KEY([FridayID])
REFERENCES [dbo].[LoadingRate] ([ID])
ALTER TABLE [dbo].[TimeShiftLoadingRates] CHECK CONSTRAINT [FK_TimeShiftLoadingRates_LoadingRate7]

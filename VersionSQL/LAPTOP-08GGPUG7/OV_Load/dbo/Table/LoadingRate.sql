/****** Object:  Table [dbo].[LoadingRate]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LoadingRate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](300) NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[Value] [decimal](5, 3) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsNormalRate] [bit] NOT NULL,
 CONSTRAINT [PK_LoadingRate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LoadingRate] ADD  CONSTRAINT [DF_LoadingRate_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[LoadingRate] ADD  CONSTRAINT [DF_LoadingRate_IsNormalRate]  DEFAULT ((0)) FOR [IsNormalRate]

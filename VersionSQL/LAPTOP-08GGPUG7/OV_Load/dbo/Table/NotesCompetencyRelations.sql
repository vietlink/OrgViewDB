/****** Object:  Table [dbo].[NotesCompetencyRelations]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NotesCompetencyRelations](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NoteID] [int] NOT NULL,
	[CompetencyID] [int] NOT NULL,
 CONSTRAINT [PK_NotesCompetencyRelations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[NotesCompetencyRelations]  WITH CHECK ADD  CONSTRAINT [FK_NotesCompetencyRelations_Notes] FOREIGN KEY([NoteID])
REFERENCES [dbo].[Notes] ([ID])
ALTER TABLE [dbo].[NotesCompetencyRelations] CHECK CONSTRAINT [FK_NotesCompetencyRelations_Notes]

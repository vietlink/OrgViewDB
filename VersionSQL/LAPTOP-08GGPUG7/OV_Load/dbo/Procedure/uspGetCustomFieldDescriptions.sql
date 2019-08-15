/****** Object:  Procedure [dbo].[uspGetCustomFieldDescriptions]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetCustomFieldDescriptions]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select
		p.code,
		a.shortname
	from
		applicationpreference ap
	inner join
		preference p
	on
		p.id = ap.preferenceid
	inner join
		entity e
	on
		e.tablename = LEFT(ap.value,CHARINDEX('.',ap.value)-1)
	inner join
		attribute a
	on
		a.columnname = RIGHT(ap.value,LEN(ap.value)-CHARINDEX('.',ap.value)) AND a.entityid = e.id
	where
		p.code in ('customfield1value', 'customfield2value', 'customfield3value', 'customfield4value');
END


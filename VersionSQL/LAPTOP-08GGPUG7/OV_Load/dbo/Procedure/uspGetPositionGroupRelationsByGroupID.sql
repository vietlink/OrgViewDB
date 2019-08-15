/****** Object:  Procedure [dbo].[uspGetPositionGroupRelationsByGroupID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetPositionGroupRelationsByGroupID](@positionEntryGroupID int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		eegr.*, a.columnname, a.shortname, a.datatype, e.tablename, e.code as EntityCode,
		COLUMNPROPERTY(OBJECT_ID(e.tablename, 'U'), a.columnname, 'AllowsNull') as AllowsNull
	FROM
		PositionEntryGroupRelations eegr
	INNER JOIN
		Attribute a
	ON
		a.id = eegr.AttributeID
	INNER JOIN
		Entity e
	ON
		e.id = a.entityid
	WHERE
		eegr.PositionEntryGroupID = @positionEntryGroupID
	ORDER BY e.Ordering, a.sortorder
END


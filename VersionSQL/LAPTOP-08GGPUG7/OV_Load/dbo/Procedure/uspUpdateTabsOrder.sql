/****** Object:  Procedure [dbo].[uspUpdateTabsOrder]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE uspUpdateTabsOrder(
@TabsId int,
@sortOrder int)

AS
BEGIN

UPDATE Tab  SET
				 TabOrder =@sortOrder			
WHERE id =@TabsId 

END

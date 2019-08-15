/****** Object:  Procedure [dbo].[uspGetAdminMenuItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspGetAdminMenuItems 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	am.PageURL, 
	am.ModuleName, 
	am.AttributeID,
	ami.Description as GroupHeader,
	ami.id as GroupID
	FROM AttributeModules am
	INNER JOIN AdminMenuAttributeModuleRelations amr ON amr.AttributeModuleID= am.ID
	INNER JOIN AdminMenuItems ami ON amr.AdminMenuItemID= ami.ID
	WHERE ami.IsEnabled= 1 and amr.IsEnabled=1
	order by ami.SortOrder, amr.SortOrder
END

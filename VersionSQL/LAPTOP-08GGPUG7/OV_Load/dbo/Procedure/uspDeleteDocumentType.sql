/****** Object:  Procedure [dbo].[uspDeleteDocumentType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspDeleteDocumentType] 
	-- Add the parameters for the stored procedure here
	@id int, @status bit, @hardDelete bit 
	  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (@hardDelete=0) begin
		if (@status=0) begin
			update DocumentTypes
			set IsDeleted=1
			where ID= @id
		end
		else begin
			update DocumentTypes
			set IsDeleted=0
			where id= @id
		end
	end
	else begin
		declare @docTypeEntityID int= (select id from Entity where tablename='DocumentTypes')
		declare @code varchar(50)= (select Code from DocumentTypes where ID= @id)
		declare @viewCode varchar(50)= '#'+@code+'View';				
		declare @attrID int = (select id from Attribute where code= @viewCode and entityid= @docTypeEntityID)
		delete from RoleAttribute where attributeid= @attrID;
		delete from Attribute where id= @attrID

		declare @addCode varchar(50)= '#'+@code+'Add';
		declare @attrAddID int = (select id from Attribute where code= @addCode and entityid= @docTypeEntityID)
		delete from RoleAttribute where attributeid= @attrAddID;
		delete from Attribute where id= @attrAddID

		declare @deleteCode varchar(50)= '#'+@code+'Delete';
		declare @attrDeleteID int = (select id from Attribute where code= @deleteCode and entityid= @docTypeEntityID)
		delete from RoleAttribute where attributeid= @attrDeleteID;
		delete from Attribute where id= @attrDeleteID
		
		delete from DocumentTypes where id= @id
	end
END

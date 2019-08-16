/****** Object:  Procedure [dbo].[uspAddOrUpdateDocumentType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspAddOrUpdateDocumentType] 
	-- Add the parameters for the stored procedure here
	@id int , 
	@docTypeCode varchar(50),
	@docTypeTitle varchar(50),
	@docTypeDesc varchar(2000),	
	@oldDocTypeCode varchar(50),
	@ReturnValue int output 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @documentTypeEntityID int= (SELECT id FROM Entity WHERE tablename='DocumentTypes')	
    -- Insert statements for procedure here	
	--print @id;
	IF (@id=0) BEGIN
		INSERT INTO DocumentTypes (Code, Description, Comments) 
		VALUES (@docTypeCode, @docTypeTitle, @docTypeDesc)
		SET @ReturnValue= @@IDENTITY
		DECLARE @sortOrder int = 1;
		SELECT @sortOrder = MAX(SortOrder) FROM Attribute WHERE entityid = @documentTypeEntityID;
		IF @sortOrder IS NULL BEGIN
			SET @sortOrder = 1;
		END
		ELSE
			SET @sortOrder = @sortOrder + 1
		DECLARE @description varchar(50) = 'Document Group - ' + @docTypeTitle
		DECLARE @attributeID int = (SELECT isnull(id,0) as id FROM Attribute WHERE entityid= @documentTypeEntityID and code='#'+ @docTypeCode)
		IF(isnull(@attributeID,0)=0) BEGIN
			INSERT INTO Attribute(entityid, code, name, columnname, shortname, longname, datatype, [format], contenttype, sortorder, justification, usereditable, ispersonal, ismanagerial, dataentry, IsPolicyBased, tab)
			VALUES(@documentTypeEntityID, '#' + @docTypeCode+'View', @description+' - View', @description+' - View', @description+' - View', @description+' - View', 'AnsiString', '', 'Value',
			@sortOrder, 'Left', 'Y', 'N', 'N', 'N', 0, 0)
			DECLARE @attId int;
			SET @attId = @@IDENTITY;
			INSERT INTO Attribute(entityid, code, name, columnname, shortname, longname, datatype, [format], contenttype, sortorder, justification, usereditable, ispersonal, ismanagerial, dataentry, IsPolicyBased, tab)
			VALUES(@documentTypeEntityID, '#' + @docTypeCode+'Add', @description+' - Add', @description+' - Add', @description+' - Add', @description+' - Add', 'AnsiString', '', 'Value',
			@sortOrder, 'Left', 'Y', 'N', 'N', 'N', 0, 0)
			DECLARE @addId int;
			SET @addId = @@IDENTITY;
			INSERT INTO Attribute(entityid, code, name, columnname, shortname, longname, datatype, [format], contenttype, sortorder, justification, usereditable, ispersonal, ismanagerial, dataentry, IsPolicyBased, tab)
			VALUES(@documentTypeEntityID, '#' + @docTypeCode+'Delete', @description+' - Delete', @description+' - Delete', @description+' - Delete', @description+' - Delete', 'AnsiString', '', 'Value',
			@sortOrder, 'Left', 'Y', 'N', 'N', 'N', 0, 0)
			DECLARE @deleteId int;
			SET @deleteId = @@IDENTITY;
			DECLARE @sysAdminId int = 0;
			SELECT TOP 1 @sysAdminId = id FROM [Role] WHERE type = 'BuiltIn'
			IF @sysAdminId <> 0 BEGIN
				INSERT INTO RoleAttribute(roleid, attributeid, granted)
				VALUES(@sysAdminId, @attId, 'Y');
				INSERT INTO RoleAttribute(roleid, attributeid, granted)
				VALUES(@sysAdminId, @addId, 'Y');
				INSERT INTO RoleAttribute(roleid, attributeid, granted)
				VALUES(@sysAdminId, @deleteId, 'Y');
			END
		END		
	END
	ELSE
	BEGIN
		
		update DocumentTypes
		set code= @docTypeCode,
		Comments= @docTypeDesc,
		Description= @docTypeTitle
		where ID=@id
		SET @ReturnValue= @id

		update Attribute
		set code= '#'+@docTypeCode+'View',
		name= 'Document Group - '+@docTypeTitle+' - View',
		longname='Document Group - '+@docTypeTitle+' - View',
		shortname= 'Document Group - '+@docTypeTitle+' - View',
		columnname= 'Document Group - '+@docTypeTitle+' - View'
		where code= '#'+@oldDocTypeCode+'View'

		update Attribute
		set code= '#'+@docTypeCode+'Add',
		name= 'Document Group - '+@docTypeTitle+' - Add',
		longname='Document Group - '+@docTypeTitle+' - Add',
		shortname= 'Document Group - '+@docTypeTitle+' - Add',
		columnname= 'Document Group - '+@docTypeTitle+' - Add'
		where code= '#'+@oldDocTypeCode+'Add'

		update Attribute
		set code= '#'+@docTypeCode+'Delete',
		name= 'Document Group - '+@docTypeTitle+' - Delete',
		longname='Document Group - '+@docTypeTitle+' - Delete',
		shortname= 'Document Group - '+@docTypeTitle+' - Delete',
		columnname= 'Document Group - '+@docTypeTitle+' - Delete'
		where code= '#'+@oldDocTypeCode+'Delete'
	END
-- update related table needed
	
END

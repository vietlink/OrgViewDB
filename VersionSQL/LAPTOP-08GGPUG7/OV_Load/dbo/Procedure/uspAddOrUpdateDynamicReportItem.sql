/****** Object:  Procedure [dbo].[uspAddOrUpdateDynamicReportItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Linh Ngo
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspAddOrUpdateDynamicReportItem] 
	-- Add the parameters for the stored procedure here
	@itemID int, @attributeID int, @headerID int, @isShow bit, @isSortBy bit, @isSum bit, @justifyVal varchar(6),
	@formatVal varchar(15), @decimalVal int, @widthVal int, @isPrompt bit, @restrictionVal int, @fromVal varchar(max),
	@toVal varchar(max), @listVal varchar(max), @sortOrder int, @sortOrderVal varchar(4), @columnOrder int, @ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (@itemID=0) 
	BEGIN
		INSERT INTO DynamicReportItems (AttributeID, DynamicReportHeaderID, isShowOnReport, isSortBy, isSum, JustifyVal, 
		FormatVal, DecimalVal, WidthVal, isPrompt, RestrictionVal, FromVal, ToVal, ListVal, SortOrder, SortOrderVal, ColumnOrder)
		VALUES (@attributeID, @headerID, @isShow, @isSortBy, @isSum, @justifyVal, @formatVal, @decimalVal, @widthVal, @isPrompt, 
		@restrictionVal, @fromVal, @toVal, @listVal, @sortOrder, @sortOrderVal, @columnOrder)
		SET @ReturnValue = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE DynamicReportItems
		SET AttributeID= @attributeID,
		DynamicReportHeaderID= @headerID, isShowOnReport= @isShow, isSortBy= @isSortBy,
		isSum= @isSum, JustifyVal= @justifyVal, FormatVal= @formatVal, DecimalVal= @decimalVal, 
		WidthVal= @widthVal, isPrompt= @isPrompt, RestrictionVal= @restrictionVal,
		FromVal= @fromVal, ToVal= @toVal, ListVal= @listVal, SortOrder= @sortOrder, SortOrderVal= @sortOrderVal,
		ColumnOrder = @columnOrder
		WHERE id= @itemID
		SET @ReturnValue= @itemID
	END
	
END

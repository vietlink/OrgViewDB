/****** Object:  Procedure [dbo].[uspGetTerminationReasonByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTerminationReasonByID] 
	-- Add the parameters for the stored procedure here
	@id int, @filter varchar(300), @status bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (@id=0) begin
		select * from TerminationReasons
		where (Value like '%'+@filter+'%' or Grouping like '%'+@filter+'%')
		and IsDeleted= @status
	end
	else begin
		SELECT * from TerminationReasons where ID=@id and IsDeleted= @status
	end
END

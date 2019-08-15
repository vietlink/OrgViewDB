/****** Object:  Procedure [dbo].[uspCheckDeleteCompetencyRanking]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
create PROCEDURE [dbo].[uspCheckDeleteCompetencyRanking] 
	-- Add the parameters for the stored procedure here
	@id int , 
	@ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @count int;
    -- Insert statements for procedure here
	set @count= (select count(n.id)
	from EmployeeCompetencyList n
	where n.EmployeeCompetencyRankingId=@id)
	if (@count>0) begin
		set @ReturnValue=0;
	end
	else begin
		set @ReturnValue =1;
	end
END


/****** Object:  Procedure [dbo].[uspCheckPositionIsSubordinateorSuperior]    Committed by VersionSQL https://www.versionsql.com ******/

-- old typo, should be LOGGED not loged
CREATE PROCEDURE [dbo].[uspCheckPositionIsSubordinateorSuperior](@LogedInUserPositionId int,@PositionId int,@Returnvalue int output)
AS
BEGIN

IF @LogedInUserPositionId = @PositionId BEGIN
  SET @Returnvalue = 0
  RETURN @Returnvalue
END;

--WITH RPL (PositionID, ParentId) AS
--  (  select P.PositionID,P.parentid  from PositionParentLookup P inner join EmployeePosition  EP on P.PositionID=EP.positionid  Where ep.IsDeleted = 0 AND P.PositionID =@LogedInUserPositionId

--     UNION ALL
--       select P.PositionID,P.parentid  from PositionParentLookup P, EmployeePosition EP, RPL PARENT  WHERE P.PositionID=EP.positionid and ep.IsDeleted = 0 and PARENT.PositionID=P.parentid 
--  )
--  select @Returnvalue = COUNT(PositionID) from RPL where PositionID=@PositionId

SELECT @Returnvalue = COUNT(PositionID) FROM PositionParentLookup WHERE PositionID = @PositionId AND ParentID = @LogedInUserPositionId
  if(@Returnvalue is null)
  SET @Returnvalue =0
  RETURN @Returnvalue
END

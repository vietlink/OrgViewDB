/****** Object:  Procedure [dbo].[uspGetAttributesBasedonPermission]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspGetAttributesBasedonPermission](@IsPersonal int,@IsManagerial int,@RoleIds varchar(100),@TabId int)          
AS          
BEGIN          
 DECLARE @SEP varchar(1)          
 SET @SEP =','          
 DECLARE @SP INT          
 DECLARE @VALUE varchar(100)          
 DECLARE @SQL nvarchar(3000)          
 DECLARE @PARAMS nvarchar(1000)          
 DECLARE @RoleIdsCount int          
 SET @PARAMS ='@TabId int'          
 CREATE TABLE #Temp2(Id int IDENTITY(1,1) not null,RoleId varchar(100) not null)          
 if(CHARINDEX (',',@RoleIds)> 0)          
 BEGIN          
          
  WHILE PATINDEX('%'+@SEP+'%',@RoleIds) <> 0          
  BEGIN          
     SELECT  @SP = PATINDEX('%' + @SEP + '%',@RoleIds)          
     SELECT  @VALUE = LEFT(@RoleIds , @SP - 1)          
     SELECT  @RoleIds = STUFF(@RoleIds, 1, @SP, '')          
     INSERT INTO #Temp2 (RoleId) VALUES (@VALUE)          
  END          
 END          
 if(@RoleIds <>'')          
 INSERT INTO #Temp2 (RoleId) VALUES (@RoleIds)          
           
 SET @SQL =''          
 if(@IsPersonal =1)          
 SET @SQL =' select A.id,a.entityid,a.name,a.columnname,E.tablename,e.code,e.code+''.''+a.columnname as codename,a.shortname,a.longname,A.TabBasedSort from Attribute A inner join Entity E on a.entityid =E.id WHERE A.IsPersonal=''Y'' and A.Tab='+CONVERT(varchar,@TabId)  
+''         
 if(@IsManagerial =1)          
 BEGIN          
  if(@SQL ='')          
  SET @SQL =' select A.id,a.entityid,a.name,a.columnname,E.tablename,e.code,e.code+''.''+a.columnname as codename,a.shortname,a.longname,A.TabBasedSort  from Attribute A inner join Entity E on a.entityid =E.id WHERE A.IsManagerial=''Y'' and A.Tab='+CONVERT(varchar,@TabId)         
  else          
  SET @SQL =@SQL +' UNION select A.id,a.entityid,a.name,a.columnname,E.tablename,e.code,e.code+''.''+a.columnname  as codename,a.shortname,a.longname,A.TabBasedSort from Attribute A inner join Entity E on a.entityid =E.id WHERE A.IsManagerial=''Y'' and A.Tab='+CONVERT     
(varchar,@TabId)         
 END          
          
 SET @RoleIdsCount =(select COUNT(roleid) from #Temp2 )          
 if(@RoleIdsCount > 0)          
 BEGIN          
  if(@SQL ='')          
  SET @SQL =' select distinct A.id,a.entityid,a.name,a.columnname,E.tablename,e.code,e.code+''.''+a.columnname as codename,a.shortname,a.longname,A.TabBasedSort from Attribute A inner join Entity E on a.entityid =E.id INNER JOIN RoleAttribute RA on RA.AttributeId=A.Id and RA.RoleId in (select roleid from #Temp2) where ra.granted = ''Y'' AND A.Tab='+CONVERT(varchar,@TabId)  
  else          
  SET @SQL =@SQL +' UNION select distinct A.id,a.entityid,a.name,a.columnname,E.tablename,e.code,e.code+''.''+a.columnname as codename,a.shortname,a.longname,A.TabBasedSort from Attribute A inner join Entity E on a.entityid =E.id INNER JOIN RoleAttribute 
  
RA on RA.AttributeId=A.Id and RA.RoleId in (select roleid from #Temp2) where ra.granted = ''Y'' AND A.Tab='+CONVERT(varchar,@TabId)          
 END          
if(@SQL <>'')         
SET @SQL=@SQL+' ORDER BY A.TabBasedSort '        
          
PRINT @SQL          
if(@SQL <>'')            
EXECUTE sp_executesql @SQL ,@PARAMS,@TabId          
          
          
          
END

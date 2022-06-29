/****** Script for SelectTopNRows command from SSMS  ******/
WITH CTE AS (
 
        SELECT ID, SysID, RANK() OVER (PARTITION BY SYSID ORDER BY ID) AS RN
        FROM [Project_name_REPORTING].dbo.History_Detail
 
)
 
--SELECT *
--  FROM [dbo].[Segreterie] AS S INNER JOIN CTE ON S.His_ID=CTE.ID
--  LEFT OUTER JOIN CTE AS AX ON S.SysID=AX.SysID AND CTE.RN-1=AX.RN
--  INNER JOIN Project_name_REPORTING.dbo.History_Detail AS H ON AX.ID=H.ID
--  WHERE S.Project='PROJECT_NAME' --AND YEAR(H.CallDate)=2021 AND MONTH(H.CallDate) IN (5,6,7)
--  ORDER BY 1,2
 
  UPDATE [dbo].[Segreterie]
  SET [esito precedente di del sysid (precedente his ID)]=H.[CallOutcome]
  ,[data del precedente His ID]=H.CallDate
  ,[Orario del precedente His ID]=H.CallStartTime
  ,[His_RecycleSetting del precedente His id]=H.RecycleSetting
  ,[Talk time del precedente His Id]=H.TalkTime
  ,[OB precedente His Id]=H.User
  FROM [dbo].[Segreterie] AS S INNER JOIN CTE ON S.ID=CTE.ID
  LEFT OUTER JOIN CTE AS AX ON S.SysID=AX.SysID AND CTE.RN-1=AX.RN
  INNER JOIN Project_name_REPORTING.dbo.History_Detail AS H ON AX.ID=H.ID
  WHERE S.Project='Project_name'

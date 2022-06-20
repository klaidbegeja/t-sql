/****** Script for SelectTopNRows command from SSMS  ******/
WITH CTE AS (
 
        SELECT His_ID, His_SysID, RANK() OVER (PARTITION BY HIS_SYSID ORDER BY His_ID) AS RN
        FROM [Project_name_REPORTING].dbo.rHistory_Detail
 
)
 
--SELECT S.[His_ID]
--      ,S.[His_SysID]
--      ,S.[His_CallDate]
--      ,S.[His_CallStartTime]
--      ,S.[His_CallEndTime]
--      ,S.[His_CallDuration]
--      ,S.[His_Hour]
--      ,S.[His_Project]
--      ,S.[His_User]
--      ,S.[His_SubCampaign1]
--      ,S.[His_CallOutcomeCode]
--      ,S.[His_CallOutcome]
--      ,S.[His_BreakTime]
--      ,S.[His_WaitTime]
--      ,S.[His_PreviewTime]
--      ,S.[His_DialTime]
--      ,S.[His_TalkTime]
--      ,S.[His_WrapTime]
--      ,AXA.RN AS RankingTabelaHistory
--      ,AX.RN AS RankingTabelaHistoryPrecedenteID
--      ,AX.His_ID AS PrecedenteID
--    ,H.[His_CallOutcome] AS [esito precedente di del sysid (precedente his ID)]
--    ,H.His_CallDate AS [data del precedente His ID]
--    ,H.His_CallStartTime AS [Orario del precedente His ID]
--    ,H.His_RecycleSetting AS [His_RecycleSetting del precedente His id]
--    ,H.His_TalkTime AS [Talk time del precedente His Id]
--    ,H.His_User AS [OB precedente His Id]
--  FROM [CTI_SYSTEM].[dbo].[Segreterie] AS S inner join CTE ON S.His_ID=CTE.His_ID
--  LEFT OUTER JOIN CTE AS AX ON S.His_SysID=AX.His_SysID AND CTE.RN-1=AX.RN
--  INNER JOIN Project_name_REPORTING.dbo.rHistory_Detail AS H ON AX.His_ID=H.His_ID
--  WHERE S.His_Project='AMEX_AXA_180546' --AND YEAR(H.His_CallDate)=2021 AND MONTH(H.His_CallDate) IN (5,6,7)
--  ORDER BY 1,2
 
  UPDATE [CTI_SYSTEM].[dbo].[Segreterie]
  SET [esito precedente di del sysid (precedente his ID)]=H.[His_CallOutcome]
  ,[data del precedente His ID]=H.His_CallDate
  ,[Orario del precedente His ID]=H.His_CallStartTime
  ,[His_RecycleSetting del precedente His id]=H.His_RecycleSetting
  ,[Talk time del precedente His Id]=H.His_TalkTime
  ,[OB precedente His Id]=H.His_User
  FROM [CTI_SYSTEM].[dbo].[Segreterie] AS S inner join CTE ON S.His_ID=CTE.His_ID
  LEFT OUTER JOIN CTE AS AX ON S.His_SysID=AX.His_SysID AND CTE.RN-1=AX.RN
  INNER JOIN Project_name_REPORTING.dbo.rHistory_Detail AS H ON AX.His_ID=H.His_ID
  WHERE S.His_Project='Project_name'
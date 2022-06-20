DECLARE @DB NVARCHAR(500)

DECLARE CursorRecord CURSOR FOR -- CURSOR


SELECT LEFT(NAME,LEN(NAME)-8) AS DB FROM master.sys.databases WHERE NAME LIKE '%_PROJECT' order by 1

IF OBJECT_ID(N'tempdb..#ReportTalkTime') IS NOT NULL DROP TABLE dbo.#ReportTalkTime

CREATE TABLE #ReportTalkTime (
Campaing NVARCHAR(500),
Mese NVARCHAR(100),
TalkMins NVARCHAR(MAX),
TIPO NVARCHAR(200),
NumeroChiamate NVARCHAR(50)

)

	OPEN CursorRecord
	
	FETCH NEXT FROM CursorRecord
		INTO @DB
		
	WHILE 	@@FETCH_STATUS = 0
	BEGIN 

	PRINT 'Get data from database: ' + @DB;

	DECLARE @COMMAND NVARCHAR(MAX)

	SET @COMMAND = 
		'WITH Project AS ( ' +

		'SELECT  ' +
		'Con_SysID, ' +
		' CASE WHEN Con_Phone1 like(''0%'') THEN ''FISSO'' '+
		'	WHEN Con_Phone1 like(''3%'') THEN ''MOBILE'' ' +
		' ELSE ''EXTRA'' '+
		' END AS TELEFONO ' +
		'FROM ' + @DB + '_PROJECT.dbo.pContacts WITH (NOLOCK)  ' +
		'WHERE Con_Team NOT LIKE ''%test%'' '+

		')' +


		' INSERT INTO #ReportTalkTime (Campaing,Mese,TalkMins,TIPO,NumeroChiamate) ' +

		'SELECT ' + 
		'''' + @DB + '''' + ' AS Campaing ' +
		', MONTH(His_CallDate) AS Mese ' +
		', SUM(His_TalkTime) /60 as TalkMins ' +
		', TELEFONO as TIPO ' +
		', COUNT(His_SysID) AS NumeroChiamate ' +
		'FROM Project LEFT OUTER JOIN ' + @DB +'_REPORTING.dbo.rHistory_Detail WITH (NOLOCK)  ' +
		'ON Con_SysID=His_SysID '+
		'WHERE  His_TalkTime > 0 '+
		'AND YEAR(His_CallDate)=DATEPART(YEAR,DATEADD(m,-1,GETDATE())) '+
		'AND MONTH(His_CallDate)=DATEPART(m,DATEADD(m,-1,GETDATE())) '+
		'AND His_Mode=''Outbound'' '+
		'GROUP BY MONTH(His_CallDate) ,TELEFONO ' ;

		EXEC (@COMMAND);

		FETCH NEXT FROM CursorRecord		
		INTO @DB
	
	
	END	-- CURSOR
	CLOSE CursorRecord
	DEALLOCATE CursorRecord

	SELECT * FROM #ReportTalkTime
	PRINT 'FINE PROCEDURA';
DECLARE @DB NVARCHAR(100)
DECLARE @DB2 NVARCHAR(100)
DECLARE @QUERY NVARCHAR(4000)
DECLARE @QUERY2 NVARCHAR(500)
DECLARE @QUERY3 NVARCHAR(500)
DECLARE @ENC NVARCHAR(200)
DECLARE @FileExists INT
DECLARE @DeleteDate NVARCHAR(50) 
DECLARE @FILE NVARCHAR(100)
DECLARE @FullPath NVARCHAR(500)

BEGIN

	IF OBJECT_ID(N'tempdb..#AttachToDel') IS NOT NULL DROP TABLE #AttachToDel  
		
		CREATE TABLE #AttachToDel(
		DB NVARCHAR(255) NOT NULL,
		NomeFile NVARCHAR(255) NOT NULL
		)

	DECLARE DBNAME CURSOR FOR

	SELECT NAME FROM SYS.DATABASES WHERE NAME LIKE 'Client_%'

	OPEN DBNAME   
	FETCH NEXT FROM DBNAME INTO @DB

	WHILE @@FETCH_STATUS = 0   
	BEGIN 

	IF @DB != 'Client_Name'
	BEGIN
		SET @QUERY= 
			'USE [' + @DB + ']' +
			'INSERT INTO #AttachToDel (DB , NomeFile) '+
			'SELECT ''' + @DB +''' , CAST(atta.Id_ATTA AS VARCHAR) + RIGHT(atta.Filename_ATTA, CHARINDEX(''.'', REVERSE(atta.Filename_ATTA)) ) As NomeFile ' +
			'FROM ' +  @DB + '.[dbo].[CASEs] AS C ' +
			'INNER JOIN '+  @DB + '.[dbo].ATTAchment ATTA on C.Id_CASE=ATTA.Id_CASE ' +
			'WHERE C.Id_Case >0 ' +
			'AND CloseDate_CASE<DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), -31) ' +
			'AND C.Id_CAST=''SO'' ';

			EXECUTE (@QUERY);
	END
	ELSE
		BEGIN
		SET @QUERY= 
			'USE [' + @DB + ']' +
			'INSERT INTO #AttachToDel (DB , NomeFile) '+
			'SELECT ''' + @DB +''' , CAST(atta.Id_ATTA AS VARCHAR) + RIGHT(atta.Filename_ATTA, CHARINDEX(''.'', REVERSE(atta.Filename_ATTA)) ) As NomeFile ' +
			'FROM ' +  @DB + '.[dbo].[CASEs] AS C ' +
			'INNER JOIN '+  @DB + '.[dbo].ATTAchment ATTA on C.Id_CASE=ATTA.Id_CASE ' +
			'WHERE C.Id_Case >0 ' +
			'AND CloseDate_CASE<DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), -25) ' +
			'AND C.Id_CAST=''SO'' ';

			EXECUTE (@QUERY);
		END

			FETCH NEXT FROM DBNAME INTO @DB
	END   

	CLOSE DBNAME
	DEALLOCATE DBNAME


		DECLARE file_cursor CURSOR FOR 

		SELECT DB, NomeFile from #AttachToDel

		OPEN file_cursor
		FETCH NEXT FROM file_cursor INTO @DB2, @FILE

		WHILE @@FETCH_STATUS=0
		BEGIN

			IF @DB2 != 'Client_Name'
			BEGIN
				SET @ENC = '\\NETWORK_PATH\FOLDER1\' + @DB2 + '\Attachments\'
			END
		ELSE
			BEGIN
				SET @ENC = '\\NETWORK_PATH\FOLDER2\' + @DB2 + '\Attachments\'
			END

			SET @FullPath = @ENC + @FILE
			   PRINT @FullPath
			   EXEC MASTER.sys.xp_FileExist @FullPath, @FileExists OUT
			   IF @FileExists = 1
					BEGIN
						PRINT 'START PROCESSING ' + @DB2 + ' FILE ' + @FILE	
						SET @QUERY2 = 'DEL '+ @FullPath 
						PRINT @QUERY2
						EXEC MASTER.sys.xp_cmdshell @QUERY2
						PRINT @FILE
						SET @QUERY3= 'INSERT INTO MASTER.DBO.[delete_file_log]([DB],[FileName],[del_date]) VALUES (''' + @DB2 + ''',''' + @FILE + ''','''+ CONVERT(VARCHAR,GETDATE(),102) +''')';
						EXEC sp_executesql @QUERY3 
						PRINT 'Deletetd File FROM ' + @FullPath
					END
			   FETCH NEXT FROM file_cursor INTO @DB2, @FILE   
			END   

			CLOSE file_cursor
			DEALLOCATE file_cursor
	
END
GO
DECLARE	@IDENT INT
	  ,@Telefono VARCHAR(MAX)
      ,@DataChiamata VARCHAR(MAX)
      ,@IdChiamata VARCHAR(MAX)
	  ,@idUnivoco VARCHAR(MAX)
      ,@FlagInviato VARCHAR(MAX)
	  ,@ImportID VARCHAR(MAX)
	  ,@ExpiredDate VARCHAR(8)
	  ,@CallsListID VARCHAR(50)
	  ,@CountRecords INT
	  ,@CallsListIdent INT

	BEGIN
	
	SET NOCOUNT ON;
	
	SET @ImportID = 'AUTOMATICO_' + CONVERT(VARCHAR,GETDATE(),112);
	--SET @ExpiredDate = CONVERT(VARCHAR,YEAR(GETDATE())) + CASE WHEN LEN(CONVERT(VARCHAR, MONTH(DATEADD(MONTH,1,GETDATE()))))=1 THEN '0' + CONVERT(VARCHAR, MONTH(DATEADD(MONTH,1,GETDATE()))) ELSE CONVERT(VARCHAR, MONTH(DATEADD(MONTH,1,GETDATE()))) END  + '15';
	SET @ExpiredDate = CONVERT(VARCHAR, DATEADD(DAY, 30, GETDATE()), 112) -- ADD 30 DAYS TO THE ACTUAL DATE
	SET @CallsListID = 0;
	SET @CountRecords = 0;

	DECLARE CursorRecords CURSOR FOR

	SELECT Telefono,Data, idchiamata, idUnivoco, Importato
	FROM [servername,555].[Asterisk].[dbo].[tbl_SMS_Rinnovi_8342]
	WHERE [Importato]='N' AND (TELEFONO IS NOT NULL OR TELEFONO !='') AND LEN(TELEFONO)>9
	ORDER BY idUnivoco
	
	OPEN CursorRecords
 
	FETCH NEXT FROM CursorRecords
	INTO @Telefono, @DataChiamata, @IdChiamata, @idUnivoco, @FlagInviato

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO dbo.pContacts (Con_Phone1,con_dateofbirth,Con_ImportDate, Con_ImportedBy,Con_ExportedBy,Con_ImportID)
		VALUES (@Telefono,@DataChiamata, GETDATE(), 'AUTOMATICO', @ExpiredDate, @ImportID)

		SET @IDENT=@@IDENTITY;
		
		INSERT INTO dbo.pContactsExtra 
		([ConExt_SysID],[ConExt_IDChiamata],[ConExt_idUnivoco])
		VALUES (@IDENT,@IdChiamata,@idUnivoco)

		 
		UPDATE [Asterisk].[dbo].[tbl_SMS_Rinnovi_8342]
		SET [Importato]='Y'
		WHERE [idChiamata]=@idchiamata

	
	FETCH NEXT FROM CursorRecords
	INTO @Telefono, @DataChiamata, @IdChiamata,@idUnivoco, @FlagInviato

	END
	CLOSE CursorRecords
	DEALLOCATE CursorRecords

	SET @CallsListID = (SELECT cl_ID FROM [pCallsLists] WHERE cl_Description=@ImportID );

		IF @CallsListID IS NULL
			BEGIN
				SET @CountRecords = (SELECT COUNT(CON_SYSID) FROM DBO.pContacts WHERE Con_ImportID=@ImportID);

				IF @CountRecords IS NULL
					BEGIN
						PRINT 'Nothing to load!';
					END
				ELSE
					BEGIN
						INSERT INTO [dbo].[pCallsLists]([cl_Description],[cl_DateLoaded],[cl_LoadedBy],[cl_TaskTypeId],[cl_RecordCount],[cl_Priority])
						VALUES (@ImportID, GETDATE(), 0, 1, @CountRecords, 5)

						SET @CallsListIdent=@@IDENTITY;
						/**
						  82- BL AZIENDIALE
						  86- BL Client
						**/
						INSERT INTO pCallBacks (CallBac_Team,CallBac_Date,CallBac_SysId,CallBac_TaskType,CallBac_Type,CallBac_Priority,CallBac_ListId,CallBac_TaskReference)
						SELECT  0,'1900-01-01',CON_SYSID,1,0,5,@CallsListIdent,0
						FROM pContacts
						WHERE Con_SysID NOT IN (select CallBac_SysId from pCallBacks)
						AND Con_RecordStatus<>3
						AND Con_ImportID = @ImportID
						--AND Con_Phone1 NOT IN (select bar_number from INFINITY_SYSTEM.dbo.sBarredNumbers WHERE bar_listid IN (82, 86))
					END
			END
		ELSE
			BEGIN
				SET @CountRecords = (SELECT COUNT(CON_SYSID) FROM DBO.pContacts WHERE Con_ImportID=@ImportID);
				/**
				  82- BL AZIENDIALE
				  86- BL Client
				**/
				INSERT INTO pCallBacks (CallBac_Team,CallBac_Date,CallBac_SysId,CallBac_TaskType,CallBac_Type,CallBac_Priority,CallBac_ListId,CallBac_TaskReference)
				SELECT  0,'1900-01-01',CON_SYSID,1,0,5,@CallsListID,0
				FROM pContacts
				WHERE Con_SysID NOT IN (select CallBac_SysId from pCallBacks)
				AND Con_RecordStatus<>3
				AND Con_ImportID = @ImportID
				--AND Con_Phone1 NOT IN (select bar_number from INFINITY_SYSTEM.dbo.sBarredNumbers WHERE bar_listid IN (82, 86))

			END
END
-- Setup sample data
DECLARE @typeEmployee TABLE (
    [Name] [varchar](10) NOT NULL,  
    [StartDate] [date] NOT NULL,
    [EndDate] [date] NOT NULL
)
DECLARE @tblEmployee TABLE (
    [EmployeeID] [int] IDENTITY(1,1) NOT NULL, 
    [Name] [varchar](10) NOT NULL,  
    [StartDate] [date] NOT NULL,
    [EndDate] [date] NOT NULL   
)
INSERT @tblEmployee VALUES ('Emp A', '1/1/2016', '2/1/2016')
INSERT @typeEmployee VALUES ('Emp A', '1/5/2016', '2/2/2016'), ('Emp B', '3/1/2016', '4/1/2016')


-- Logic to do upsert
DECLARE @Updates TABLE (
    [Name] [varchar](10) NOT NULL,  
    [StartDate] [date] NOT NULL,
    [EndDate] [date] NOT NULL
)

INSERT @Updates
    SELECT
        Name,
        StartDate,
        EndDate
    FROM (
        MERGE INTO @tblEmployee AS TARGET
        USING @typeEmployee AS SOURCE
            ON TARGET.Name = SOURCE.Name 
        WHEN MATCHED AND TARGET.StartDate < SOURCE.StartDate
        THEN
            --First Update Existing Record EndDate to Previous Date as shown below 
            UPDATE SET
                EndDate = DATEADD(DAY, -1, CONVERT(DATE, SOURCE.StartDate))
        WHEN NOT MATCHED BY TARGET -- OR MATCHED AND TARGET.StartDate >= SOURCE.StartDate -- Handle this case?
        THEN
            INSERT VALUES(SOURCE.Name, SOURCE.StartDate, SOURCE.EndDate)
        OUTPUT $action, INSERTED.Name, INSERTED.StartDate, INSERTED.EndDate
        -- Use the MERGE to return all changed records of target table
    ) AllChanges (ActionType, Name, StartDate, EndDate)
    WHERE AllChanges.ActionType = 'UPDATE' -- Only get records that were updated
	
	INSERT @tblEmployee
    SELECT
        SOURCE.Name,
        SOURCE.StartDate,
        SOURCE.EndDate
    FROM @typeEmployee SOURCE
    WHERE EXISTS (
        SELECT *
        FROM @Updates Updates
        WHERE Updates.Name = SOURCE.Name
            -- Other join conditions to ensure 1:1 match against SOURCE (start date?)
    )
	
	-- Show output
SELECT * FROM @tblEmployee
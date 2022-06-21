-- =============================================
-- Author:		Klaid Begeja
-- Description:	Scalar Funciton to return Gregorian date from Julian date
-- Format date yyyyjjj
-- Sample date 2022172
-- =============================================
CREATE FUNCTION ConvertJulianToGregorianDate 
(
	-- Add the parameters for the function here
	@value VARCHAR(200)
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result DATETIME

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = DATEADD(dd, CAST(RIGHT(LEFT(@value,7),3) AS INT) - 1, CAST(CONCAT('01/01/', LEFT(@value,4)) AS DATETIME))

	-- Return the result of the function
	RETURN @Result

END
GO

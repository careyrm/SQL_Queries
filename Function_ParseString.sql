USE [TST_DATA]
GO

/****** Object:  UserDefinedFunction [dbo].[udf_parse_string]    Script Date: 7/23/2020 4:57:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================================
-- Author:		Rhonda Carey
-- Create date: 05/23/2019
-- Description:	Parse out a string from another string
-- ===========================================================================================================================

CREATE FUNCTION [dbo].[udf_parse_string] 
(
	-- Add the parameters for the function here
	@INPUT_STRING nvarchar(max),
	@SEARCH_STRING nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @RESULT_STRING varchar(max)
	SET @RESULT_STRING = NULL
	
	IF(CHARINDEX(@SEARCH_STRING,@INPUT_STRING) > 0)
		BEGIN
			SET @RESULT_STRING = SUBSTRING(@INPUT_STRING,CHARINDEX(@SEARCH_STRING,@INPUT_STRING),LEN(@SEARCH_STRING))
		END
	
	-- Return the result of the function
	RETURN @RESULT_STRING

END
GO



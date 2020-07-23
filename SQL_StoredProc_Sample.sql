USE [PDF_REPORT_GENERATOR]
GO
/****** Object:  StoredProcedure [dbo].[usp_PDF_Generate_CustomerWeekly]    Script Date: 4/29/2020 9:37:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rhonda Carey
-- Create date: 07/30/2019
-- Description:	This procedure will execute the exe to create the PDF of the Customer Weekly Report from CRM/Sharepoint. The SP is called from a Nintex workflow.
--			    @List_ID = the id for a sharepoint list item for the report
--				@RptID = the id for which report to run. The exe is setup so we can generate different reports based on the id passed
--				         1 = Customer Weekly Report
--				@Source_ID = this is the CRM job number that the customer weekly was run for
--				@PDF_REPORT_NAME = this is the name of the report used in naming the PDF - CustomerWeeklyReport in this case
--              @IS_DEBUG = Y/N Indicates if this is a test of the process 
-- =============================================
ALTER PROCEDURE [dbo].[usp_PDF_Generate_CustomerWeekly]
	-- Add the parameters for the stored procedure here
	@List_ID varchar(10),
	@RptID varchar(10),
	@Source_ID varchar(50),
	@PDF_REPORT_NAME varchar(50),
	@IS_DEBUG varchar(1)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Build the final report name
	SET @PDF_REPORT_NAME = @PDF_REPORT_NAME + '_' + @Source_ID + '_' + @List_ID +'_' + CONVERT(varchar(4),Year(GETDATE())) + RIGHT('00' + CAST(DATEPART(mm, GETDATE()) AS varchar(2)), 2) + RIGHT('00' + CAST(DATEPART(dd, GETDATE()) AS varchar(2)), 2) + '.pdf'
	
	--insert a process record in the PDF_GENERATOR_MASTER table
	INSERT INTO [dbo].[PDF_GENERATOR_MASTER]
           ([PROCESS_START_DATE],[REPORT_ID],[LIST_ID],[SOURCE_ID],[PDF_REPORT_NAME],[SENT_TO_CLIENT])
     VALUES
           (GETDATE() ,CONVERT(int,@RptID) ,CONVERT(int,@List_ID) ,@Source_ID  ,@PDF_REPORT_NAME,0)
	
	--Get the id of new master record
	DECLARE @ID int
    SET @ID=SCOPE_IDENTITY()
	
	--Set parameters needed for the exe
	DECLARE @UserName varchar(25)
	DECLARE @UserPWD varchar(25)

	-- Get the parameters for the report
	SELECT @UserName = [PARAMETER_DEFAULT_VALUE]
	FROM [dbo].[PARAMETER_MASTER]
	WHERE [REPORT_ID] = @RptID AND [PARAMETER_STATUS] = 'A' AND [PARAMETER_NAME] = 'UserName'
	ORDER BY [PARAMETER_ORDER]

	SELECT @UserPWD = [PARAMETER_DEFAULT_VALUE]
	FROM [dbo].[PARAMETER_MASTER]
	WHERE [REPORT_ID] = @RptID AND [PARAMETER_STATUS] = 'A' AND [PARAMETER_NAME] = 'UserPWD'
			

	--Build the cmd string
	DECLARE @Cmd varchar(8000)
	SET @Cmd = '"C:\PDFGenerator\PDF_Report_Generator.exe" ' + @UserName + ' ' + @UserPWD + ' ' + @RptID + ' ' + @List_ID + ' ' + @IS_DEBUG
    
	--execute the exe that will create the PDF
	EXECUTE master..xp_cmdshell @Cmd

	--Update the process record with the end datetime
	UPDATE [dbo].[PDF_GENERATOR_MASTER] SET [PROCESS_END_DATE] = GETDATE() WHERE ID = @ID

	return 1
	
END

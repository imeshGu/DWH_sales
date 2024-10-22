USE [STG_Cargills_SALES]
GO
/****** Object:  StoredProcedure [dbo].[SUP_DWH_FACT]    Script Date: 11/27/2023 5:12:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SUP_DWH_FACT]
AS 
BEGIN


	DELETE FROM [dbo].[DWH__FACT_ORDER]
	WHERE LOAD_INT_FK IN (
		SELECT JJ.[DATE_KEY]
		FROM [dbo].[DWH_Dim_Date] JJ
		WHERE JJ.[DATE] = CAST(GETDATE() AS DATE));

------------------///////////////////////////////////////////////////////////////////////////////////////////-------------
	------- INSERTION OF FACT
	INSERT INTO [dbo].[DWH__FACT_ORDER](
		[ORDERNUMBER]
      ,[QUANTITYORDERED]
      ,[PRICEEACH]
      ,[ORDERLINENUMBER]
      ,[SALES]
      ,[STATUS]
      ,[DEALSIZE]
      ,[DATE_KEY_FK]
      ,[CUSTOMER_FK]
      ,[PRODUCT_FK]
      ,[LOAD_INT_FK]
	  )
	SELECT [ORDERNUMBER],
		[QUANTITYORDERED],
		[PRICEEACH],
		[ORDERLINENUMBER],
		[SALES],
		[STATUS],
		[DEALSIZE],
		(
			SELECT [DATE_KEY]
			FROM [dbo].[DWH_Dim_Date] Q_F
			WHERE Q_F.DATE = CAST(STG_F.[ORDERDATE] AS DATE)
		) [DATE_KEY_FK],
		(
			SELECT [CUSTOMER_SK]
			FROM [dbo].[DWH_Dim_CUSTOMER] Q_C
			WHERE Q_C.[CUSTOMERNAME]=STG_F.CUSTOMERNAME AND Q_C.FLAG='Y'
		)[CUSTOMER_FK],
		(
			SELECT [PRODUCT_SK]
			FROM  [dbo].[DWH_Dim_PRODUCT] Q_P
			WHERE Q_P.[PRODUCTCODE]=STG_F.[PRODUCTCODE] AND Q_P.FLAG='Y'
		)[PRODUCT_FK],
		(
			SELECT [DATE_KEY]
			FROM [dbo].[DWH_Dim_Date] Q_F_L
			WHERE Q_F_L.[DATE]= CAST(STG_F.[LOAD_DMT] AS DATE)
		) [LOAD_INT_FK]
	FROM [dbo].[STG_SALES] STG_F

END
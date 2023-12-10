
CREATE PROCEDURE [dbo].[SUP_DWH_CUSTOMER]
AS
BEGIN
	
	MERGE INTO [dbo].[DWH_Dim_CUSTOMER] AS TARGET
	USING (
	SELECT [CUSTOMERNAME],
					[PHONE],
					CASE 
						WHEN ADDRESSLINE2 IS NOT NULL THEN CONCAT(ADDRESSLINE1,', ',ADDRESSLINE2)
						WHEN ADDRESSLINE2 IS NULL THEN ADDRESSLINE1 
					END [ADDRESSLINE],
					[CITY],
					CASE 
						WHEN CHARINDEX(',',[State]) <> 0 THEN SUBSTRING([State],0,CHARINDEX(',',[State]))
					END [STATE],
					[POSTALCODE],
					[COUNTRY],
					[TERRITORY],
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					'Y' [FLAG],
					ADDRESSLINE2,
					ADDRESSLINE1
	FROM (SELECT  [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					[CONCAT KEY],
					[ROW NO]
			FROM (SELECT [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					SSN.[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					ROW_NUMBER() OVER (PARTITION BY [CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME] --ONLY CHECKING THE ADDRESS SINCE CITY,STATE,POSTALCODE,COUNTRY ARE DEPENDAND ON STATE
						ORDER BY [CUSTOMERNAME]) [ROW NO],
						CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
					FROM [dbo].[STG_SALES] SIS
				LEFT JOIN [dbo].[STG_STATE_NAME] SSN ON SIS.[STATE]=SSN.Code
				WHERE [CUSTOMERNAME] IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER])
			) SS
			WHERE [ROW NO] = 1 AND [CONCAT KEY] <> (SELECT CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
													FROM [dbo].[DWH_Dim_CUSTOMER] IIC
													WHERE IIC.[CUSTOMERNAME] = SS.[CUSTOMERNAME] AND IIC.[FLAG] = 'Y')
			UNION 

			SELECT  [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					[CONCAT KEY],
					[ROW NO]
			FROM (SELECT [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					SSN.[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					ROW_NUMBER() OVER (PARTITION BY [CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME] --ONLY CHECKING THE ADDRESS SINCE CITY,STATE,POSTALCODE,COUNTRY ARE DEPENDAND ON STATE
						ORDER BY [CUSTOMERNAME]) [ROW NO],
						CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
					FROM [dbo].[STG_SALES] SIS
				LEFT JOIN [dbo].[STG_STATE_NAME] SSN ON SIS.[STATE]=SSN.Code
				WHERE [CUSTOMERNAME] NOT IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER])
			) SS
			WHERE [ROW NO] = 1
		)SSS
		) SCOURCE 

		  ON TARGET.[CUSTOMERNAME] = SCOURCE.[CUSTOMERNAME] 
		  WHEN MATCHED AND TARGET.FLAG = 'Y' 
		  THEN UPDATE 
		  SET TARGET.FLAG = 'N';

		--------------------------------------------------------
		INSERT INTO [dbo].[DWH_Dim_CUSTOMER]([CUSTOMERNAME]
		  ,[PHONE]
		  ,[ADDRESSLINE]
		  ,[CITY]
		  ,[STATE]
		  ,[POSTALCODE]
		  ,[COUNTRY]
		  ,[TERRITORY]
		  ,[CONTACTLASTNAME]
		  ,[CONTACTFIRSTNAME]
		  ,[FLAG]
		  ,[ADDRESSLINE2]
		  ,[ADDRESSLINE1]
		  )

		  SELECT [CUSTOMERNAME],
					[PHONE],
					CASE 
						WHEN ADDRESSLINE2 IS NOT NULL THEN CONCAT(ADDRESSLINE1,', ',ADDRESSLINE2)
						WHEN ADDRESSLINE2 IS NULL THEN ADDRESSLINE1 
					END [ADDRESSLINE],
					[CITY],
					CASE 
						WHEN CHARINDEX(',',[State]) <> 0 THEN SUBSTRING([State],0,CHARINDEX(',',[State]))
					END [STATE],
					[POSTALCODE],
					[COUNTRY],
					[TERRITORY],
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					'Y' [FLAG],
					ADDRESSLINE2,
					ADDRESSLINE1
	FROM (SELECT  [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					[CONCAT KEY],
					[ROW NO]
			FROM (SELECT [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					SSN.[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					ROW_NUMBER() OVER (PARTITION BY [CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME] --ONLY CHECKING THE ADDRESS SINCE CITY,STATE,POSTALCODE,COUNTRY ARE DEPENDAND ON STATE
						ORDER BY [CUSTOMERNAME]) [ROW NO],
						CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
					FROM [dbo].[STG_SALES] SIS
				LEFT JOIN [dbo].[STG_STATE_NAME] SSN ON SIS.[STATE]=SSN.Code
				WHERE [CUSTOMERNAME] IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER])
			) SS
			WHERE [ROW NO] = 1 AND [CONCAT KEY] <> (SELECT CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
													FROM [dbo].[DWH_Dim_CUSTOMER] IIC
													WHERE IIC.[CUSTOMERNAME] = SS.[CUSTOMERNAME] AND IIC.[FLAG] = 'Y')
			UNION 

			SELECT  [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					[CONCAT KEY],
					[ROW NO]
			FROM (SELECT [CUSTOMERNAME],
					[PHONE],
					ADDRESSLINE1,
					ADDRESSLINE2,
					[CONTACTLASTNAME],
					[CONTACTFIRSTNAME],
					SSN.[State],
					[TERRITORY],
					[POSTALCODE],
					[COUNTRY],
					[CITY],
					ROW_NUMBER() OVER (PARTITION BY [CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME] --ONLY CHECKING THE ADDRESS SINCE CITY,STATE,POSTALCODE,COUNTRY ARE DEPENDAND ON STATE
						ORDER BY [CUSTOMERNAME]) [ROW NO],
						CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
					FROM [dbo].[STG_SALES] SIS
				LEFT JOIN [dbo].[STG_STATE_NAME] SSN ON SIS.[STATE]=SSN.Code
				WHERE [CUSTOMERNAME] NOT IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER])
			) SS
			WHERE [ROW NO] = 1
		)SSS

	
							
			
			
	---------------------------------------------------------
	-----INSERTION PRODUCT------------
	MERGE INTO [dbo].[DWH_Dim_PRODUCT] AS TARGET
	USING (	INSERT INTO [dbo].[DWH_Dim_PRODUCT] (
						[PRODUCTCODE]
						,[PRODUCTLINE]
						,[MSRP]
						,[FLAG]
	)
	SELECT [PRODUCTCODE],
		[PRODUCTLINE],
		[MSRP],
		'Y' 
	FROM (SELECT *,
			ROW_NUMBER() OVER (PARTITION BY [PRODUCTCODE],[PRODUCTLINE],[MSRP] 
								ORDER BY [PRODUCTCODE]) [ROW NO]
		FROM [dbo].[STG_SALES]) STG
	WHERE [ROW NO] = 1 AND 
			[PRODUCTCODE] NOT IN (SELECT DISTINCT [PRODUCTCODE] FROM [dbo].[DWH_Dim_PRODUCT])

	UNION 

	SELECT [PRODUCTCODE],
		[PRODUCTLINE],
		[MSRP],
		'Y' 
	FROM (SELECT *,
			ROW_NUMBER() OVER (PARTITION BY [PRODUCTCODE],[PRODUCTLINE],[MSRP] 
								ORDER BY [PRODUCTCODE]) [ROW NO],
			CONCAT([PRODUCTCODE],[PRODUCTLINE],[MSRP]) [CONCAT KEY]
		FROM [dbo].[STG_SALES]
		WHERE [PRODUCTCODE] IN (SELECT DISTINCT [PRODUCTCODE] FROM [dbo].[DWH_Dim_PRODUCT])
		) STG_P
	WHERE [ROW NO] = 1 AND [CONCAT KEY] <> (SELECT CONCAT([PRODUCTCODE],[PRODUCTLINE],[MSRP])
											FROM [dbo].[DWH_Dim_PRODUCT] I_P
											WHERE I_P.[PRODUCTCODE] = STG_P.[PRODUCTCODE])
	

	SELECT * FROM [dbo].[STG_SALES]
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
      --,[CUSTOMER_FK]
      --,[PRODUCT_FK]
      ,[LOAD_INT_FK]
	  )
	SELECT [ORDERNUMBER],
		[QUANTITYORDERED],
		[PRICEEACH],
		[ORDERLINENUMBER],
		[SALES],
		[STATUS],
		[DEALSIZE],
		(SELECT [DATE_KEY]
		FROM [dbo].[DWH_Dim_Date] Q_F
		WHERE Q_F.DATE = CAST(STG_F.[ORDERDATE] AS DATE)
		) [DATE_KEY_FK],
		(SELECT [DATE_KEY]
		FROM [dbo].[DWH_Dim_Date] Q_F_L
		WHERE Q_F_L.[DATE]= CAST(STG_F.[LOAD_DMT] AS DATE)
		) [LOAD_INT_FK]
	FROM [dbo].[STG_SALES] STG_F

	
	-----------------UPDATING SCD FLAGS----------------
	-----------------///////////////////////////////////////////////////////////////////////////////////////////////----------
	-----
	UPDATE D
	SET [FLAG] = 'Y'
	SELECT *
	FROM (SELECT *,
			ROW_NUMBER() OVER (PARTITION BY [CUSTOMERNAME] ORDER BY [CUSTOMERNAME]) [ROW NO]
		FROM [dbo].[DWH_Dim_CUSTOMER]
		LEFT JOIN [dbo].[DWH__FACT_ORDER] DF_C ON ) UDC
	WHERE [ROW NO] > 1 

	JOIN [dbo].[DWH__FACT_ORDER] F ON D.[CUSTOMER_SK]=F.[CUSTOMER_FK]
	WHERE D.[CUSTOMERNAME] IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER]) AND 
		  F.[DATE_KEY_FK] > (SELECT MAX([DATE_KEY_FK])
								FROM [dbo].[DWH_Dim_CUSTOMER] DC
								LEFT JOIN [dbo].[DWH__FACT_ORDER] FO ON D.[CUSTOMER_SK]=F.[CUSTOMER_FK]
								WHERE D.[CUSTOMERNAME] = DC.[CUSTOMERNAME]
								GROUP BY DC.[CUSTOMERNAME]
SELECT * FROM 						)
	-----
	UPDATE D
	SET [FLAG] = 'N'
	FROM [dbo].[DWH_Dim_CUSTOMER] D
	LEFT JOIN [dbo].[DWH__FACT_ORDER] F ON D.[CUSTOMER_SK]=F.[CUSTOMER_FK]
	WHERE D.[CUSTOMERNAME] IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER]) AND 
			F.[DATE_KEY_FK] < (SELECT MAX([DATE_KEY_FK])
								FROM [dbo].[DWH_Dim_CUSTOMER] DC
								LEFT JOIN [dbo].[DWH__FACT_ORDER] FO ON D.[CUSTOMER_SK]=F.[CUSTOMER_FK]
								WHERE D.[CUSTOMERNAME] = DC.[CUSTOMERNAME]
								GROUP BY DC.[CUSTOMERNAME])
	-----------------///////////////////////////////////////////////////////////////////////////////////////////////----------

	-----------------///////////////////////////////////////////////////////////////////////////////////////////////----------
	-----------------UPDATING [dbo].[DWH_Dim_PRODUCT] FLAG COLUMN ------------------
	-----
	UPDATE D
	SET [FLAG] = 'Y'
	FROM [dbo].[DWH_Dim_PRODUCT] D
	LEFT JOIN [dbo].[DWH__FACT_ORDER] F ON D.[PRODUCT_SK]=F.[PRODUCT_FK]
	WHERE D.[CUSTOMERNAME] IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER]) AND 
			F.[DATE_KEY_FK] > (SELECT MAX([DATE_KEY_FK])
			FROM [dbo].[DWH_Dim_CUSTOMER] DC
			LEFT JOIN [dbo].[DWH__FACT_ORDER] FO ON D.[CUSTOMER_SK]=F.[CUSTOMER_FK]
			WHERE D.[CUSTOMERNAME] = DC.[CUSTOMERNAME]
			GROUP BY DC.[CUSTOMERNAME])

	-----
	UPDATE [dbo].[DWH_Dim_CUSTOMER]
	SET [FLAG] = 'N'
	FROM [dbo].[DWH_Dim_CUSTOMER] D
	LEFT JOIN [dbo].[DWH__FACT_ORDER] F ON D.[CUSTOMER_SK]=F.[CUSTOMER_FK]
	WHERE D.[CUSTOMERNAME] IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER]) AND 
			F.[DATE_KEY_FK] < (SELECT MAX([DATE_KEY_FK])
								FROM [dbo].[DWH_Dim_CUSTOMER] DC
								LEFT JOIN [dbo].[DWH__FACT_ORDER] FO ON D.[CUSTOMER_SK]=F.[CUSTOMER_FK]
								WHERE D.[CUSTOMERNAME] = DC.[CUSTOMERNAME]
								GROUP BY DC.[CUSTOMERNAME])
	-----------------///////////////////////////////////////////////////////////////////////////////////////////////----------

END

TRUNCATE TABLE [dbo].[DWH_Dim_CUSTOMER]
SELECT * FROM [dbo].[DWH_Dim_CUSTOMER]

SELECT * FROM [dbo].[DWH__FACT_ORDER]
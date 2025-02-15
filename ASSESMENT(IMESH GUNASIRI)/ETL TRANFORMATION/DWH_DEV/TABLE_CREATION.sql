create table [dbo].[DWH_Dim_Date](
	[DATE_KEY] INT PRIMARY KEY,
	[DATE] DATE,
	[YEAR] INT,
	[QUARTER] INT,
	[MONTH] INT,
	[MONTH_NAME] NVARCHAR(50),
	[WEEK_OF_YEAR] INT,
	[DAY] INT,
	[DAY_NAME] NVARCHAR(50)
)

CREATE TABLE [dbo].[DWH_Dim_CUSTOMER](
	[CUSTOMER_SK] INT IDENTITY(1000,1) PRIMARY KEY,
	[CUSTOMERNAME] NVARCHAR(50),
	[PHONE] NVARCHAR(50),
	[ADDRESSLINE] NVARCHAR(50),
	[CITY] NVARCHAR(50),
	[STATE] NVARCHAR(50),
	[POSTALCODE] NVARCHAR(50),
	[COUNTRY] NVARCHAR(50),
	[TERRITORY] NVARCHAR(50),
	[CONTACTLASTNAME] NVARCHAR(50),
	[CONTACTFIRSTNAME] NVARCHAR(50),
	[FLAG] CHAR(1)
)


CREATE TABLE [dbo].[DWH_Dim_PRODUCT](
	[PRODUCT_SK] INT IDENTITY(1,1) PRIMARY KEY,
	[PRODUCTCODE] NVARCHAR(50),
	[PRODUCTLINE] NVARCHAR(50),
	[MSRP] NVARCHAR(50)
)

CREATE TABLE [dbo].[DWH__FACT_ORDER](
	---[ORDER_SK] INT IDENTITY(1,1) PRIMARY KEY,
	[ORDERNUMBER] INT,
	[QUANTITYORDERED] INT,
	[PRICEEACH] FLOAT,
	[ORDERLINENUMBER] INT,
	[SALES] FLOAT,
	[STATUS] NVARCHAR(50),
	[DEALSIZE] NVARCHAR(50),
	[DATE_KEY_FK] INT,
	[CUSTOMER_FK] INT,
	[PRODUCT_FK] INT,
	[LOAD_INT_FK] INT
)

ALTER TABLE [dbo].[DWH__FACT_ORDER]
ADD CONSTRAINT FK_PRODUCT 
FOREIGN KEY ([PRODUCT_FK]) REFERENCES  [dbo].[DWH_Dim_PRODUCT]([PRODUCT_SK])

ALTER TABLE [dbo].[DWH__FACT_ORDER]
ADD CONSTRAINT FK_CUSTOMER 
FOREIGN KEY ([CUSTOMER_FK]) REFERENCES [dbo].[DWH_Dim_CUSTOMER]([CUSTOMER_SK])


ALTER TABLE [dbo].[DWH__FACT_ORDER]
ADD CONSTRAINT FK_DATE_KEY
FOREIGN KEY ([DATE_KEY_FK]) REFERENCES [dbo].[DWH_Dim_Date]([DATE_KEY])


ALTER TABLE [dbo].[DWH__FACT_ORDER]
ADD CONSTRAINT FK_LOAD_INT_KEY
FOREIGN KEY ([LOAD_INT_FK]) REFERENCES [dbo].[DWH_Dim_Date]([DATE_KEY])


--------------------------------
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
	)
	SELECT [CUSTOMERNAME],
		[PHONE],
		CASE 
			WHEN ADDRESSLINE2 IS NOT NULL THEN CONCAT(ADDRESSLINE1,', ',ADDRESSLINE2)
			WHEN ADDRESSLINE2 IS NULL THEN ADDRESSLINE1 
		END [ADDRESSLINE],
		[CITY],
		CASE 
			WHEN CHARINDEX(',',SN.[State]) <> 0 THEN SUBSTRING(SN.[State],0,CHARINDEX(',',SN.[State]))
		END [STATE],
		[POSTALCODE],
		[COUNTRY],
		[TERRITORY],
		[CONTACTLASTNAME],
		[CONTACTFIRSTNAME],
		'Y'
	FROM (
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY [CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME] --ONLY CHECKING THE ADDRESS SINCE CITY,STATE,POSTALCODE,COUNTRY ARE DEPENDAND ON STATE
					ORDER BY [CUSTOMERNAME]) [ROW NO],
				CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
			FROM [dbo].[STG_SALES]) S
	LEFT JOIN [dbo].[STG_STATE_NAME] SN ON S.[STATE]=SN.Code
	WHERE [ROW NO] = 1 AND 
			[CUSTOMERNAME] NOT IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER])
	----------------------------------------------------------
	UNION
	-------------------------------------------------------------
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
		'Y'
	FROM (
			SELECT [CUSTOMERNAME],
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
	WHERE [ROW NO] = 1 AND (SS.[PHONE] <> (
											SELECT [PHONE] 
											FROM [dbo].[DWH_Dim_CUSTOMER] IC
											WHERE IC.[CUSTOMERNAME] = SS.[CUSTOMERNAME] AND IC.[FLAG] = 'Y')
							OR SS.ADDRESSLINE1 <> (
											SELECT SUBSTRING(ADDRESSLINE,1,LEN(ADDRESSLINE) - CHARINDEX(',', REVERSE(ADDRESSLINE))) 
											FROM [dbo].[DWH_Dim_CUSTOMER] IIC
											WHERE IIC.[CUSTOMERNAME] = SS.[CUSTOMERNAME] AND IIC.[FLAG] = 'Y')
							OR SS.ADDRESSLINE2 <> (
											SELECT SUBSTRING(ADDRESSLINE,LEN(ADDRESSLINE) - CHARINDEX(',', REVERSE(ADDRESSLINE))+3,LEN(ADDRESSLINE))
											FROM [dbo].[DWH_Dim_CUSTOMER] IIIC
											WHERE IIIC.[CUSTOMERNAME] = SS.[CUSTOMERNAME] AND IIIC.[FLAG] = 'Y')
							OR [CONTACTLASTNAME] <> (
											SELECT [CONTACTLASTNAME]
											FROM [dbo].[DWH_Dim_CUSTOMER] IIIIC
											WHERE IIIIC.[CUSTOMERNAME] = SS.[CUSTOMERNAME] AND IIIIC.[FLAG] = 'Y')
							OR [CONTACTFIRSTNAME] <> (
											SELECT [CONTACTFIRSTNAME]
											FROM [dbo].[DWH_Dim_CUSTOMER] IIIIIC
											WHERE IIIIIC.[CUSTOMERNAME] = SS.[CUSTOMERNAME] AND IIIIIC.[FLAG] = 'Y')
							)



		SELECT *
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
			WHERE [ROW NO] = 1 AND [CONCAT KEY] = (SELECT CONCAT([CUSTOMERNAME],[PHONE],ADDRESSLINE1,ADDRESSLINE2,[CONTACTLASTNAME],[CONTACTFIRSTNAME]) [CONCAT KEY]
													FROM [dbo].[DWH_Dim_CUSTOMER] IIC
													WHERE IIC.[CUSTOMERNAME] = 'Atelier graphique' AND IIC.[FLAG] = 'Y')
		)SSS
		
		
		
		WHERE SSS.ADDRESSLINE1 <> (
							SELECT SUBSTRING(ADDRESSLINE,1,LEN(ADDRESSLINE) - CHARINDEX(',', REVERSE(ADDRESSLINE))) 
							FROM [dbo].[DWH_Dim_CUSTOMER] IIC
							WHERE IIC.[CUSTOMERNAME] = 'Atelier graphique' AND IIC.[FLAG] = 'Y')
			OR SSS.ADDRESSLINE2 <> (
							SELECT SUBSTRING(ADDRESSLINE,LEN(ADDRESSLINE) - CHARINDEX(',', REVERSE(ADDRESSLINE))+3,LEN(ADDRESSLINE))
							FROM [dbo].[DWH_Dim_CUSTOMER] IIIC
							WHERE IIIC.[CUSTOMERNAME] = SSS.[CUSTOMERNAME] AND IIIC.[FLAG] = 'Y')
	SELECT * FROM [DWH_Dim_CUSTOMER] WHERE [CUSTOMERNAME] = 'Atelier graphique'
	UNION 

		SELECT *
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
					[CITY]
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
						ORDER BY [CUSTOMERNAME]) [ROW NO]
					FROM [dbo].[STG_SALES] SIS
				LEFT JOIN [dbo].[STG_STATE_NAME] SSN ON SIS.[STATE]=SSN.Code
				WHERE [CUSTOMERNAME] IN (SELECT DISTINCT [CUSTOMERNAME] FROM [dbo].[DWH_Dim_CUSTOMER])
			) SS
			WHERE [ROW NO] = 1
		)SSS
 

)



ALTER TABLE [dbo].[DWH_Dim_CUSTOMER]
ADD ADDRESSLINE1 NVARCHAR(50)
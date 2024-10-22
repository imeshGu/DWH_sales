USE [STG_Cargills_SALES]
GO
/****** Object:  StoredProcedure [dbo].[Sup_STG_SALES]    Script Date: 11/27/2023 5:10:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sup_STG_SALES] 

AS
BEGIN
	declare @date datetime = cast(getdate() as date)

	update [dbo].STG_SALES
	set [LOAD_DMT] = cast(@date as date), 
		[LOAD_INT] = cast(concat(datepart(year,@date),datepart(month,@date), datepart(DAY,@date)) as int)
	where [LOAD_DMT] is null and [LOAD_INT] is null

	update [dbo].[STG_STATE_NAME]
	set [LOAD_DMT] = cast(@date as date), 
		[LOAD_INT] = cast(concat(datepart(year,@date),datepart(month,@date), datepart(DAY,@date)) as int)
	where [LOAD_DMT] is null and [LOAD_INT] is null

END


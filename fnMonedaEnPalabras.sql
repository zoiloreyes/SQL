USE NRH

DROP FUNCTION IF EXISTS dbo.fnMonedaEnPalabras
go
CREATE FUNCTION dbo.fnMonedaEnPalabras (@Number as BIGINT)
	RETURNS VARCHAR(1024)
AS
BEGIN
	DECLARE @Below30 TABLE(ID INT IDENTITY(0,1), WORD VARCHAR(150))
	DECLARE @Below100 Table(ID INT IDENTITY(2,1), WORD VARCHAR(32))
	INSERT @Below30 (WORD) VALUES (''), ('un'), ('dos'), ('tres'), 
								  ('cuatro'),('cinco'),('seis'),('siete'),('ocho'),
								  ('nueve'),('diez'),('once'),('doce'),('trece'),('catorce'),
								  ('quince'),('dieciséis'),('diecisiete'),('dieciocho'),('diecinueve'),
								  ('veinte'),('veintiún'),('veintidós'),('veintitrés'),('veinticuatro'),
								  ('veinticinco'),('veintiseis'),('veintisiete'),('veintiocho'),('veintinueve')
	INSERT @Below100 values ('treinta'), ('cuarenta'),('cincuenta'),('sesenta'),('setenta'),('ochenta'),('noventa')

	Declare @ESPANOL VARCHAR(1024) = 
	(
		SELECT CASE
			WHEN @Number = 0 THEN ''
			WHEN @Number BETWEEN 1 AND 29
				THEN (SELECT WORD FROM @Below30 WHERE ID=@Number)
			WHEN @Number BETWEEN 30 AND 99
				THEN (SELECT WORD FROM @Below100 WHERE ID= ((@Number/10) -1)) + ' y ' + dbo.fnMonedaEnPalabras (@Number % 10)				
			WHEN @Number BETWEEN 100 AND 199
				THEN (SELECT CASE WHEN @Number = 100 THEN 'cien'
					  ELSE ('ciento ' + dbo.fnMonedaEnPalabras(@Number % 100))
					  END)
			WHEN @Number BETWEEN 200 AND 499 OR @Number BETWEEN 600 and 699 OR @Number BETWEEN 800 AND 899
				THEN (dbo.fnMonedaEnPalabras(@Number / 100) + 'cientos ' + dbo.fnMonedaEnPalabras(@Number % 100))
			WHEN @Number BETWEEN 500 and 599
				THEN ('quinientos ' + dbo.fnMonedaEnPalabras(@Number % 100))
			WHEN @Number BETWEEN 700 and 799
				THEN ('setecientos ' + dbo.fnMonedaEnPalabras(@Number % 100))
			WHEN @Number BETWEEN 900 and 999
				THEN ('novecientos ' + dbo.fnMonedaEnPalabras(@Number % 100)) 
			WHEN @Number BETWEEN 1000 and 1999
				THEN (' mil ' + dbo.fnMonedaEnPalabras(@Number % 1000))
			WHEN @Number BETWEEN 2000 and 999999
				THEN (dbo.fnMonedaEnPalabras(@Number / 1000) + ' mil ' + dbo.fnMonedaEnPalabras(@Number % 1000))
			WHEN @Number BETWEEN 1000000 AND 1999999
				THEN ('un millón ' + dbo.fnMonedaEnPalabras(@Number % 1000000))
			WHEN @Number BETWEEN 1999999 AND 999999999
				THEN (dbo.fnMonedaEnPalabras(@Number / 1000000) + ' millones ' + dbo.fnMonedaEnPalabras(@Number % 1000000))
			ELSE
				' Entrada invalida '
			END

	)

	SELECT @ESPANOL = RTRIM(@ESPANOL)
	SELECT @ESPANOL = RTRIM(LEFT(@ESPANOL,len(@ESPANOL)-1))

                 WHERE RIGHT(@ESPANOL,1)='y'
	RETURN (@ESPANOL)
END
GO


GO

DROP FUNCTION IF EXISTS dbo.fnMonedaDecimalEnPalabras
go
CREATE FUNCTION dbo.fnMonedaDecimalEnPalabras (@Number as Decimal(18,2), @NombreMoneda AS VARCHAR(40), @NombreCentavos AS VARCHAR(40))
	RETURNS VARCHAR(1024)
AS
BEGIN

	DECLARE @Entero AS INT = (SELECT FLOOR(@Number))
	DECLARE @Centavos AS INT = (SELECT PARSENAME(@Number,1))


	Declare @Resultado VARCHAR(2048);
	select @Resultado = CASE WHEN @Entero = 0 AND @Centavos = 0 
								THEN 'cero ' + @NombreMoneda
							 WHEN @Entero != 0 AND @Centavos = 0
								THEN dbo.fnMonedaEnPalabras(@Entero) + ' ' + @NombreMoneda
							 WHEN @Entero = 0 AND @Centavos != 0
								THEN 'cero ' + @NombreMoneda + ' con ' + dbo.fnMonedaEnPalabras(@Centavos) + ' ' + @NombreCentavos
							 ELSE
								dbo.fnMonedaEnPalabras(@Entero) + ' ' + @NombreMoneda + ' con ' + dbo.fnMonedaEnPalabras(@Centavos) + ' ' + @NombreCentavos
						END
	RETURN @Resultado
END

GO

DROP FUNCTION IF EXISTS dbo.fnMonedaEnPalabrasFormatoBanreservas
go
CREATE FUNCTION dbo.fnMonedaEnPalabrasFormatoBanreservas (@Number as Decimal(18,2), @NombreMoneda AS VARCHAR(40))
	RETURNS VARCHAR(1024)
AS
BEGIN

	DECLARE @Entero AS INT = (SELECT FLOOR(@Number))
	DECLARE @Centavos AS INT = (SELECT PARSENAME(@Number,1))

	Declare @Resultado VARCHAR(2048);
	select @Resultado = CASE WHEN @Entero = 0
								THEN 'cero ' + @NombreMoneda + ' con ' +  LEFT((PARSENAME(ROUND(@Number,2),1)),2) + '/100'
							 WHEN @Entero != 0
								THEN dbo.fnMonedaEnPalabras(@Entero) + ' ' + @NombreMoneda + ' con ' +  LEFT((PARSENAME(ROUND(@Number,2),1)),2) + '/100'
						END
	RETURN @Resultado
END
GO

--Ejemplo basico
SELECT dbo.fnMonedaDecimalEnPalabras(101112523.65, 'pesos','centavos')

--Formato Banreservas
SELECT dbo.fnMonedaEnPalabrasFormatoBanreservas(4300.30, 'pesos')
DROP FUNCTION IF EXISTS dbo.fnFechaCompleta
GO
CREATE FUNCTION dbo.fnFechaCompleta (@Fecha DATETIME)
RETURNS NVARCHAR(200)
AS
BEGIN
	RETURN CONCAT(FORMAT(@Fecha, '%d', 'es'),' de ',FORMAT(@Fecha,'MMMM','es'),' del ',YEAR(@Fecha))
END
GO

SELECT dbo.fnFechaCompleta(GETDATE())
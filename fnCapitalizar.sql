GO
DROP FUNCTION IF EXISTS fnCapitalizar
GO
 CREATE FUNCTION dbo.fnCapitalizar(@String VARCHAR(8000))
RETURNS VARCHAR(8000)
     AS
  BEGIN 
----------------------------------------------------------------------------------------------------
 DECLARE @i INT           -- index
  DECLARE @l INT           -- input length
  DECLARE @c NCHAR(1)      -- current char
  DECLARE @f INT           -- first letter flag (1/0)
  DECLARE @o VARCHAR(255)  -- output string
  DECLARE @w VARCHAR(10)   -- characters considered as white space

  SET @w = '[' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(160) + ' ' + ']'
  SET @i = 1
  SET @l = LEN(@String)
  SET @f = 1
  SET @o = ''
  WHILE @i <= @l
  BEGIN
    SET @c = SUBSTRING(@String, @i, 1)
    IF @f = 1 
    BEGIN
     SET @o = @o + @c
     SET @f = 0
    END
    ELSE
    BEGIN
     SET @o = @o + LOWER(@c)
    END
    IF @c LIKE @w SET @f = 1
    SET @i = @i + 1
  END
  RETURN @o
    END ;
	GO
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.GetUserByEmail'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetUserByEmail]
        @Email NVARCHAR(256)
    AS
    BEGIN
        SELECT * FROM Users WHERE Email = @Email;
    END
    ')
END 
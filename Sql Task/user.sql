USE userdb;
Go

CREATE TABLE Users (
    userId INT PRIMARY KEY IDENTITY(1,1), 
    name NVARCHAR(100) NOT NULL,           
    age INT NOT NULL,                      
);

Insert into Users (name , age) values('sachin',44),('dhoni',42),('rohit' , 36),('kholi',35)

select * from users


CREATE TABLE TargetUsers (
    userId INT,
    name NVARCHAR(100) NOT NULL,
    age INT NOT NULL,
    createdAt DATETIME,
    updatedAt DATETIME,  
    isDeleted BIT DEFAULT 0,  
    PRIMARY KEY (userId, updatedAt)  
);

CREATE PROCEDURE usp_ETL_TransferUsers
AS
BEGIN
    INSERT INTO TargetUsers (userId, name, age, createdAt, updatedAt, isDeleted)
    SELECT 
        u.userId, 
        u.name, 
        u.age, 
        CASE 
            WHEN t.userId IS NULL THEN GETDATE()  
            ELSE t.createdAt
        END AS createdAt,
        GETDATE() AS updatedAt,  
        0 AS isDeleted  
    FROM 
        Users u
    LEFT JOIN 
        TargetUsers t 
    ON 
        u.userId = t.userId 
        AND t.updatedAt = (SELECT MAX(updatedAt) FROM TargetUsers WHERE userId = u.userId)
    WHERE 
        t.userId IS NULL  
        OR t.updatedAt < GETDATE(); 

    UPDATE TargetUsers
    SET isDeleted = 1,  
        updatedAt = GETDATE() 
    WHERE userId NOT IN (
        SELECT userId 
        FROM Users
    ) AND isDeleted = 0;  
END;

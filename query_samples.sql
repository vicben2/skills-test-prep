--creating db
CREATE DATABASE Zeth;

--use db
USE Zeth;

--creating table
CREATE TABLE Students (
	StudentID INT IDENTITY(1,1) PRIMARY KEY, --primary key
	FirstName VARCHAR(100) NOT NULL,
	LastName VARCHAR(100) NOT NULL,
	RegisterDate DATETIME DEFAULT GETDATE(), --default value
)

--creating index
CREATE INDEX Idx_Students
ON Students(FirstName, LastName)

CREATE TABLE Sections (
	SectionID INT IDENTITY(1,1) PRIMARY KEY,
	SectionName VARCHAR(50) NOT NULL,
	Room VARCHAR(20) NOT NULL
)

CREATE INDEX Idx_Section
ON Sections(SectionName);

--altering table by adding new column
ALTER TABLE Students
ADD SectionID INT NOT NULL;

--querying from table
SELECT * FROM Students;

--altering table by adding fk constraint
ALTER TABLE Students
ADD CONSTRAINT FK_StudentSection
FOREIGN KEY (SectionID) REFERENCES Sections(SectionID);

--dropping a column from table
ALTER TABLE Sections
DROP COLUMN Room;

ALTER TABLE Sections
ADD RoomID INT NOT NULL;

CREATE TABLE Rooms(
	RoomID INT IDENTITY(1,1) PRIMARY KEY,
	RoomFloor VARCHAR(20) NOT NULL,
	RoomNum VARCHAR(20) NOT NULL
);

ALTER TABLE Sections
ADD CONSTRAINT FK_SectionRoom
FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID);

--populating tables
INSERT INTO Rooms(RoomFloor, RoomNum)
VALUES
('1st', '101'),
('2nd', '205'),
('2nd', '206');

INSERT INTO Sections(SectionName, RoomID)
VALUES
('1A', 2),
('2B', 3),
('3A', 1)

--adding check constraint but allows null
ALTER TABLE Students
ADD Age INT NULL;

ALTER TABLE Students
ADD CONSTRAINT CK_StudentAge CHECK (Age > 0);

INSERT INTO Students(FirstName, LastName, SectionID, Age)
VALUES
('Dog', 'Man', 1, NULL),
('Awoo', 'Ga', 1, 13),
('Nyan', 'Cat', 2, 14),
('Zeth', 'Bran', 2, NULL),
('Ice', 'Cold', 2, 14);

--STORED PROCEDURES
--GET STUDENTS FROM SECTION, ORDER BY LAST NAME
CREATE PROCEDURE GetStudentsInSection
	@SectionID INT
AS
BEGIN
	SELECT st.FirstName, st.LastName, st.Age FROM Students st
	INNER JOIN Sections se ON st.SectionID = se.SectionID
	WHERE se.SectionID = @SectionID
	ORDER BY st.LastName
END;

--UPDATE AGE
CREATE PROCEDURE UpdateStudentAge
	@StudentID INT,
	@NewAge INT
AS
BEGIN
	UPDATE Students
	SET Age = @NewAge
	WHERE StudentID = @StudentID
END;

--REMOVE A STUDENT
CREATE PROCEDURE RemoveStudent
	@StudentID INT
AS
BEGIN
	DELETE FROM Students
	WHERE StudentID = @StudentID
END;

--EXECUTING SPs
EXEC GetStudentsInSection @SectionID = 1;
EXEC UpdateStudentAge @StudentID = 4, @NewAge = 18;
EXEC RemoveStudent @StudentId = 1

--TABLE VALUE FUNCTIONS (like select)
--GET STUDENT'S FIRST NAME, LAST NAME, AGE, SECTION, AND DESIGNATED ROOM
--replace CREATE with ALTER to update funcs and sps
ALTER FUNCTION GetStudentInfo(@StudentID INT)
RETURNS TABLE
AS
RETURN (
	--concat by combining room floor and number
	SELECT st.FirstName, st.LastName, st.Age, se.SectionName, CONCAT(r.RoomFloor, ' Floor, Room ', r.RoomNum) as Room FROM Students st
	INNER JOIN Sections se ON st.SectionID = se.SectionID
	INNER JOIN Rooms r ON se.RoomID = r.RoomID
	WHERE st.StudentID = @StudentID
);

--EXECUTING TVF
SELECT * FROM GetStudentInfo(3);

--SCALAR FUNCTIONS
--GET A STUDENT'S DESIGNATED ROOM
CREATE FUNCTION GetStudentRoom(@StudentID INT)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @Room VARCHAR(50);
	
	SELECT @Room = CONCAT(r.RoomFloor, ' Floor, Room ', r.RoomNum) FROM Students st
	INNER JOIN Sections se ON st.SectionID = se.SectionID
	INNER JOIN Rooms r ON se.RoomID = r.RoomID
	RETURN @Room
END;

--EXECUTING SCALAR FUNCS
SELECT FirstName, LastName, se.SectionName, [dbo].[GetStudentRoom](StudentID) as Room FROM Students st
INNER JOIN Sections se ON st.SectionID = se.SectionID


SELECT StudentID, FirstName, LastName, Age FROM Students

CREATE PROCEDURE GetStudentsDetails
AS
BEGIN
	SELECT st.FirstName, st.LastName, st.Age, se.SectionName, CONCAT(r.RoomFloor, ' Floor, Room ', r.RoomNum) AS DesignatedRoom FROM Students st
	INNER JOIN Sections se ON st.SectionID = se.SectionID
	INNER JOIN Rooms r ON se.RoomID = r.RoomID
END;

EXEC GetStudentsDetails;

CREATE PROCEDURE TransferStudent(@StudentID INT, @ToSectionID INT)
AS
BEGIN
	UPDATE Students
	SET SectionID = @ToSectionID
	WHERE StudentID = @StudentID
END;


SELECT * FROM Sections
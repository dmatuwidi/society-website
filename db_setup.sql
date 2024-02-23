DROP DATABASE IF EXISTS coursework;

CREATE DATABASE coursework;

USE coursework;

-- This is the Course table
 
DROP TABLE IF EXISTS Course;

CREATE TABLE Course (
Crs_Code 	INT UNSIGNED NOT NULL,
Crs_Title 	VARCHAR(255) NOT NULL,
Crs_Enrollment INT UNSIGNED,
PRIMARY KEY (Crs_code));


INSERT INTO Course VALUES 
(100,'BSc Computer Science', 150),
(101,'BSc Computer Information Technology', 20),
(200, 'MSc Data Science', 100),
(201, 'MSc Security', 30),
(210, 'MSc Electrical Engineering', 70),
(211, 'BSc Physics', 100);


-- This is the student table definition


DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
URN INT UNSIGNED NOT NULL,
Stu_FName 	VARCHAR(255) NOT NULL,
Stu_LName 	VARCHAR(255) NOT NULL,
Stu_DOB 	DATE,
Stu_Phone 	VARCHAR(12),
Stu_Course	INT UNSIGNED NOT NULL,
Stu_Type 	ENUM('UG', 'PG'),
PRIMARY KEY (URN),
FOREIGN KEY (Stu_Course) REFERENCES Course (Crs_Code)
ON DELETE RESTRICT);


INSERT INTO Student VALUES
(612345, 'Sara', 'Khan', '2002-06-20', '01483112233', 100, 'UG'),
(612346, 'Pierre', 'Gervais', '2002-03-12', '01483223344', 100, 'UG'),
(612347, 'Patrick', 'O-Hara', '2001-05-03', '01483334455', 100, 'UG'),
(612348, 'Iyabo', 'Ogunsola', '2002-04-21', '01483445566', 100, 'UG'),
(612349, 'Omar', 'Sharif', '2001-12-29', '01483778899', 100, 'UG'),
(612350, 'Yunli', 'Guo', '2002-06-07', '01483123456', 100, 'UG'),
(612351, 'Costas', 'Spiliotis', '2002-07-02', '01483234567', 100, 'UG'),
(612352, 'Tom', 'Jones', '2001-10-24',  '01483456789', 101, 'UG'),
(612353, 'Simon', 'Larson', '2002-08-23', '01483998877', 101, 'UG'),
(612354, 'Sue', 'Smith', '2002-05-16', '01483776655', 101, 'UG');

DROP TABLE IF EXISTS Undergraduate;

CREATE TABLE Undergraduate (
UG_URN 	INT UNSIGNED NOT NULL,
UG_Credits   INT NOT NULL,
CHECK (60 <= UG_Credits <= 150),
PRIMARY KEY (UG_URN),
FOREIGN KEY (UG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);

INSERT INTO Undergraduate VALUES
(612345, 120),
(612346, 90),
(612347, 150),
(612348, 120),
(612349, 120),
(612350, 60),
(612351, 60),
(612352, 90),
(612353, 120),
(612354, 90);

DROP TABLE IF EXISTS Postgraduate;

CREATE TABLE Postgraduate (
PG_URN 	INT UNSIGNED NOT NULL,
Thesis  VARCHAR(512) NOT NULL,
PRIMARY KEY (PG_URN),
FOREIGN KEY (PG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);


-- Please add your table definitions below this line.......

-- This is the Hobby table definition 

DROP TABLE IF EXISTS Hobby;

CREATE TABLE Hobby (
HOBBY_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Hobby_Title VARCHAR(512) NOT NULL UNIQUE,
PRIMARY KEY (HOBBY_ID));

INSERT INTO HOBBY
VALUES(1, "Hiking"), 
(2, "Chess"), 
(3, "Taichi"),
(4, "Ballroom"),
(5, "Football"),
(6, "Tennis"),
(7, "Rugby"),
(8, "Climbing"),
(9, "Rowing");

-- This is the StudentHobby table definition

DROP TABLE IF EXISTS StudentHobby;

CREATE TABLE StudentHobby (
HOBBY_ID INT UNSIGNED NOT NULL,
URN INT UNSIGNED NOT NULL,
PRIMARY KEY (HOBBY_ID, URN),
FOREIGN KEY (HOBBY_ID) REFERENCES Hobby(HOBBY_ID) ON DELETE CASCADE,
FOREIGN KEY (URN) REFERENCES Student(URN) ON DELETE CASCADE);

INSERT INTO StudentHobby
VALUES(1, 612345), (2, 612346), (3, 612347);

-- This is the Member table definition

DROP TABLE IF EXISTS Members;

CREATE TABLE Members (
MEMBER_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
URN INT UNSIGNED NOT NULL UNIQUE,
Member_Type ENUM("Regular", "Committee" ) NOT NULL,
PRIMARY KEY (MEMBER_ID),
FOREIGN KEY (URN) REFERENCES Student(URN) ON DELETE CASCADE);

INSERT INTO Members
VALUES(1, 612345, "Regular"), (2, 612346, "Committee"), (3, 612347, "Committee"), (4, 612348, "Committee");

-- This is the Society table definition

DROP TABLE IF EXISTS Society;

CREATE TABLE Society(
SOC_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Soc_Title VARCHAR(512) UNIQUE NOT NULL,
Soc_Email VARCHAR(512) UNIQUE,
Soc_MembershipFee DECIMAL(4,2) DEFAULT 0, 
PRIMARY KEY (SOC_ID));

INSERT INTO Society
VALUES(1, "CompSoc", "ussu.computing@surrey.ac.uk", 5.50), (2, "ChessSoc", "ussu.chess@surrey.ac.uk", 7.50);

-- This is the Membership table definition

DROP TABLE IF EXISTS Membership;

CREATE TABLE Membership(
MEMBER_ID INT UNSIGNED NOT NULL,
SOC_ID INT UNSIGNED NOT NULL,
Membership_Start DATE,
Membership_Expiry DATE,  
PRIMARY KEY (MEMBER_ID, SOC_ID),
FOREIGN KEY (MEMBER_ID) REFERENCES Members(MEMBER_ID) ON DELETE CASCADE,
FOREIGN KEY (SOC_ID) REFERENCES Society(SOC_ID) ON DELETE CASCADE);

INSERT INTO Membership 
VALUES(3, 2, "2023-02-02", "2024-02-02");

-- This is the SocietyMember table definition

DROP TABLE IF EXISTS SocietyMember;

CREATE TABLE SocietyMember(
SOC_ID INT UNSIGNED NOT NULL,
MEMBER_ID INT UNSIGNED NOT NULL,
PRIMARY KEY (SOC_ID, MEMBER_ID),
FOREIGN KEY (SOC_ID) REFERENCES Society(SOC_ID) ON DELETE CASCADE,
FOREIGN KEY (MEMBER_ID) REFERENCES Members(MEMBER_ID) ON DELETE CASCADE);

INSERT INTO SocietyMember
VALUES(1, 1), (1, 2), (2, 3), (2, 4);

-- This is the Committee_Member table definition

DROP TABLE IF EXISTS Committee_Member;

CREATE TABLE Committee_Member(
MEMBER_ID INT UNSIGNED NOT NULL,
SOC_ID INT UNSIGNED NOT NULL,
Title VARCHAR(512),
Signatory BOOLEAN NOT NULL,
PRIMARY KEY (MEMBER_ID),
FOREIGN KEY (MEMBER_ID) REFERENCES Members(MEMBER_ID) ON DELETE CASCADE,
FOREIGN KEY (SOC_ID) REFERENCES Society(SOC_ID) ON DELETE CASCADE);

INSERT INTO Committee_Member 
VALUES(3, 1, "Chairman", TRUE), (2, 1, "Vice", TRUE), (4, 2, "Web Developer", FALSE);
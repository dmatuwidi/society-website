USE coursework;

-- Query 1: returns a society and how many members it has in it

SELECT Soc_Title AS 'Society', COUNT(MEMBER_ID) AS 'Memberships', SUM(Soc_MembershipFee) AS 'Membership Income'
FROM Society INNER JOIN Membership ON Society.SOC_ID = Membership.SOC_ID
GROUP BY Soc_Title
ORDER BY 'Membership Income';

-- Query 2: return undergraduate students full names and phone numbers which have chess as a hobby (for society reccomendations)

SELECT CONCAT(Stu_FName, ' ', Stu_LName) AS "Name", Stu_Phone AS 'Number', Hobby_Title AS Hobby 
FROM Student INNER JOIN StudentHobby ON Student.URN = StudentHobby.URN INNER JOIN Hobby ON StudentHobby.HOBBY_ID = Hobby.HOBBY_ID
WHERE Student.URN = (SELECT URN FROM StudentHobby WHERE Hobby_ID = (SELECT Hobby_ID FROM Hobby WHERE Hobby_Title = "Chess"))
AND Stu_Type = "UG";

-- Query 3: return list of names of society committee members and their society

SELECT CONCAT(Stu_FName, ' ', Stu_LName) AS "Name", Soc_Title AS 'Committee', IF(Signatory, 'Yes', 'No') Signatory
FROM Student INNER JOIN Members ON Student.URN = Members.URN 
INNER JOIN Committee_Member ON Members.MEMBER_ID = Committee_Member.MEMBER_ID 
INNER JOIN Society ON Committee_Member.SOC_ID = Society.SOC_ID;

-- If you want to do some more queries as the extra challenge task you can include them here
CREATE DATABASE CrimeManagement;
USE CrimeManagement;
CREATE TABLE Crime (
 CrimeID INT PRIMARY KEY,
 IncidentType VARCHAR(255),
 IncidentDate DATE,
 Location VARCHAR(255),
 Description TEXT,
 Status VARCHAR(20)
);

INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
 (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
 (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under 
Investigation'),
 (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');
 
SELECT * FROM Crime;
CREATE TABLE Victim (
 VictimID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 ContactInfo VARCHAR(255),
 Injuries VARCHAR(255),
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries)
VALUES
 (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
 (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
 (3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');
 
SELECT * FROM Victim;
 
CREATE TABLE Suspect (
 SuspectID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 Description TEXT,
 CriminalHistory TEXT,
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory)
VALUES
 (1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
 (2, 2, 'Unknown', 'Investigation ongoing', NULL),
 (3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');
 
SELECT * FROM Suspect;

/*1. Select all open incidents*/
SELECT * FROM Crime WHERE Status='Open';

/* 2. Find the total number of incidents*/
SELECT COUNT(*) AS TotalNoOfIncidents FROM Crime;

/* 3. List all unique incident types*/
SELECT DISTINCT IncidentType FROM Crime;

/* 4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'.*/
SELECT * FROM Crime WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';

/* 5. List persons involved in incidents in descending order of age */
ALTER TABLE Victim
ADD COLUMN Age INT;
UPDATE Victim SET Age = 45 WHERE VictimID = 1;
UPDATE Victim SET Age = 28 WHERE VictimID = 2;
UPDATE Victim SET Age = 29 WHERE VictimID = 3;

ALTER TABLE Suspect
ADD Age INT;
UPDATE Suspect SET Age = 35 WHERE SuspectID = 1;
UPDATE Suspect SET Age = 30 WHERE SuspectID = 2;
UPDATE Suspect SET Age = 40 WHERE SuspectID = 3;

SELECT Name,Age FROM Victim
UNION
SELECT Name,Age FROM Suspect
ORDER BY Name DESC;

/* 6. Find the average age of persons involved in incidents */
SELECT AVG(Age) AS AverageAge
FROM (SELECT Age FROM Victim UNION ALL SELECT Age FROM Suspect) AS AllAges;

/* 7. List incident types and their counts, only for open cases*/
SELECT IncidentType, COUNT(*) AS IncidentCount FROM CRIME 
WHERE Status = 'Open' GROUP BY IncidentType;

/* 8. Find persons with names containing 'Doe' */
SELECT Name FROM Victim WHERE Name like '%Doe%'
UNION 
SELECT Name FROM Suspect WHERE Name like '%Doe%';

/* 9. Retrieve the names of persons involved in open cases and closed cases*/
SELECT Name FROM Victim WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Open')
UNION
SELECT Name FROM Suspect WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Open')
UNION
SELECT Name FROM Victim WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Closed')
UNION
SELECT Name FROM Suspect WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Closed');

/* 10. List incident types where there are persons aged 30 or 35 involved*/
SELECT DISTINCT C.IncidentType FROM Crime C
JOIN (SELECT CrimeID FROM Victim WHERE Age = 30 UNION SELECT CrimeID FROM Suspect WHERE Age = 30 UNION 
SELECT CrimeID FROM Victim WHERE Age = 35 UNION SELECT CrimeID FROM Suspect WHERE Age = 35) AS Incidents ON C.CrimeID = Incidents.CrimeID;
 
 /* 11. Find persons involved in incidents of the same type as 'Robbery'*/
SELECT Name FROM Victim
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery')
UNION
SELECT Name FROM Suspect
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery');

/* 12. List incident types with more than one open case*/
SELECT IncidentType FROM Crime WHERE Status = 'Open' GROUP BY IncidentType HAVING COUNT(*) > 1; 

/* 13. List all incidents with suspects whose names also appear as victims in other incidents*/
SELECT * FROM Crime
WHERE CrimeID IN 
(SELECT CrimeID FROM Suspect WHERE Name IN (SELECT Name FROM Victim));

/* 14. Retrieve all incidents along with victim and suspect details*/
SELECT C.*, V.Name AS VictimName, V.ContactInfo, V.Injuries, S.Name AS SuspectName, S.Description AS SuspectDescription, S.CriminalHistory
FROM Crime C
LEFT JOIN Victim V ON C.CrimeID = V.CrimeID
LEFT JOIN Suspect S ON C.CrimeID = S.CrimeID;

/* 15. Find incidents where the suspect is older than any victim */
SELECT C.IncidentType FROM Crime C
JOIN (SELECT CrimeID FROM Suspect WHERE Age > ANY (SELECT Age FROM Victim WHERE Victim.CrimeID = Suspect.CrimeID)) 
AS OlderSuspects ON C.CrimeID = OlderSuspects.CrimeID;

/* 16. Find suspects involved in multiple incidents*/
SELECT Name FROM Suspect GROUP BY Name
HAVING COUNT(CrimeID) > 1;

/* 17. List incidents with no suspects involved */
SELECT * FROM Crime
WHERE CrimeID NOT IN (SELECT CrimeID FROM Suspect);

/* 18. List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'*/
SELECT * FROM Crime
WHERE IncidentType = 'Homicide'
AND NOT EXISTS (SELECT * FROM Crime WHERE IncidentType != 'Robbery' AND CrimeID = Crime.CrimeID);

/* 19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none*/
SELECT c.*, COALESCE(s.Name, 'No Suspect') AS SuspectName
FROM Crime c LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;

/* 20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'*/
SELECT DISTINCT s.SuspectID, s.Name
FROM Suspect s JOIN Crime c ON s.CrimeID = c.CrimeID WHERE c.IncidentType IN ('Robbery', 'Assault');


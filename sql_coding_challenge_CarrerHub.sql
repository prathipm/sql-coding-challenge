create database if not exists CarrerHub;

use CarrerHub;

create table if not exists Companies(
CompanyID int primary key,
CompanyName varchar(255),
Location varchar(255)
);

insert into Companies values(1001, 'Hexaware', 'Chennai'),
(1002, 'TCS', 'Banglore'),
(1003, 'Accenture', 'Hyderbad');

create table if not exists Jobs(
JobID int primary key,
CompanyID int,
JobTitle varchar(255),
JobDescription text,
JobLocation varchar(255),
Salary decimal(10,2),
JobType varchar(255),
PostedDate datetime,
foreign key(CompanyID) references Companies(CompanyID)
);

insert into Jobs
values(101, 1001, 'Software Engineer', 'Developing software applications', 'Chennai', 60000.00, 'Full-time', '2024-01-15 09:00:00'),
       (102, 1002, 'Data Analyst', 'Analyzing data for business insights', 'Banglore', 70000.00, 'Full-time', '2024-01-24 10:30:00'),
       (103, 1003, 'Web Developer', 'Building websites and web applications', 'Hyderabad', 65000.00, 'Full-time', '2024-02-28 11:45:00');
       insert into Jobs values(104,1001,'Web Developer','Building websites and web applications','Chennai','75000.00','Full-time','2024-02-02 9:30:23');

create table if not exists Applicants(
ApplicantID int primary key,
FirstName varchar(255),
LastName varchar(255),
Email varchar(255),
Phone varchar(30),
Resume text
);

insert into Applicants
values(501, 'Ajith', 'Kumar', 'ajith123@example.com', '9854267845', 'Resume_Ajith Kumar.pdf'),
       (502, 'Rahul', 'Sharma', 'rahul246@example.com', '8664356780', 'Rahul Sharma_Resume.pdf'),
       (503,'Priya','Ravi','pr2468@example.com','7456238941','Reumse_priya.pdf'),
       (504,'Karan','Praveen','kp122@example.com','9456896034', 'Karan_Resume.pdf');

insert into Applicants
values(505,'Ajay','Kanna','ajay102@example.com','9734568720','ajay_resume.pdf');

alter table Applicants
add YearsOfExperience int;
update Applicants set YearsOfExperience=4 where ApplicantID=505;

select * from Applicants;
       
create table if not exists Applications(
ApplicationID int primary key,
JobID int,
ApplicantID int,
ApplicationDate datetime,
CoverLetter text,
foreign key (JobID) references Jobs(JobID),
foreign key (ApplicantID) references Applicants(ApplicantID)
);

insert into Applications
values(1, 101, 501, '2024-01-20 09:30:45', 'Cover letter for Software Engineer position'),
       (2, 102, 502, '2024-01-26 10:30:05', 'Cover letter for Data Analyst position'),
       (3, 103, 503, '2024-02-29 09:30:23', 'Cover letter for Web Developer position'),
       (4,101,504,'2024-01-23 08:45:00','Cover letter for Software Engineer position'),
       (5,103,505,'2024-03-01 10:20:45','Cover letter for Web Developer position');

select * from Applications;

select Jobs.JobTitle,count(Applications.ApplicationID) as Application_Count
from Jobs
left join Applications ON Jobs.JobID = Applications.JobID
group by Jobs.JobID;

-- Task 6: SQL query to retrieve job listings within a specified salary range
select JobTitle, CompanyName, JobLocation, Salary
from Jobs
join Companies on Jobs.CompanyID = Companies.CompanyID
where Salary between 60000 and 80000;

-- Task 7: SQL query to retrieve job application history for a specific applicant
select Jobs.JobTitle, Companies.CompanyName, Applications.ApplicationDate
from Applications
join Jobs on Applications.JobID = Jobs.JobID
join Companies on Jobs.CompanyID = Companies.CompanyID
where Applications.ApplicantID = 502;

-- Task 8: SQL query to calculate and display the average salary offered by all companies for job listings
select avg(Salary) as Average_Salary
from Jobs
where Salary > 0;

-- Task 9: SQL query to identify the company that has posted the most job listings
select CompanyName from Companies where(select count(*) as c from Jobs group by CompanyID
order by c DESC limit 1)
limit 1;

-- Task 10: SQL query to find applicants who have applied for positions in 'CityX' and have at least 3 years of experience
SELECT * FROM Applicants
WHERE ApplicantID IN (SELECT A.ApplicantID FROM Applications A
    JOIN Jobs J ON A.JobID = J.JobID
    JOIN Companies C ON J.CompanyID = C.CompanyID
    WHERE C.Location = 'Chennai' GROUP BY A.ApplicantID
    HAVING SUM(YearsOfExperience) >= 3
);

-- Task 11: SQL query to retrieve a list of distinct job titles with salaries between $60,000 and $80,000
select distinct JobTitle
from Jobs
where Salary between 60000 and 80000;

-- Task 12: SQL query to find jobs that have not received any applications
select * from Jobs
where JobID not in(select distinct JobID from Applications);

-- Task 13: SQL query to retrieve a list of job applicants along with the companies they have applied to and the positions they have applied for
select Applicants.FirstName, Applicants.LastName, Companies.CompanyName, Jobs.JobTitle
from Applicants
left join Applications on Applicants.ApplicantID = Applications.ApplicantID
left join Jobs on Applications.JobID = Jobs.JobID
left join Companies on Jobs.CompanyID = Companies.CompanyID;

-- Task 14: SQL query to retrieve a list of companies along with the count of jobs they have posted, even if they have not received any applications
select Companies.CompanyName,count(Jobs.JobID)as JobCount
from Companies
left join Jobs on Companies.CompanyID = Jobs.CompanyID
group by Companies.CompanyID;

-- Task 15: SQL query to list all applicants along with the companies and positions they have applied for, including those who have not applied
select Applicants.ApplicantID, Applicants.FirstName, Applicants.LastName, 
(select Companies.CompanyName from Companies) as CompanyName,
(select Jobs.JobTitle from Jobs) as JobTitle
from Applicants;

-- Task 16: SQL query to find companies that have posted jobs with a salary higher than the average salary of all jobs
select cmp.CompanyName 
from Companies cmp
join Jobs J on cmp.CompanyID = J.CompanyID
where J.Salary > (select avg(Salary) from Jobs where Salary > 0);

-- Task 17: SQL query to display a list of applicants with their names and a concatenated string of their city and state
-- Assuming location is stored as 'City, State' in the Companies table
alter table Applicants
add City varchar(100),
add State varchar(100);
update Applicants set City='Mysore',State='Karnataka' where ApplicantID=505;

select concat(FirstName,' ',LastName)as Name,
concat(City,' - ',State)as Location from Applicants;

-- Task 18: SQL query to retrieve a list of jobs with titles containing either 'Developer' or 'Engineer'
select * from Jobs
where JobTitle like '%Developer%' or JobTitle like '%Engineer%';

-- Task 19: SQL query to retrieve a list of applicants and the jobs they have applied for, including those who have not applied and jobs without applicants
select ApplicantID,FirstName,LastName,(select JobID 
from Applications 
where Applications.ApplicantID = Applicants.ApplicantID limit 1) as JobID,
(select JobTitle from Applications 
join Jobs on Applications.JobID = Jobs.JobID
where Applications.ApplicantID = Applicants.ApplicantID limit 1) as JobTitle
from Applicants;

-- Task 20: SQL query to find all combinations of applicants and companies where the company is in a specific city and the applicant has more than 2 years of experience
-- For example: city = 'Chennai'
select *, (select CompanyName from Companies where Location = 'Chennai')as Companies
from Applicants
where YearsOfExperience > 2;
-- Database: lifeinsurance

--DROP DATABASE IF EXISTS lifeinsurance;

-- CREATE DATABASE lifeinsurance
--     WITH
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'English_India.1252'
--     LC_CTYPE = 'English_India.1252'
--     LOCALE_PROVIDER = 'libc'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1
--     IS_TEMPLATE = False;

-- ======================================
--  TABLE CREATION
-- ======================================

--  Customer Table
CREATE TABLE customers (
    Customer_ID VARCHAR(10) PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female')),
    DOB DATE NOT NULL,
    Email VARCHAR(100)  NOT NULL,
    Phone VARCHAR(15)  NOT NULL,
    Address TEXT NOT NULL,
    City VARCHAR(50) NOT NULL,
    Zip_Code VARCHAR(10) NOT NULL,
    Occupation VARCHAR(100),
    Annual_Income NUMERIC(10,2) CHECK (Annual_Income >= 50000),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


--  Agents Table

CREATE TABLE agents (
    Agent_ID VARCHAR(10) PRIMARY KEY,  
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100)  NOT NULL,
    Phone VARCHAR(15)  NOT NULL,
    Joining_Date DATE NOT NULL,
    Status VARCHAR(10) CHECK (Status IN ('Active', 'Inactive')),
    Commission_Rate NUMERIC(5,2) CHECK (Commission_Rate BETWEEN 0.5 AND 10)
);

--  Branch Table
CREATE TABLE branches (
    Branch_ID VARCHAR(10) PRIMARY KEY,
    Branch_Name VARCHAR(100) NOT NULL,
    Address TEXT NOT NULL,
    City VARCHAR(50) NOT NULL,
    Zip_Code VARCHAR(10) NOT NULL
);


-- Relationship Manager Table
CREATE TABLE bank_rms (
    RM_ID VARCHAR(10) PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100)  NOT NULL,
    Phone VARCHAR(15)  NOT NULL,
    Joining_Date DATE NOT NULL,
    Status VARCHAR(10) CHECK (Status IN ('Active', 'Inactive')),
    Branch_ID VARCHAR(10) REFERENCES branches(Branch_ID) ON DELETE CASCADE
);


--  Policy Types Table
CREATE TABLE policy_types (
    PolicyType_ID VARCHAR(15) PRIMARY KEY,
    Type_Name VARCHAR(100)  NOT NULL,
    Description TEXT NOT NULL,
    Min_Term_Year INT CHECK (Min_Term_Year > 0),
    Max_Term_Year INT CHECK (Max_Term_Year >= Min_Term_Year),
    Min_Sum_Assured NUMERIC(12,2) CHECK (Min_Sum_Assured >= 1),
    Max_Sum_Assured NUMERIC(12,2) CHECK (Max_Sum_Assured >= Min_Sum_Assured)
);

-- drop table policy_types

-- Applications Table
CREATE TABLE applications (
    Application_ID VARCHAR(15) PRIMARY KEY,
    Customer_ID VARCHAR(10) REFERENCES customers(Customer_ID) ON DELETE CASCADE,
    PolicyType_ID VARCHAR(10) REFERENCES policy_types(PolicyType_ID) ON DELETE CASCADE,
    Application_Date DATE NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Approved', 'Pending', 'Rejected')),
    Sum_Assured NUMERIC(12,2) NOT NULL CHECK (Sum_Assured >= 1),
    Premium_Amount NUMERIC(10,2) NOT NULL,
    Premium_Frequency VARCHAR(15) CHECK (Premium_Frequency IN ('Monthly', 'Quarterly', 'Semi-Annually', 'Annually')),
    Term_Years INT CHECK (Term_Years > 0),
    Payment_Method VARCHAR(15) CHECK (Payment_Method IN ('Auto Pay', 'Non Auto Pay')),
    Marital_Status VARCHAR(15) CHECK (Marital_Status IN ('Married', 'Unmarried', 'Divorced'))
);


--  Application Source Table
CREATE TABLE application_sources (
    Source_ID VARCHAR(15) PRIMARY KEY,
    Application_ID VARCHAR(15) REFERENCES applications(Application_ID) ON DELETE CASCADE,
    Source_Type VARCHAR(10) CHECK (Source_Type IN ('Web', 'Agent', 'Bank'))
);


--  Application-Agent Table (Many-to-Many)
CREATE TABLE application_agents (
    App_Agent_ID VARCHAR(15) PRIMARY KEY,
    Application_ID VARCHAR(15) REFERENCES applications(Application_ID) ON DELETE CASCADE,
    Agent_ID VARCHAR(15) REFERENCES agents(Agent_ID) ON DELETE CASCADE
);


--  Application-BankRM Table (Many-to-Many)
CREATE TABLE application_bankrms (
    App_BankRM_ID VARCHAR(15) PRIMARY KEY,
    Application_ID VARCHAR(15) REFERENCES applications(Application_ID) ON DELETE CASCADE,
    RM_ID VARCHAR(15) REFERENCES bank_rms(RM_ID) ON DELETE CASCADE
);

-- Status Code Table
CREATE TABLE status_codes (
    Status_Code VARCHAR(2) PRIMARY KEY,
    Description VARCHAR(100) NOT NULL
);



--  Policies Table
CREATE TABLE policies (
    Policy_Number VARCHAR(15) PRIMARY KEY,
    Application_ID VARCHAR(15) REFERENCES applications(Application_ID) ON DELETE CASCADE,
    Status_Code VARCHAR(2) REFERENCES status_codes(Status_Code) ON DELETE SET NULL,
    Issue_Date DATE NOT NULL,
    Maturity_Date DATE NOT NULL CHECK (Maturity_Date > Issue_Date),
    Premium_Amount NUMERIC(10,2) NOT NULL
);

--  Policies Inactive Table
CREATE TABLE policies_inactive (
    Inactive_ID VARCHAR(15) PRIMARY KEY,
    Policy_Number VARCHAR(15) REFERENCES policies(Policy_Number) ON DELETE CASCADE,
    Status_Code VARCHAR(2) REFERENCES status_codes(Status_Code) ON DELETE SET NULL,
    Status_Change_Date DATE
);

--  Premium Schedule Table
CREATE TABLE premium_schedules (
    Policy_Number VARCHAR(15),
    Due_Date DATE NOT NULL,
    Amount NUMERIC(10,2) NOT NULL,
    Status VARCHAR(15) CHECK (Status IN ('Due', 'Paid', 'Overdue')),
    Grace_Period_Days INT CHECK (Grace_Period_Days IN (3,30)),
    PRIMARY KEY (Policy_Number, Due_Date),
    FOREIGN KEY (Policy_Number) REFERENCES policies(Policy_Number) ON DELETE CASCADE
);



--  Premium Payment Table
CREATE TABLE premium_payments (
    Transaction_ID VARCHAR(15) PRIMARY KEY,
    Policy_Number VARCHAR(15) REFERENCES policies(Policy_Number) ON DELETE CASCADE,
    Payment_Date DATE NOT NULL,
    Amount NUMERIC(10,2) NOT NULL,
    Status VARCHAR(15) CHECK (Status IN ('Success', 'Pending'))
);

--  Auto Pay Table (Specialization)
CREATE TABLE auto_payments (
    Transaction_ID VARCHAR(15) PRIMARY KEY REFERENCES premium_payments(Transaction_ID) ON DELETE CASCADE
);

--  Non Auto Pay Table (Specialization)
CREATE TABLE non_auto_payments (
    Transaction_ID VARCHAR(15) PRIMARY KEY REFERENCES premium_payments(Transaction_ID) ON DELETE CASCADE
);


--  Communication Log Table
CREATE TABLE communication_logs (
    Log_ID VARCHAR(15) PRIMARY KEY,
    Policy_Number VARCHAR(15) REFERENCES policies(Policy_Number) ON DELETE CASCADE,
    Communication_Type VARCHAR(10) CHECK (Communication_Type IN ('Email', 'SMS', 'Call')),
    Sent_Date DATE NOT NULL,
    Message_Type VARCHAR(20) CHECK (Message_Type IN ('Reminder', 'Warning'))
);


--  Lapsation Record Table
CREATE TABLE lapsation_records (
    Lapsation_ID VARCHAR(15) PRIMARY KEY,
    Policy_Number VARCHAR(15) REFERENCES policies(Policy_Number) ON DELETE CASCADE,
    Lapsation_Date DATE NOT NULL,
    Reason VARCHAR(200),
    Days_Overdue INT CHECK (Days_Overdue >= 30),
    Amount_Due NUMERIC(10,2) CHECK (Amount_Due >= 100),
    Reinstatement_Eligibility VARCHAR(3) CHECK (Reinstatement_Eligibility IN ('Yes', 'No'))
);


--  Reinstatement Table
CREATE TABLE reinstatements (
    Reinstatement_ID VARCHAR(15) PRIMARY KEY,
    Lapsation_ID VARCHAR(15) REFERENCES lapsation_records(Lapsation_ID) ON DELETE CASCADE,
    Request_Date DATE NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Pending', 'Approved', 'Rejected')),
    Approved_Date DATE
);







	
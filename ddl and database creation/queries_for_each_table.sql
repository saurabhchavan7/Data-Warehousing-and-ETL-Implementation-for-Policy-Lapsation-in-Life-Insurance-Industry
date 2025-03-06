SELECT * FROM customers;

SELECT Agent_ID, First_Name, Last_Name, Status, Commission_Rate 
FROM agents 
WHERE Status = 'Active' 
ORDER BY Commission_Rate DESC;

SELECT RM_ID, First_Name, Last_Name, Status, Branch_ID 
FROM bank_rms 
WHERE Status = 'Inactive';

SELECT * FROM branches;

SELECT Type_Name, Min_Term_Year, Max_Term_Year, Min_Sum_Assured, Max_Sum_Assured 
FROM policy_types 
WHERE Min_Term_Year < 15;


SELECT Application_ID, Customer_ID, Status, Sum_Assured, Premium_Amount 
FROM applications 
WHERE Status = 'Approved' 
ORDER BY Sum_Assured DESC;


SELECT Source_Type, COUNT(*) AS Total_Applications 
FROM application_sources 
GROUP BY Source_Type;


SELECT aa.Application_ID, a.First_Name, a.Last_Name 
FROM application_agents aa 
JOIN agents a ON aa.Agent_ID = a.Agent_ID;


SELECT *
FROM application_bankrms 









SELECT * FROM status_codes;





SELECT Policy_Number, Application_ID, Issue_Date, Maturity_Date, Premium_Amount 
FROM policies 
WHERE Issue_Date >= '2023-01-01' 
ORDER BY Issue_Date DESC 
LIMIT 10;
SELECT pi.Policy_Number, s.Description, pi.Status_Change_Date 
FROM policies_inactive pi 
JOIN status_codes s ON pi.Status_Code = s.Status_Code 
ORDER BY Status_Change_Date DESC 
LIMIT 10;

SELECT Policy_Number, Due_Date, Amount, Status 
FROM premium_schedules 


SELECT Policy_Number, COUNT(Transaction_ID) AS Total_Payments, SUM(Amount) AS Total_Amount 
FROM premium_payments 
GROUP BY Policy_Number 
ORDER BY Total_Amount DESC 
LIMIT 10;

SELECT ap.Transaction_ID, pp.Policy_Number, pp.Payment_Date, pp.Amount 
FROM auto_payments ap 
JOIN premium_payments pp ON ap.Transaction_ID = pp.Transaction_ID 
ORDER BY pp.Payment_Date DESC 
LIMIT 10;


SELECT np.Transaction_ID, pp.Policy_Number, pp.Payment_Date, pp.Amount 
FROM non_auto_payments np 
JOIN premium_payments pp ON np.Transaction_ID = pp.Transaction_ID 
ORDER BY pp.Payment_Date DESC 
LIMIT 10;


SELECT Policy_Number, Communication_Type, Sent_Date, Message_Type 
FROM communication_logs 
WHERE Sent_Date >= CURRENT_DATE - INTERVAL '30 days';


SELECT lr.Policy_Number, lr.Lapsation_Date, lr.Reason, lr.Days_Overdue, lr.Amount_Due 
FROM lapsation_records lr 
ORDER BY lr.Lapsation_Date DESC 
LIMIT 10;

SELECT r.Reinstatement_ID, r.Lapsation_ID, lr.Policy_Number, r.Request_Date, r.Status, r.Approved_Date 
FROM reinstatements r 
JOIN lapsation_records lr ON r.Lapsation_ID = lr.Lapsation_ID 
WHERE r.Status = 'Approved' 
ORDER BY r.Approved_Date DESC 
LIMIT 10;

select * from customers;


select * from application_agents




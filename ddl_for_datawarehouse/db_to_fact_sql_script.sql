
    with test as (select
    
        c.Customer_ID AS customer_id,
        p.Policy_Number AS policy_number,
        a.Agent_ID AS agent_id,
        br.Branch_ID AS branch_id,
        p.Issue_Date AS policy_issue_date,
        lr.Lapsation_Date AS lapsation_date,
        CASE 
            WHEN p.Status_Code = '02' THEN TRUE 
            ELSE FALSE 
        END AS lapsation_flag,
        CAST(DATE_PART('year', AGE(p.Issue_Date, c.DOB)) AS INT) AS policy_age,
        CASE 
            WHEN a.Status = 'Active' AND p.Status_Code != '2' THEN 90
            WHEN a.Status = 'Active' AND p.Status_Code = '2' THEN 60
            WHEN a.Status = 'Inactive' AND p.Status_Code != '2' THEN 50
            ELSE 30
        END AS agent_performance_score
    FROM policies p
    INNER JOIN applications app ON p.Application_ID = app.Application_ID
    INNER JOIN customers c ON app.Customer_ID = c.Customer_ID
    LEFT JOIN application_agents aa ON aa.Application_ID = app.Application_ID
    LEFT JOIN agents a ON aa.Agent_ID = a.Agent_ID
    LEFT JOIN application_bankrms abrm ON abrm.Application_ID = app.Application_ID
    LEFT JOIN bank_rms rm ON abrm.RM_ID = rm.RM_ID
    LEFT JOIN branches br ON rm.Branch_ID = br.Branch_ID
    LEFT JOIN lapsation_records lr ON p.Policy_Number = lr.Policy_Number)
    
    select * from test where lapsation_flag = true
    
-----------------------
    
   SELECT 
    pp.Policy_Number AS policy_number,
    pp.Transaction_ID AS transaction_id,
    pp.Payment_Date,
    pp.Amount AS amount_paid,
    CASE 
        WHEN ap.Transaction_ID IS NOT NULL THEN TRUE
        WHEN nap.Transaction_ID IS NOT NULL THEN FALSE
        ELSE NULL
    END AS autopay_flag,
    SUM(pp.Amount) OVER (PARTITION BY pp.Policy_Number ORDER BY pp.Payment_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_amount
FROM premium_payments pp
LEFT JOIN auto_payments ap ON pp.Transaction_ID = ap.Transaction_ID
LEFT JOIN non_auto_payments nap ON pp.Transaction_ID = nap.Transaction_ID
WHERE pp.Status = 'Success';




SELECT table_name, row_count
FROM (
    SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers UNION ALL
    SELECT 'agents', COUNT(*) FROM agents UNION ALL
    SELECT 'bank_rms', COUNT(*) FROM bank_rms UNION ALL
    SELECT 'branches', COUNT(*) FROM branches UNION ALL
    SELECT 'policy_types', COUNT(*) FROM policy_types UNION ALL
    SELECT 'applications', COUNT(*) FROM applications UNION ALL
    SELECT 'application_sources', COUNT(*) FROM application_sources UNION ALL
    SELECT 'application_agents', COUNT(*) FROM application_agents UNION ALL
    SELECT 'application_bankrms', COUNT(*) FROM application_bankrms UNION ALL
    SELECT 'status_codes', COUNT(*) FROM status_codes UNION ALL
    SELECT 'policies', COUNT(*) FROM policies UNION ALL
    SELECT 'policies_inactive', COUNT(*) FROM policies_inactive UNION ALL
    SELECT 'premium_schedules', COUNT(*) FROM premium_schedules UNION ALL
    SELECT 'premium_payments', COUNT(*) FROM premium_payments UNION ALL
    SELECT 'auto_payments', COUNT(*) FROM auto_payments UNION ALL
    SELECT 'non_auto_payments', COUNT(*) FROM non_auto_payments UNION ALL
    SELECT 'communication_logs', COUNT(*) FROM communication_logs UNION ALL
    SELECT 'lapsation_records', COUNT(*) FROM lapsation_records UNION ALL
    SELECT 'reinstatements', COUNT(*) FROM reinstatements
) AS counts
ORDER BY row_count DESC;

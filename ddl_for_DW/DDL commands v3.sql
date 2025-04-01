DROP DATABASE IF EXISTS lifeinsurance_dw;
-- CREATE DATABASE lifeinsurance_dw;

-- =========================
-- DIMENSION TABLES
-- =========================

-- Country-State-City Hierarchy
CREATE TABLE dim_country (
    country_key SERIAL PRIMARY KEY,
    country_name VARCHAR(50)
);

CREATE TABLE dim_state (
    state_id SERIAL PRIMARY KEY,
    state_name VARCHAR(50),
    country_key INT REFERENCES dim_country(country_key) ON DELETE CASCADE
);

CREATE TABLE dim_city (
    city_key SERIAL PRIMARY KEY,
    city_name VARCHAR(50),
    state_id INT REFERENCES dim_state(state_id) ON DELETE CASCADE
);

-- Customers (SCD Type 2)
CREATE TABLE dim_customers (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(10) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    occupation VARCHAR(100),
    marital_status VARCHAR(15) CHECK (marital_status IN ('Married', 'Unmarried', 'Divorced')),
    age_group VARCHAR(15),
    zip_code VARCHAR(10),
    city_name VARCHAR(50),
    effective_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_end_date TIMESTAMP DEFAULT NULL,
    is_current BOOLEAN DEFAULT TRUE
);

-- Branches
CREATE TABLE dim_branches (
    branch_key SERIAL PRIMARY KEY,
    branch_name VARCHAR(100),
    zip_code VARCHAR(10),
    branch_id VARCHAR(10) UNIQUE,
    city_name VARCHAR(50)
);

-- Agents (SCD Type 2)
CREATE TABLE dim_agents (
    agent_key SERIAL PRIMARY KEY,
    agent_id VARCHAR(10) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    status_name VARCHAR(15) CHECK (status_name IN ('Active', 'Inactive')),
    effective_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_end_date TIMESTAMP DEFAULT NULL,
    is_current BOOLEAN DEFAULT TRUE
);

-- Policy Type
CREATE TABLE dim_policy_type (
    policy_type_id VARCHAR(15) PRIMARY KEY,
    policy_type_name VARCHAR(100)
);

-- Policies (SCD Type 2)
CREATE TABLE dim_policies (
    policy_number VARCHAR(15) UNIQUE,
    status_code VARCHAR(2),
    premium_frequency VARCHAR(15) CHECK (premium_frequency IN ('Monthly', 'Quarterly', 'Semi-Annually', 'Annually')),
    policy_type_id VARCHAR(15) REFERENCES dim_policy_type(policy_type_id) ON DELETE CASCADE,
    reinstatement_flag BOOLEAN DEFAULT FALSE,
    effective_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_end_date TIMESTAMP DEFAULT NULL,
    is_current BOOLEAN DEFAULT TRUE
);

alter table dim_policies 
add column policy_key serial primary key;

-- Payment Methods
CREATE TABLE dim_payment_methods (
    payment_method_key SERIAL PRIMARY KEY,
    transaction_id VARCHAR(20) UNIQUE,
    autopay_flag BOOLEAN
);

-- Time Dimension
CREATE TABLE dim_time (
    time_key SERIAL PRIMARY KEY,
    date DATE UNIQUE,
    day_nb_month INT,
    day_nb_year INT,
    month_number INT,
    month_name VARCHAR(15),
    quarter INT,
    year INT
);

-- =========================
-- FACT TABLES
-- =========================

-- Policy Payments Fact
CREATE TABLE fact_policy_payments (
    policy_number VARCHAR(15) REFERENCES dim_policies(policy_number) ON DELETE CASCADE,
    payment_method_key INT REFERENCES dim_payment_methods(payment_method_key) ON DELETE CASCADE,
    payment_date_key INT REFERENCES dim_time(time_key) ON DELETE CASCADE,
    amount_paid NUMERIC(10,2),
    autopay_flag BOOLEAN DEFAULT FALSE,
    cumulative_amount NUMERIC(12,2)
);

ALTER TABLE fact_policy_payments 
DROP COLUMN policy_number;

ALTER TABLE fact_policy_payments
ADD COLUMN policy_key INT REFERENCES dim_policies(policy_key) ON DELETE CASCADE;

-- Policy Status Lifecycle Fact
CREATE TABLE fact_policy_status_lifecycle (
    fact_lifecycle_key SERIAL PRIMARY KEY,
    customer_key INT REFERENCES dim_customers(customer_key) ON DELETE CASCADE,
    policy_number VARCHAR(15) REFERENCES dim_policies(policy_number) ON DELETE CASCADE,
    agent_key INT REFERENCES dim_agents(agent_key) ON DELETE CASCADE,
    branch_key INT REFERENCES dim_branches(branch_key) ON DELETE CASCADE,
    policy_issue_date_key INT REFERENCES dim_time(time_key) ON DELETE CASCADE,
    lapsation_date_key INT REFERENCES dim_time(time_key) ON DELETE CASCADE,
    reinstatement_date_key INT REFERENCES dim_time(time_key) ON DELETE CASCADE,
    lapsation_flag BOOLEAN DEFAULT FALSE,
    policy_age INT,
    agent_performance_score INT
);

ALTER TABLE fact_policy_status_lifecycle
DROP COLUMN policy_number;

ALTER TABLE fact_policy_status_lifecycle
ADD COLUMN policy_key INT REFERENCES dim_policies(policy_key) ON DELETE CASCADE;

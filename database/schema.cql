
CREATE KEYSPACE IF NOT EXISTS cloudpulse
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
};

USE cloudpulse;

CREATE TABLE IF NOT EXISTS organizations (
    org_id UUID PRIMARY KEY,
    name TEXT
);

CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY,
    org_id UUID,
    name TEXT,
    email TEXT,
    role TEXT,
    password_hash TEXT
);

CREATE INDEX IF NOT EXISTS users_email_idx ON users (email);

CREATE TABLE IF NOT EXISTS server_groups (
    group_id UUID PRIMARY KEY,
    org_id UUID,
    name TEXT
);

CREATE TABLE IF NOT EXISTS servers_by_org (
    org_id UUID,
    server_id UUID,
    group_id UUID,
    group_name TEXT,
    hostname TEXT,
    ip_address INET,
    os TEXT,
    status TEXT,
    registered_at TIMESTAMP,
    PRIMARY KEY (org_id, server_id)
);

CREATE TABLE IF NOT EXISTS metric_definitions (
    metric_id TEXT PRIMARY KEY,
    unit TEXT,
    type TEXT
);

CREATE TABLE IF NOT EXISTS metrics_by_server_bucket (
    server_id UUID,
    bucket_date DATE,
    metric_name TEXT,
    recorded_at TIMESTAMP,
    value DOUBLE,
    PRIMARY KEY ((server_id, bucket_date), metric_name, recorded_at)
) WITH CLUSTERING ORDER BY (metric_name ASC, recorded_at DESC);

CREATE TABLE IF NOT EXISTS latest_metric_by_server (
    server_id UUID,
    metric_name TEXT,
    recorded_at TIMESTAMP,
    value DOUBLE,
    PRIMARY KEY (server_id, metric_name)
);

CREATE TABLE IF NOT EXISTS alert_rules (
    rule_id UUID PRIMARY KEY,
    org_id UUID,
    name TEXT,
    metric_name TEXT,
    operator TEXT,
    threshold DOUBLE,
    severity TEXT,
    enabled BOOLEAN
);

CREATE TABLE IF NOT EXISTS alert_events_by_server (
    server_id UUID,
    event_time TIMESTAMP,
    event_id UUID,
    rule_id UUID,
    rule_name TEXT,
    severity TEXT,
    message TEXT,
    status TEXT,
    PRIMARY KEY (server_id, event_time, event_id)
) WITH CLUSTERING ORDER BY (event_time DESC, event_id ASC);

CREATE TABLE IF NOT EXISTS alert_events_by_rule (
    rule_id UUID,
    event_time TIMESTAMP,
    event_id UUID,
    server_id UUID,
    severity TEXT,
    message TEXT,
    status TEXT,
    PRIMARY KEY (rule_id, event_time, event_id)
) WITH CLUSTERING ORDER BY (event_time DESC, event_id ASC);

CREATE TABLE IF NOT EXISTS logs_by_server_bucket (
    server_id UUID,
    bucket_date DATE,
    log_time TIMESTAMP,
    log_id UUID,
    level TEXT,
    message TEXT,
    source TEXT,
    PRIMARY KEY ((server_id, bucket_date), log_time, log_id)
) WITH CLUSTERING ORDER BY (log_time DESC, log_id ASC);

CREATE TABLE IF NOT EXISTS audit_logs (
    org_id UUID,
    event_time TIMESTAMP,
    audit_id UUID,
    user_id UUID,
    action TEXT,
    entity_type TEXT,
    entity_id TEXT,
    details TEXT,
    PRIMARY KEY ((org_id), event_time, audit_id)
) WITH CLUSTERING ORDER BY (event_time DESC, audit_id ASC);

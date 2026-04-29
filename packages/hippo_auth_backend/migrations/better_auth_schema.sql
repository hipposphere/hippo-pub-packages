-- better-auth-diesel-sqlite schema used by dart_edge_auth.
-- Keep this file in sync with the Better Auth migration bundled by dart_edge_auth.

CREATE TABLE IF NOT EXISTS "users" (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT,
    email TEXT NOT NULL UNIQUE,
    username TEXT UNIQUE,
    display_username TEXT,
    email_verified INTEGER NOT NULL DEFAULT 0,
    image TEXT,
    role TEXT NOT NULL DEFAULT 'user',
    banned INTEGER NOT NULL DEFAULT 0,
    ban_reason TEXT,
    ban_expires TEXT,
    two_factor_enabled INTEGER NOT NULL DEFAULT 0,
    metadata TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON "users" (email);
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username ON "users" (username);

CREATE TABLE IF NOT EXISTS "sessions" (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL REFERENCES "users" (id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    ip_address TEXT,
    user_agent TEXT,
    expires_at TEXT NOT NULL,
    active_organization_id TEXT,
    impersonated_by TEXT,
    active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_sessions_token ON "sessions" (token);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON "sessions" (user_id);

CREATE TABLE IF NOT EXISTS "accounts" (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL REFERENCES "users" (id) ON DELETE CASCADE,
    account_id TEXT NOT NULL,
    provider_id TEXT NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    id_token TEXT,
    access_token_expires_at TEXT,
    refresh_token_expires_at TEXT,
    scope TEXT,
    password TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON "accounts" (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_accounts_provider ON "accounts" (provider_id, account_id);

CREATE TABLE IF NOT EXISTS "verifications" (
    id TEXT PRIMARY KEY NOT NULL,
    identifier TEXT NOT NULL,
    value TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_verifications_identifier ON "verifications" (identifier);
CREATE INDEX IF NOT EXISTS idx_verifications_value ON "verifications" (value);

CREATE TABLE IF NOT EXISTS "organization" (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    logo TEXT,
    metadata TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_slug ON "organization" (slug);

CREATE TABLE IF NOT EXISTS "member" (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL REFERENCES "users" (id) ON DELETE CASCADE,
    organization_id TEXT NOT NULL REFERENCES "organization" (id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member',
    created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_member_user_id ON "member" (user_id);
CREATE INDEX IF NOT EXISTS idx_member_org_id ON "member" (organization_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_member_user_org ON "member" (user_id, organization_id);

CREATE TABLE IF NOT EXISTS "invitation" (
    id TEXT PRIMARY KEY NOT NULL,
    organization_id TEXT NOT NULL REFERENCES "organization" (id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member',
    status TEXT NOT NULL DEFAULT 'pending',
    inviter_id TEXT NOT NULL REFERENCES "users" (id),
    expires_at TEXT NOT NULL,
    created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_invitation_org_id ON "invitation" (organization_id);
CREATE INDEX IF NOT EXISTS idx_invitation_email ON "invitation" (email);

CREATE TABLE IF NOT EXISTS "two_factor" (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL UNIQUE REFERENCES "users" (id) ON DELETE CASCADE,
    secret TEXT NOT NULL,
    backup_codes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_two_factor_user_id ON "two_factor" (user_id);

CREATE TABLE IF NOT EXISTS "api_keys" (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL REFERENCES "users" (id) ON DELETE CASCADE,
    name TEXT,
    start TEXT,
    prefix TEXT,
    "key" TEXT NOT NULL,
    enabled INTEGER NOT NULL DEFAULT 1,
    rate_limit_enabled INTEGER NOT NULL DEFAULT 0,
    rate_limit_time_window INTEGER,
    rate_limit_max INTEGER,
    request_count INTEGER,
    remaining INTEGER,
    refill_interval INTEGER,
    refill_amount INTEGER,
    last_refill_at TEXT,
    last_request TEXT,
    expires_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    permissions TEXT,
    metadata TEXT
);

CREATE INDEX IF NOT EXISTS idx_api_keys_user_id ON "api_keys" (user_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_key ON "api_keys" ("key");

CREATE TABLE IF NOT EXISTS "passkeys" (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL REFERENCES "users" (id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    credential_id TEXT NOT NULL UNIQUE,
    public_key TEXT NOT NULL,
    counter INTEGER NOT NULL DEFAULT 0,
    device_type TEXT NOT NULL DEFAULT '',
    backed_up INTEGER NOT NULL DEFAULT 0,
    transports TEXT,
    created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_passkeys_user_id ON "passkeys" (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_passkeys_credential_id ON "passkeys" (credential_id);

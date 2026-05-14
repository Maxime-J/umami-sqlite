BEGIN TRANSACTION;
PRAGMA writable_schema=ON;

UPDATE sqlite_schema SET sql = 'CREATE TABLE "user" (
    "user_id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME,
    "deleted_at" DATETIME
, "display_name" TEXT, "logo_url" TEXT)' WHERE type='table' AND name='user';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "session" (
    "session_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "hostname" TEXT,
    "browser" TEXT,
    "os" TEXT,
    "device" TEXT,
    "screen" TEXT,
    "language" TEXT,
    "country" TEXT,
    "subdivision1" TEXT,
    "subdivision2" TEXT,
    "city" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000)
)' WHERE type='table' AND name='session';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "website" (
    "website_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "domain" TEXT,
    "share_id" TEXT,
    "reset_at" DATETIME,
    "user_id" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME,
    "deleted_at" DATETIME
, "created_by" TEXT, "team_id" TEXT)' WHERE type='table' AND name='website';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "event_data" (
    "event_data_id" TEXT NOT NULL,
    "website_event_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "data_key" TEXT NOT NULL,
    "string_value" TEXT,
    "number_value" NUMERIC,
    "date_value" DATETIME,
    "data_type" INTEGER NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000)
)' WHERE type='table' AND name='event_data';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "team" (
    "team_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "access_code" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
, "deleted_at" DATETIME, "logo_url" TEXT)' WHERE type='table' AND name='team';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "team_user" (
    "team_user_id" TEXT NOT NULL,
    "team_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
)' WHERE type='table' AND name='team_user';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "session_data" (
    "session_data_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "data_key" TEXT NOT NULL,
    "string_value" TEXT,
    "number_value" NUMERIC,
    "date_value" DATETIME,
    "data_type" INTEGER NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000)
)' WHERE type='table' AND name='session_data';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "report" (
    "report_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "parameters" TEXT NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
)' WHERE type='table' AND name='report';

UPDATE sqlite_schema SET sql = 'CREATE TABLE "website_event" (
    "event_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "visit_id" TEXT NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "url_path" TEXT NOT NULL,
    "url_query" TEXT,
    "referrer_path" TEXT,
    "referrer_query" TEXT,
    "referrer_domain" TEXT,
    "page_title" TEXT,
    "event_type" INTEGER NOT NULL DEFAULT 1,
    "event_name" TEXT
, "tag" TEXT NULL)' WHERE type='table' AND name='website_event';

CREATE TABLE update_schema_version ( version INTEGER );
DROP TABLE update_schema_version;
PRAGMA writable_schema=OFF;
COMMIT;

UPDATE user SET created_at = created_at * 1000;
UPDATE user SET updated_at = updated_at * 1000 WHERE updated_at IS NOT NULL;
UPDATE user SET deleted_at = deleted_at * 1000 WHERE deleted_at IS NOT NULL;

UPDATE session SET created_at = created_at * 1000;

UPDATE website SET created_at = created_at * 1000;
UPDATE website SET updated_at = updated_at * 1000 WHERE updated_at IS NOT NULL;
UPDATE website SET deleted_at = deleted_at * 1000 WHERE deleted_at IS NOT NULL;
UPDATE website SET reset_at = reset_at * 1000 WHERE reset_at IS NOT NULL;

UPDATE event_data SET created_at = created_at * 1000;
UPDATE event_data SET date_value = date_value * 1000 WHERE date_value IS NOT NULL;

UPDATE team SET created_at = created_at * 1000;
UPDATE team SET updated_at = updated_at * 1000 WHERE updated_at IS NOT NULL;
UPDATE team SET deleted_at = deleted_at * 1000 WHERE deleted_at IS NOT NULL;

UPDATE team_user SET created_at = created_at * 1000;
UPDATE team_user SET updated_at = updated_at * 1000 WHERE updated_at IS NOT NULL;

UPDATE session_data SET created_at = created_at * 1000;
UPDATE session_data SET date_value = date_value * 1000 WHERE date_value IS NOT NULL;

UPDATE report SET created_at = created_at * 1000;
UPDATE report SET updated_at = updated_at * 1000 WHERE updated_at IS NOT NULL;

UPDATE website_event SET created_at = created_at * 1000;

VACUUM;
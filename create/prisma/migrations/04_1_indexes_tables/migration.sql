-- Remove redundant indexes and clean table definitions
BEGIN TRANSACTION;
-- Create new tables
CREATE TABLE "new_user" (
    "user_id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "created_at" INTEGER DEFAULT (unixepoch()),
    "updated_at" INTEGER,
    "deleted_at" INTEGER
);
CREATE TABLE "new_session" (
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
    "created_at" INTEGER DEFAULT (unixepoch())
);
CREATE TABLE "new_website" (
    "website_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "domain" TEXT,
    "share_id" TEXT,
    "reset_at" INTEGER,
    "user_id" TEXT,
    "created_at" INTEGER DEFAULT (unixepoch()),
    "updated_at" INTEGER,
    "deleted_at" INTEGER
);
CREATE TABLE "new_website_event" (
    "event_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "created_at" INTEGER DEFAULT (unixepoch()),
    "url_path" TEXT NOT NULL,
    "url_query" TEXT,
    "referrer_path" TEXT,
    "referrer_query" TEXT,
    "referrer_domain" TEXT,
    "page_title" TEXT,
    "event_type" INTEGER NOT NULL DEFAULT 1,
    "event_name" TEXT
);
CREATE TABLE "new_event_data" (
    "event_data_id" TEXT NOT NULL,
    "website_event_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "event_key" TEXT NOT NULL,
    "string_value" TEXT,
    "number_value" NUMERIC,
    "date_value" INTEGER,
    "data_type" INTEGER NOT NULL,
    "created_at" INTEGER DEFAULT (unixepoch())
);
CREATE TABLE "new_team" (
    "team_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "access_code" TEXT,
    "created_at" INTEGER DEFAULT (unixepoch()),
    "updated_at" INTEGER
);
CREATE TABLE "new_team_user" (
    "team_user_id" TEXT NOT NULL,
    "team_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "created_at" INTEGER DEFAULT (unixepoch()),
    "updated_at" INTEGER
);
CREATE TABLE "new_team_website" (
    "team_website_id" TEXT NOT NULL,
    "team_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "created_at" INTEGER DEFAULT (unixepoch())
);
CREATE TABLE "new_session_data" (
    "session_data_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "event_key" TEXT NOT NULL,
    "string_value" TEXT,
    "number_value" NUMERIC,
    "date_value" INTEGER,
    "data_type" INTEGER NOT NULL,
    "created_at" INTEGER DEFAULT (unixepoch())
);
CREATE TABLE "new_report" (
    "report_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "parameters" TEXT NOT NULL,
    "created_at" INTEGER DEFAULT (unixepoch()),
    "updated_at" INTEGER
);
-- Transfer data
INSERT INTO "new_user" SELECT "user_id", "username", "password", "role", "created_at", "updated_at", "deleted_at" FROM "user";
INSERT INTO "new_session" SELECT "session_id", "website_id", "hostname", "browser", "os", "device", "screen", "language", "country", "subdivision1", "subdivision2", "city", "created_at" FROM "session";
INSERT INTO "new_website" SELECT "website_id", "name", "domain", "share_id", "reset_at", "user_id", "created_at", "updated_at", "deleted_at" FROM "website";
INSERT INTO "new_website_event" SELECT "event_id", "website_id", "session_id", "created_at", "url_path", "url_query", "referrer_path", "referrer_query", "referrer_domain", "page_title", "event_type", "event_name" FROM "website_event";
INSERT INTO "new_event_data" SELECT "event_data_id", "website_event_id", "website_id", "event_key", "string_value", "number_value", "date_value", "data_type", "created_at" FROM "event_data";
INSERT INTO "new_team" SELECT "team_id", "name", "access_code", "created_at", "updated_at" FROM "team";
INSERT INTO "new_team_user" SELECT "team_user_id", "team_id", "user_id", "role", "created_at", "updated_at" FROM "team_user";
INSERT INTO "new_team_website" SELECT "team_website_id", "team_id", "website_id", "created_at" FROM "team_website";
INSERT INTO "new_session_data" SELECT "session_data_id", "website_id", "session_id", "event_key", "string_value", "number_value", "date_value", "data_type", "created_at" FROM "session_data";
INSERT INTO "new_report" SELECT "report_id", "user_id", "website_id", "type", "name", "description", "parameters", "created_at", "updated_at" FROM "report";
-- Drop tables
DROP TABLE "user";
DROP TABLE "session";
DROP TABLE "website";
DROP TABLE "website_event";
DROP TABLE "event_data";
DROP TABLE "team";
DROP TABLE "team_user";
DROP TABLE "team_website";
DROP TABLE "session_data";
DROP TABLE "report";
-- Rename tables
ALTER TABLE "new_user" RENAME TO "user";
ALTER TABLE "new_session" RENAME TO "session";
ALTER TABLE "new_website" RENAME TO "website";
ALTER TABLE "new_website_event" RENAME TO "website_event";
ALTER TABLE "new_event_data" RENAME TO "event_data";
ALTER TABLE "new_team" RENAME TO "team";
ALTER TABLE "new_team_user" RENAME TO "team_user";
ALTER TABLE "new_team_website" RENAME TO "team_website";
ALTER TABLE "new_session_data" RENAME TO "session_data";
ALTER TABLE "new_report" RENAME TO "report";
-- Create indexes
CREATE UNIQUE INDEX "user_user_id_key" ON "user"("user_id");
CREATE UNIQUE INDEX "user_username_key" ON "user"("username");

CREATE UNIQUE INDEX "session_session_id_key" ON "session"("session_id");
CREATE INDEX "session_created_at_idx" ON "session"("created_at");
CREATE INDEX "session_website_id_idx" ON "session"("website_id");
CREATE INDEX "session_website_id_created_at_idx" ON "session"("website_id", "created_at");
CREATE INDEX "session_website_id_created_at_hostname_idx" ON "session"("website_id", "created_at", "hostname");
CREATE INDEX "session_website_id_created_at_browser_idx" ON "session"("website_id", "created_at", "browser");
CREATE INDEX "session_website_id_created_at_os_idx" ON "session"("website_id", "created_at", "os");
CREATE INDEX "session_website_id_created_at_device_idx" ON "session"("website_id", "created_at", "device");
CREATE INDEX "session_website_id_created_at_screen_idx" ON "session"("website_id", "created_at", "screen");
CREATE INDEX "session_website_id_created_at_language_idx" ON "session"("website_id", "created_at", "language");
CREATE INDEX "session_website_id_created_at_country_idx" ON "session"("website_id", "created_at", "country");
CREATE INDEX "session_website_id_created_at_subdivision1_idx" ON "session"("website_id", "created_at", "subdivision1");
CREATE INDEX "session_website_id_created_at_city_idx" ON "session"("website_id", "created_at", "city");

CREATE UNIQUE INDEX "website_website_id_key" ON "website"("website_id");
CREATE UNIQUE INDEX "website_share_id_key" ON "website"("share_id");
CREATE INDEX "website_user_id_idx" ON "website"("user_id");
CREATE INDEX "website_created_at_idx" ON "website"("created_at");

CREATE UNIQUE INDEX "website_event_event_id_key" ON "website_event"("event_id");
CREATE INDEX "website_event_created_at_idx" ON "website_event"("created_at");
CREATE INDEX "website_event_session_id_idx" ON "website_event"("session_id");
CREATE INDEX "website_event_website_id_idx" ON "website_event"("website_id");
CREATE INDEX "website_event_website_id_created_at_idx" ON "website_event"("website_id", "created_at");
CREATE INDEX "website_event_website_id_session_id_created_at_idx" ON "website_event"("website_id", "session_id", "created_at");
CREATE INDEX "website_event_website_id_created_at_url_path_idx" ON "website_event"("website_id", "created_at", "url_path");
CREATE INDEX "website_event_website_id_created_at_url_query_idx" ON "website_event"("website_id", "created_at", "url_query");
CREATE INDEX "website_event_website_id_created_at_referrer_domain_idx" ON "website_event"("website_id", "created_at", "referrer_domain");
CREATE INDEX "website_event_website_id_created_at_page_title_idx" ON "website_event"("website_id", "created_at", "page_title");
CREATE INDEX "website_event_website_id_created_at_event_name_idx" ON "website_event"("website_id", "created_at", "event_name");

CREATE UNIQUE INDEX "event_data_event_data_id_key" ON "event_data"("event_data_id");
CREATE INDEX "event_data_created_at_idx" ON "event_data"("created_at");
CREATE INDEX "event_data_website_id_idx" ON "event_data"("website_id");
CREATE INDEX "event_data_website_event_id_idx" ON "event_data"("website_event_id");
CREATE INDEX "event_data_website_id_website_event_id_created_at_idx" ON "event_data"("website_id", "website_event_id", "created_at");
CREATE INDEX "event_data_website_id_created_at_idx" ON "event_data"("website_id", "created_at");
CREATE INDEX "event_data_website_id_created_at_event_key_idx" ON "event_data"("website_id", "created_at", "event_key");

CREATE UNIQUE INDEX "team_team_id_key" ON "team"("team_id");
CREATE UNIQUE INDEX "team_access_code_key" ON "team"("access_code");

CREATE UNIQUE INDEX "team_user_team_user_id_key" ON "team_user"("team_user_id");
CREATE INDEX "team_user_team_id_idx" ON "team_user"("team_id");
CREATE INDEX "team_user_user_id_idx" ON "team_user"("user_id");

CREATE UNIQUE INDEX "team_website_team_website_id_key" ON "team_website"("team_website_id");
CREATE INDEX "team_website_team_id_idx" ON "team_website"("team_id");
CREATE INDEX "team_website_website_id_idx" ON "team_website"("website_id");

CREATE UNIQUE INDEX "session_data_session_data_id_key" ON "session_data"("session_data_id");
CREATE INDEX "session_data_created_at_idx" ON "session_data"("created_at");
CREATE INDEX "session_data_website_id_idx" ON "session_data"("website_id");
CREATE INDEX "session_data_session_id_idx" ON "session_data"("session_id");

CREATE UNIQUE INDEX "report_report_id_key" ON "report"("report_id");
CREATE INDEX "report_user_id_idx" ON "report"("user_id");
CREATE INDEX "report_website_id_idx" ON "report"("website_id");
CREATE INDEX "report_type_idx" ON "report"("type");
CREATE INDEX "report_name_idx" ON "report"("name");
COMMIT;

VACUUM;
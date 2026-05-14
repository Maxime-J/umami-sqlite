BEGIN TRANSACTION;

CREATE TABLE "new_website_event" (
    "event_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "visit_id" TEXT NOT NULL,
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

INSERT INTO "new_website_event" SELECT "event_id", "website_id", "session_id", 'uuid' as "visit_id", "created_at", "url_path", "url_query", "referrer_path", "referrer_query", "referrer_domain", "page_title", "event_type", "event_name" FROM "website_event";

UPDATE "new_website_event" as we
SET visit_id = a.uuid
FROM (SELECT DISTINCT
        s.session_id,
        s.visit_time,
        lower(
          hex(randomblob(4))
          || '-' || hex(randomblob(2))
          || '-' || '4' || substr(hex(randomblob(2)), 2)
          || '-' || substr('89AB', 1 + (abs(random()) % 4) , 1)  || substr(hex(randomblob(2)), 2)
          || '-' || hex(randomblob(6))
        ) uuid
    FROM (SELECT DISTINCT session_id,
            strftime('%Y-%m-%d %H:00:00', created_at, 'unixepoch') visit_time
        FROM "website_event") s) a
WHERE we.session_id = a.session_id 
    and strftime('%Y-%m-%d %H:00:00', we.created_at, 'unixepoch') = a.visit_time;

DROP TABLE "website_event";

ALTER TABLE "new_website_event" RENAME TO "website_event";

CREATE UNIQUE INDEX "website_event_event_id_key" ON "website_event"("event_id");
CREATE INDEX "website_event_created_at_idx" ON "website_event"("created_at");
CREATE INDEX "website_event_session_id_idx" ON "website_event"("session_id");
CREATE INDEX "website_event_visit_id_idx" ON "website_event"("visit_id");
CREATE INDEX "website_event_website_id_idx" ON "website_event"("website_id");
CREATE INDEX "website_event_website_id_created_at_idx" ON "website_event"("website_id", "created_at");
CREATE INDEX "website_event_website_id_session_id_created_at_idx" ON "website_event"("website_id", "session_id", "created_at");
CREATE INDEX "website_event_website_id_created_at_url_path_idx" ON "website_event"("website_id", "created_at", "url_path");
CREATE INDEX "website_event_website_id_created_at_url_query_idx" ON "website_event"("website_id", "created_at", "url_query");
CREATE INDEX "website_event_website_id_created_at_referrer_domain_idx" ON "website_event"("website_id", "created_at", "referrer_domain");
CREATE INDEX "website_event_website_id_created_at_page_title_idx" ON "website_event"("website_id", "created_at", "page_title");
CREATE INDEX "website_event_website_id_created_at_event_name_idx" ON "website_event"("website_id", "created_at", "event_name");
CREATE INDEX "website_event_website_id_visit_id_created_at_idx" ON "website_event"("website_id", "visit_id", "created_at");

COMMIT;
VACUUM;
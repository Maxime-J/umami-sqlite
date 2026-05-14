-- CreateTable
CREATE TABLE "link" (
    "link_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "user_id" TEXT,
    "team_id" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME,
    "deleted_at" DATETIME
);

-- CreateTable
CREATE TABLE "pixel" (
    "pixel_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "user_id" TEXT,
    "team_id" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME,
    "deleted_at" DATETIME
);

-- CreateIndex
CREATE UNIQUE INDEX "link_link_id_key" ON "link"("link_id");

-- CreateIndex
CREATE UNIQUE INDEX "link_slug_key" ON "link"("slug");

-- CreateIndex
CREATE INDEX "link_user_id_idx" ON "link"("user_id");

-- CreateIndex
CREATE INDEX "link_team_id_idx" ON "link"("team_id");

-- CreateIndex
CREATE INDEX "link_created_at_idx" ON "link"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "pixel_pixel_id_key" ON "pixel"("pixel_id");

-- CreateIndex
CREATE UNIQUE INDEX "pixel_slug_key" ON "pixel"("slug");

-- CreateIndex
CREATE INDEX "pixel_user_id_idx" ON "pixel"("user_id");

-- CreateIndex
CREATE INDEX "pixel_team_id_idx" ON "pixel"("team_id");

-- CreateIndex
CREATE INDEX "pixel_created_at_idx" ON "pixel"("created_at");

-- DataMigration Funnel
DELETE FROM "report" WHERE type = 'funnel' AND json_array_length(parameters, '$.steps') = 1;
UPDATE "report" SET parameters = json_remove(parameters, '$.websiteId', '$.dateRange', '$.urls') WHERE type = 'funnel';

UPDATE "report"
SET parameters = json_set(
    parameters,
    '$.steps',
    (
      SELECT json_group_array(
        CASE
          WHEN value->>'type' = 'url'
          THEN json_set(value, '$.type', 'path')
          ELSE value
        END
      )
      FROM json_each(parameters, '$.steps')
    )
)
WHERE type = 'funnel'
  AND EXISTS (
    SELECT 1
    FROM json_each(parameters, '$.steps')
    WHERE value->>'type' = 'url'
    LIMIT 1
  );

-- DataMigration Goals
UPDATE "report" SET type = 'goal' WHERE type = 'goals';

INSERT INTO "report" (report_id, user_id, website_id, type, name, description, parameters, created_at, updated_at)
SELECT lower(
      hex(randomblob(4))
      || '-' || hex(randomblob(2))
      || '-' || '4' || substr(hex(randomblob(2)), 2)
      || '-' || substr('89AB', 1 + (abs(random()) % 4) , 1)  || substr(hex(randomblob(2)), 2)
      || '-' || hex(randomblob(6))
    ),
    r.user_id,
    r.website_id,
    'goal',
    name || ' - ' || (elem.value ->> 'value'),
    r.description,
    json_object(
      'type', CASE WHEN elem.value ->> 'type' = 'url' THEN 'path'
              ELSE elem.value ->> 'type' END,
      'value', elem.value ->> 'value'
    ),
    r.created_at,
    r.updated_at
FROM "report" r, json_each(r.parameters, '$.goals') AS elem
WHERE r.type = 'goal'
  AND elem.value ->> 'type' IN ('event', 'url');

DELETE FROM "report" WHERE type = 'goal' AND json_type(parameters, '$.goals') IS NOT NULL;

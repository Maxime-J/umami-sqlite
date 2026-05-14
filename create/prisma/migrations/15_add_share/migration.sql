-- CreateTable
CREATE TABLE "share" (
    "share_id" TEXT NOT NULL,
    "entity_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "share_type" INTEGER NOT NULL,
    "slug" TEXT NOT NULL,
    "parameters" JSONB NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
);

-- MigrateData
INSERT INTO "share" (share_id, entity_id, name, share_type, slug, parameters, created_at)
SELECT lower(
      hex(randomblob(4))
      || '-' || hex(randomblob(2))
      || '-' || '4' || substr(hex(randomblob(2)), 2)
      || '-' || substr('89AB', 1 + (abs(random()) % 4) , 1)  || substr(hex(randomblob(2)), 2)
      || '-' || hex(randomblob(6))
    ),
    website_id,
    name,
    1,
    share_id,
    json_object('overview', true),
    unixepoch() * 1000
FROM "website"
WHERE share_id IS NOT NULL;

-- RedefineTables
CREATE TABLE "new_website" (
    "website_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "domain" TEXT,
    "reset_at" DATETIME,
    "user_id" TEXT,
    "team_id" TEXT,
    "created_by" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME,
    "deleted_at" DATETIME
);
INSERT INTO "new_website" ("created_at", "created_by", "deleted_at", "domain", "name", "reset_at", "team_id", "updated_at", "user_id", "website_id") SELECT "created_at", "created_by", "deleted_at", "domain", "name", "reset_at", "team_id", "updated_at", "user_id", "website_id" FROM "website";
DROP TABLE "website";
ALTER TABLE "new_website" RENAME TO "website";
CREATE UNIQUE INDEX "website_website_id_key" ON "website"("website_id");
CREATE INDEX "website_user_id_idx" ON "website"("user_id");
CREATE INDEX "website_team_id_idx" ON "website"("team_id");
CREATE INDEX "website_created_at_idx" ON "website"("created_at");
CREATE INDEX "website_created_by_idx" ON "website"("created_by");

-- CreateIndex
CREATE UNIQUE INDEX "share_share_id_key" ON "share"("share_id");

-- CreateIndex
CREATE UNIQUE INDEX "share_slug_key" ON "share"("slug");

-- CreateIndex
CREATE INDEX "share_entity_id_idx" ON "share"("entity_id");

-- RedefineTables
CREATE TABLE "new_report" (
    "report_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "parameters" JSONB NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
);
INSERT INTO "new_report" ("created_at", "description", "name", "parameters", "report_id", "type", "updated_at", "user_id", "website_id") SELECT "created_at", "description", "name", "parameters", "report_id", "type", "updated_at", "user_id", "website_id" FROM "report";
DROP TABLE "report";
ALTER TABLE "new_report" RENAME TO "report";
CREATE UNIQUE INDEX "report_report_id_key" ON "report"("report_id");
CREATE INDEX "report_user_id_idx" ON "report"("user_id");
CREATE INDEX "report_website_id_idx" ON "report"("website_id");
CREATE INDEX "report_type_idx" ON "report"("type");
CREATE INDEX "report_name_idx" ON "report"("name");

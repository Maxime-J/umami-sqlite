/*
  Warnings:

  - You are about to drop the `team_website` table. If the table is not empty, all the data it contains will be lost.

*/
BEGIN TRANSACTION;
-- AlterTable
ALTER TABLE "team" ADD COLUMN "deleted_at" INTEGER;
ALTER TABLE "team" ADD COLUMN "logo_url" TEXT;

-- AlterTable
ALTER TABLE "user" ADD COLUMN "display_name" TEXT;
ALTER TABLE "user" ADD COLUMN "logo_url" TEXT;

-- AlterTable
ALTER TABLE "website" ADD COLUMN "created_by" TEXT;
ALTER TABLE "website" ADD COLUMN "team_id" TEXT;
COMMIT;

-- MigrateData
UPDATE "website" SET created_by = user_id WHERE team_id IS NULL;

-- DropTable
DROP TABLE "team_website";

-- CreateIndex
CREATE INDEX "website_team_id_idx" ON "website"("team_id");

-- CreateIndex
CREATE INDEX "website_created_by_idx" ON "website"("created_by");
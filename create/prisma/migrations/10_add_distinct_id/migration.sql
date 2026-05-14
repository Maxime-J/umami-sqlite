-- AlterTable
ALTER TABLE "session" ADD COLUMN "distinct_id" TEXT;

-- AlterTable
ALTER TABLE "session_data" ADD COLUMN "distinct_id" TEXT;

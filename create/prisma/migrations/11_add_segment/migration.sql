-- CreateTable
CREATE TABLE "segment" (
    "segment_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "parameters" JSONB NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
);

-- CreateIndex
CREATE UNIQUE INDEX "segment_segment_id_key" ON "segment"("segment_id");

-- CreateIndex
CREATE INDEX "segment_website_id_idx" ON "segment"("website_id");

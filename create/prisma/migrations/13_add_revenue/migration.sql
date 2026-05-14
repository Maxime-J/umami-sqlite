-- CreateTable
CREATE TABLE "revenue" (
    "revenue_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "event_id" TEXT NOT NULL,
    "event_name" TEXT NOT NULL,
    "currency" TEXT NOT NULL,
    "revenue" NUMERIC,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000)
);

-- CreateIndex
CREATE UNIQUE INDEX "revenue_revenue_id_key" ON "revenue"("revenue_id");

-- CreateIndex
CREATE INDEX "revenue_website_id_idx" ON "revenue"("website_id");

-- CreateIndex
CREATE INDEX "revenue_session_id_idx" ON "revenue"("session_id");

-- CreateIndex
CREATE INDEX "revenue_website_id_created_at_idx" ON "revenue"("website_id", "created_at");

-- CreateIndex
CREATE INDEX "revenue_website_id_session_id_created_at_idx" ON "revenue"("website_id", "session_id", "created_at");

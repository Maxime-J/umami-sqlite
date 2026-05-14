-- CreateTable
CREATE TABLE "board" (
    "board_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "parameters" JSONB NOT NULL,
    "slug" TEXT NOT NULL,
    "user_id" TEXT,
    "team_id" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
);

-- CreateIndex
CREATE UNIQUE INDEX "board_board_id_key" ON "board"("board_id");

-- CreateIndex
CREATE UNIQUE INDEX "board_slug_key" ON "board"("slug");

-- CreateIndex
CREATE INDEX "board_slug_idx" ON "board"("slug");

-- CreateIndex
CREATE INDEX "board_user_id_idx" ON "board"("user_id");

-- CreateIndex
CREATE INDEX "board_team_id_idx" ON "board"("team_id");

-- CreateIndex
CREATE INDEX "board_created_at_idx" ON "board"("created_at");

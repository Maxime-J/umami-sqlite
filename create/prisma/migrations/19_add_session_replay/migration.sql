-- RedefineTable
CREATE TABLE "new_board" (
    "board_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "parameters" JSONB NOT NULL,
    "user_id" TEXT,
    "team_id" TEXT,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
);
INSERT INTO "new_board" ("board_id", "created_at", "description", "name", "parameters", "team_id", "type", "updated_at", "user_id") SELECT "board_id", "created_at", "description", "name", "parameters", "team_id", "type", "updated_at", "user_id" FROM "board";
DROP TABLE "board";
ALTER TABLE "new_board" RENAME TO "board";
CREATE UNIQUE INDEX "board_board_id_key" ON "board"("board_id");
CREATE INDEX "board_user_id_idx" ON "board"("user_id");
CREATE INDEX "board_team_id_idx" ON "board"("team_id");
CREATE INDEX "board_created_at_idx" ON "board"("created_at");

-- AlterTable
ALTER TABLE "website" ADD COLUMN "replay_enabled" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "website" ADD COLUMN "replay_config" JSONB;

-- CreateTable
CREATE TABLE "session_replay" (
    "replay_id" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "visit_id" TEXT NOT NULL,
    "chunk_index" INTEGER NOT NULL,
    "events" BLOB NOT NULL,
    "event_count" INTEGER NOT NULL,
    "started_at" DATETIME NOT NULL,
    "ended_at" DATETIME NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000)
);

-- CreateIndex
CREATE UNIQUE INDEX "session_replay_replay_id_key" ON "session_replay"("replay_id");

-- CreateIndex
CREATE INDEX "session_replay_website_id_idx" ON "session_replay"("website_id");

-- CreateIndex
CREATE INDEX "session_replay_session_id_idx" ON "session_replay"("session_id");

-- CreateIndex
CREATE INDEX "session_replay_visit_id_idx" ON "session_replay"("visit_id");

-- CreateIndex
CREATE INDEX "session_replay_website_id_session_id_idx" ON "session_replay"("website_id", "session_id");

-- CreateIndex
CREATE INDEX "session_replay_website_id_visit_id_idx" ON "session_replay"("website_id", "visit_id");

-- CreateIndex
CREATE INDEX "session_replay_website_id_created_at_idx" ON "session_replay"("website_id", "created_at");

-- CreateIndex
CREATE INDEX "session_replay_session_id_chunk_index_idx" ON "session_replay"("session_id", "chunk_index");

-- CreateTable
CREATE TABLE "session_replay_saved" (
    "saved_replay_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "website_id" TEXT NOT NULL,
    "visit_id" TEXT NOT NULL,
    "created_at" DATETIME DEFAULT (unixepoch() * 1000),
    "updated_at" DATETIME
);

-- CreateIndex
CREATE UNIQUE INDEX "session_replay_saved_saved_replay_id_key" ON "session_replay_saved"("saved_replay_id");

-- CreateIndex
CREATE INDEX "session_replay_saved_website_id_idx" ON "session_replay_saved"("website_id");

-- CreateIndex
CREATE INDEX "session_replay_saved_visit_id_idx" ON "session_replay_saved"("visit_id");

-- CreateIndex
CREATE INDEX "session_replay_saved_website_id_created_at_idx" ON "session_replay_saved"("website_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "session_replay_saved_website_id_visit_id_key" ON "session_replay_saved"("website_id", "visit_id");

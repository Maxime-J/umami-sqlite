-- CreateTable
CREATE TABLE `user` (
    `user_id` TEXT PRIMARY KEY NOT NULL,
    `username` TEXT NOT NULL,
    `password` TEXT NOT NULL,
    `role` TEXT NOT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now')),
    `updated_at` INTEGER NULL,
    `deleted_at` INTEGER NULL
);
CREATE UNIQUE INDEX `user_user_id_key` ON `user`(`user_id`);
CREATE UNIQUE INDEX `user_username_key` ON `user`(`username`);

-- CreateTable
CREATE TABLE `session` (
    `session_id` TEXT PRIMARY KEY NOT NULL,
    `website_id` TEXT NOT NULL,
    `hostname` TEXT NULL,
    `browser` TEXT NULL,
    `os` TEXT NULL,
    `device` TEXT NULL,
    `screen` TEXT NULL,
    `language` TEXT NULL,
    `country` TEXT NULL,
    `subdivision1` TEXT NULL,
    `subdivision2` TEXT NULL,
    `city` TEXT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now'))
);
CREATE UNIQUE INDEX `session_session_id_key` ON `session`(`session_id`);
CREATE INDEX `session_created_at_idx` ON `session`(`created_at`);
CREATE INDEX `session_website_id_idx` ON `session`(`website_id`);

-- CreateTable
CREATE TABLE `website` (
    `website_id` TEXT PRIMARY KEY NOT NULL,
    `name` TEXT NOT NULL,
    `domain` TEXT NULL,
    `share_id` TEXT NULL,
    `reset_at` INTEGER NULL,
    `user_id` TEXT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now')),
    `updated_at` INTEGER NULL,
    `deleted_at` INTEGER NULL
);
CREATE UNIQUE INDEX `website_website_id_key` ON `website`(`website_id`);
CREATE UNIQUE INDEX `website_share_id_key` ON `website`(`share_id`);
CREATE INDEX `website_user_id_idx` ON `website`(`user_id`);
CREATE INDEX `website_created_at_idx` ON `website`(`created_at`);
CREATE INDEX `website_share_id_idx` ON `website`(`share_id`);

-- CreateTable
CREATE TABLE `website_event` (
    `event_id` TEXT PRIMARY KEY NOT NULL,
    `website_id` TEXT NOT NULL,
    `session_id` TEXT NOT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now')),
    `url_path` TEXT NOT NULL,
    `url_query` TEXT NULL,
    `referrer_path` TEXT NULL,
    `referrer_query` TEXT NULL,
    `referrer_domain` TEXT NULL,
    `page_title` TEXT NULL,
    `event_type` INTEGER UNSIGNED NOT NULL DEFAULT 1,
    `event_name` TEXT NULL
);
CREATE INDEX `website_event_created_at_idx` ON `website_event`(`created_at`);
CREATE INDEX `website_event_session_id_idx` ON `website_event`(`session_id`);
CREATE INDEX `website_event_website_id_idx` ON `website_event`(`website_id`);
CREATE INDEX `website_event_website_id_created_at_idx` ON `website_event`(`website_id`, `created_at`);
CREATE INDEX `website_event_website_id_session_id_created_at_idx` ON `website_event`(`website_id`, `session_id`, `created_at`);

-- CreateTable
CREATE TABLE `event_data` (
    `event_id` TEXT PRIMARY KEY NOT NULL,
    `website_event_id` TEXT NOT NULL,
    `website_id` TEXT NOT NULL,
    `event_key` TEXT NOT NULL,
    `event_string_value` TEXT NULL,
    `event_numeric_value` NUMERIC NULL,
    `event_date_value` INTEGER NULL,
    `event_data_type` INTEGER UNSIGNED NOT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now'))
);
CREATE INDEX `event_data_created_at_idx` ON `event_data`(`created_at`);
CREATE INDEX `event_data_website_id_idx` ON `event_data`(`website_id`);
CREATE INDEX `event_data_website_event_id_idx` ON `event_data`(`website_event_id`);
CREATE INDEX `event_data_website_id_website_event_id_created_at_idx` ON `event_data`(`website_id`, `website_event_id`, `created_at`);

-- CreateTable
CREATE TABLE `team` (
    `team_id` TEXT PRIMARY KEY NOT NULL,
    `name` TEXT NOT NULL,
    `access_code` TEXT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now')),
    `updated_at` INTEGER NULL
);
CREATE UNIQUE INDEX `team_team_id_key` ON `team`(`team_id`);
CREATE UNIQUE INDEX `team_access_code_key` ON `team`(`access_code`);
CREATE INDEX `team_access_code_idx` ON `team`(`access_code`);

-- CreateTable
CREATE TABLE `team_user` (
    `team_user_id` TEXT PRIMARY KEY NOT NULL,
    `team_id` TEXT NOT NULL,
    `user_id` TEXT NOT NULL,
    `role` TEXT NOT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now')),
    `updated_at` INTEGER NULL
);
CREATE UNIQUE INDEX `team_user_team_user_id_key` ON `team_user`(`team_user_id`);
CREATE INDEX `team_user_team_id_idx` ON `team_user`(`team_id`);
CREATE INDEX `team_user_user_id_idx` ON `team_user`(`user_id`);

-- CreateTable
CREATE TABLE `team_website` (
    `team_website_id` TEXT PRIMARY KEY NOT NULL,
    `team_id` TEXT NOT NULL,
    `website_id` TEXT NOT NULL,
    `created_at` INTEGER NULL DEFAULT (strftime('%s', 'now'))
);
CREATE UNIQUE INDEX `team_website_team_website_id_key` ON `team_website`(`team_website_id`);
CREATE INDEX `team_website_team_id_idx` ON `team_website`(`team_id`);
CREATE INDEX `team_website_website_id_idx` ON `team_website`(`website_id`);
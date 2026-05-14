-- AlterTable
ALTER TABLE `event_data` RENAME COLUMN `event_data_type` TO `data_type`;
ALTER TABLE `event_data` RENAME COLUMN `event_date_value` TO `date_value`;
ALTER TABLE `event_data` RENAME COLUMN `event_id` TO `event_data_id`;
ALTER TABLE `event_data` RENAME COLUMN `event_numeric_value` TO `number_value`;
ALTER TABLE `event_data` RENAME COLUMN `event_string_value` TO `string_value`;

-- CreateTable
CREATE TABLE `session_data` (
    `session_data_id` TEXT PRIMARY KEY NOT NULL,
    `website_id` TEXT NOT NULL,
    `session_id` TEXT NOT NULL,
    `event_key` TEXT NOT NULL,
    `string_value` TEXT NULL,
    `number_value` NUMERIC NULL,
    `date_value` INTEGER NULL,
    `data_type` INTEGER UNSIGNED NOT NULL,
    `created_at` INTEGER NULL DEFAULT (unixepoch())
);
CREATE INDEX `session_data_created_at_idx` ON `session_data`(`created_at`);
CREATE INDEX `session_data_website_id_idx` ON `session_data`(`website_id`);
CREATE INDEX `session_data_session_id_idx` ON `session_data`(`session_id`);

-- CreateTable
CREATE TABLE `report` (
    `report_id` TEXT PRIMARY KEY NOT NULL,
    `user_id` TEXT NOT NULL,
    `website_id` TEXT NOT NULL,
    `type` TEXT NOT NULL,
    `name` TEXT NOT NULL,
    `description` TEXT NOT NULL,
    `parameters` TEXT NOT NULL,
    `created_at` INTEGER NULL DEFAULT (unixepoch()),
    `updated_at` INTEGER NULL
);
CREATE UNIQUE INDEX `report_report_id_key` ON `report`(`report_id`);
CREATE INDEX `report_user_id_idx` ON `report`(`user_id`);
CREATE INDEX `report_website_id_idx` ON `report`(`website_id`);
CREATE INDEX `report_type_idx` ON `report`(`type`);
CREATE INDEX `report_name_idx` ON `report`(`name`);

-- EventData migration
UPDATE event_data
SET string_value = number_value
WHERE data_type = 2;

UPDATE event_data
SET string_value = strftime('%Y-%m-%dT%H:%M:%fZ', date_value, 'unixepoch')
WHERE data_type = 4;
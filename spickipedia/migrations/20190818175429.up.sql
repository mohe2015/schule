ALTER TABLE "schedule_data" RENAME TO "schedule_data1077";
CREATE TABLE "schedule_data" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "weekday" INTEGER NOT NULL,
    "hour" INTEGER NOT NULL,
    "week_modulo" INTEGER NOT NULL,
    "course_id" INTEGER NOT NULL,
    "room" VARCHAR(32) NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);
INSERT INTO "schedule_data" ("course_id", "created_at", "hour", "id", "room", "updated_at", "week_modulo", "weekday") SELECT "course_id", "created_at", "hour", "id", "room", "updated_at", "week_modulo", "weekday" FROM "schedule_data1077";
CREATE TABLE "schedule_revision_data" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "schedule_revision_id" INTEGER NOT NULL,
    "schedule_data_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

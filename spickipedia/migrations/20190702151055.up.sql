ALTER TABLE "user" RENAME TO "user10977";
CREATE TABLE "user" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" VARCHAR(64) NOT NULL,
    "group" VARCHAR(64) NOT NULL,
    "hash" VARCHAR(512) NOT NULL,
    "grade_id" INTEGER,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);
INSERT INTO "user" ("created_at", "grade_id", "group", "hash", "id", "name", "updated_at") SELECT "created_at", "grade_id", "group", "hash", "id", "name", "updated_at" FROM "user10977";

CREATE TABLE "web_push" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER NOT NULL,
    "p256dh" VARCHAR(128) NOT NULL,
    "auth" VARCHAR(32) NOT NULL,
    "endpoint" VARCHAR(1024) NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP,
    UNIQUE ("user_id", "p256dh", "auth", "endpoint")
);

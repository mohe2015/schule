CREATE TABLE "schedule" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "grade" VARCHAR(64) NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP,
    UNIQUE ("grade")
);

CREATE TABLE "user" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" VARCHAR(64) NOT NULL,
    "group" VARCHAR(64) NOT NULL,
    "hash" VARCHAR(512) NOT NULL,
    "grade_id" INTEGER,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "schedule_revision" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "author_id" INTEGER NOT NULL,
    "schedule_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "course" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

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

CREATE TABLE "schedule_revision_data" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "schedule_revision_id" INTEGER NOT NULL,
    "schedule_data_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

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

CREATE TABLE "student_course" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "student_id" INTEGER NOT NULL,
    "course_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP,
    UNIQUE ("student_id", "course_id")
);

CREATE TABLE "teacher" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "course_revision" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "author_id" INTEGER NOT NULL,
    "course_id" INTEGER NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "type" VARCHAR(4) NOT NULL,
    "subject" VARCHAR(64) NOT NULL,
    "is_tutorial" BOOLEAN NOT NULL,
    "grade_id" INTEGER NOT NULL,
    "topic" VARCHAR(512) NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "teacher_revision" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "author_id" INTEGER NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "initial" VARCHAR(64) NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "quiz" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "quiz_revision" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "author_id" INTEGER NOT NULL,
    "quiz_id" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "my_session" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "session_cookie" VARCHAR(512) NOT NULL,
    "csrf_token" VARCHAR(512) NOT NULL,
    "user_id" INTEGER,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "wiki_article" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "title" VARCHAR(128) NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "wiki_article_revision" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "author_id" INTEGER NOT NULL,
    "article_id" INTEGER NOT NULL,
    "summary" VARCHAR(256) NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE "wiki_article_revision_category" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "revision_id" INTEGER NOT NULL,
    "category" VARCHAR(256) NOT NULL,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "schema_migrations" (
    "version" VARCHAR(255) PRIMARY KEY
);
INSERT INTO schema_migrations (version) VALUES ('20190818175429');

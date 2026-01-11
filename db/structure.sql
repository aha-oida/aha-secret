CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "bins" ("payload" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "id" varchar, "expire_date" datetime(6) DEFAULT (datetime('now','+7 day','localtime')), "has_password" boolean DEFAULT FALSE);
CREATE UNIQUE INDEX "index_bins_on_id" ON "bins" ("id");
INSERT INTO "schema_migrations" (version) VALUES
('20240914195836'),
('20240407035007'),
('20240326191856'),
('20240325152739'),
('20240324133511'),
('20240322074525');


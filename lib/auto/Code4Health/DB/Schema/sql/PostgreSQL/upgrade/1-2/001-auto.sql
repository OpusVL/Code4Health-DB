-- Convert schema '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/1/001-auto.yml' to '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "communities" (
  "id" serial NOT NULL,
  "name" character varying NOT NULL,
  "code" character varying NOT NULL,
  "status" character varying DEFAULT 'active' NOT NULL,
  "created" timestamp NOT NULL,
  "updated" timestamp NOT NULL,
  PRIMARY KEY ("id")
);

;
CREATE TABLE "community_links" (
  "id" serial NOT NULL,
  "person_id" integer NOT NULL,
  "community_id" integer NOT NULL,
  "created" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "comm_link" UNIQUE ("person_id", "community_id")
);
CREATE INDEX "community_links_idx_community_id" on "community_links" ("community_id");
CREATE INDEX "community_links_idx_person_id" on "community_links" ("person_id");

;
ALTER TABLE "community_links" ADD CONSTRAINT "community_links_fk_community_id" FOREIGN KEY ("community_id")
  REFERENCES "communities" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "community_links" ADD CONSTRAINT "community_links_fk_person_id" FOREIGN KEY ("person_id")
  REFERENCES "people" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE people ADD COLUMN registrant_category text;

;
ALTER TABLE people ADD COLUMN registrant_category_other text;

;
ALTER TABLE people ADD COLUMN email_preferences text[];

;
ALTER TABLE people ADD COLUMN show_membership boolean DEFAULT '0' NOT NULL;

;

COMMIT;


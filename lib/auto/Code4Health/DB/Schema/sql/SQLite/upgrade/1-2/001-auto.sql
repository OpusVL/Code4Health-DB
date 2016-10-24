-- Convert schema '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/1/001-auto.yml' to '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE communities (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar NOT NULL,
  code varchar NOT NULL,
  status varchar NOT NULL DEFAULT 'active',
  created timestamp NOT NULL,
  updated timestamp NOT NULL
);

;
CREATE TABLE community_links (
  id INTEGER PRIMARY KEY NOT NULL,
  person_id integer NOT NULL,
  community_id integer NOT NULL,
  created timestamp NOT NULL,
  FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX community_links_idx_community_id ON community_links (community_id);

;
CREATE INDEX community_links_idx_person_id ON community_links (person_id);

;
CREATE UNIQUE INDEX comm_link ON community_links (person_id, community_id);

;
ALTER TABLE people ADD COLUMN registrant_category text;

;
ALTER TABLE people ADD COLUMN registrant_category_other text;

;
ALTER TABLE people ADD COLUMN email_preferences text[];

;
ALTER TABLE people ADD COLUMN show_membership boolean NOT NULL DEFAULT 0;

;

COMMIT;


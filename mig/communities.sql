
CREATE TABLE communities (
  id serial NOT NULL,
  name varchar NOT NULL,
  code varchar NOT NULL,
  status varchar DEFAULT 'active' NOT NULL,
  created timestamp NOT NULL,
  updated timestamp NOT NULL,
  PRIMARY KEY (id)
);

--
-- Table: community_links
--
CREATE TABLE community_links (
  id serial NOT NULL,
  person_id integer NOT NULL,
  community_id integer NOT NULL,
  created timestamp NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT comm_link UNIQUE (person_id, community_id)
);
CREATE INDEX community_links_idx_community_id on community_links (community_id);
CREATE INDEX community_links_idx_person_id on community_links (person_id);

ALTER TABLE community_links ADD CONSTRAINT community_links_fk_community_id FOREIGN KEY (community_id)
  REFERENCES communities (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE community_links ADD CONSTRAINT community_links_fk_person_id FOREIGN KEY (person_id)
  REFERENCES people (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;


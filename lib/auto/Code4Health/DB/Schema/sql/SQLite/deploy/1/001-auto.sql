-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Oct 21 16:09:46 2016
-- 

;
BEGIN TRANSACTION;
--
-- Table: email_verifications
--
CREATE TABLE email_verifications (
  hash text NOT NULL,
  expiry timestamp NOT NULL,
  email text NOT NULL,
  PRIMARY KEY (hash)
);
--
-- Table: prf_owner_type
--
CREATE TABLE prf_owner_type (
  prf_owner_type_id INTEGER PRIMARY KEY NOT NULL,
  owner_table varchar NOT NULL,
  owner_resultset varchar NOT NULL
);
CREATE UNIQUE INDEX prf_owner_type__resultset ON prf_owner_type (owner_resultset);
CREATE UNIQUE INDEX prf_owner_type__table ON prf_owner_type (owner_table);
--
-- Table: prf_defaults
--
CREATE TABLE prf_defaults (
  prf_owner_type_id integer NOT NULL,
  name varchar NOT NULL,
  default_value varchar NOT NULL,
  data_type varchar,
  comment varchar,
  required boolean DEFAULT 0,
  active boolean DEFAULT 1,
  hidden boolean,
  audit boolean,
  display_on_search boolean,
  unique_field boolean,
  ajax_validate boolean,
  display_order int NOT NULL DEFAULT 1,
  confirmation_required boolean,
  PRIMARY KEY (prf_owner_type_id, name),
  FOREIGN KEY (prf_owner_type_id) REFERENCES prf_owner_type(prf_owner_type_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX prf_defaults_idx_prf_owner_type_id ON prf_defaults (prf_owner_type_id);
--
-- Table: prf_owners
--
CREATE TABLE prf_owners (
  prf_owner_id integer NOT NULL,
  prf_owner_type_id integer NOT NULL,
  PRIMARY KEY (prf_owner_id, prf_owner_type_id),
  FOREIGN KEY (prf_owner_type_id) REFERENCES prf_owner_type(prf_owner_type_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX prf_owners_idx_prf_owner_type_id ON prf_owners (prf_owner_type_id);
--
-- Table: organisations
--
CREATE TABLE organisations (
  code text NOT NULL,
  import_file text,
  created timestamptz NOT NULL,
  updated timestamptz NOT NULL,
  name text,
  national_grouping text,
  high_level_health_geography text,
  address1 text,
  address2 text,
  address3 text,
  address4 text,
  address5 text,
  postcode text,
  open_date text,
  close_date text,
  organisation_sub_type_code text,
  parent_organisation_code text,
  join_parent_date text,
  left_parent_date text,
  contact_phone_number text,
  amended_record_indicator text,
  unknown1 text,
  unknown2 text,
  unknown3 text,
  unknown4 text,
  unknown5 text,
  unknown6 text,
  unknown7 text,
  unknown8 text,
  unknown9 text,
  prf_id int NOT NULL,
  prf_owner_type_id integer,
  PRIMARY KEY (code),
  FOREIGN KEY (prf_id, prf_owner_type_id) REFERENCES prf_owners(prf_owner_id, prf_owner_type_id),
  FOREIGN KEY (prf_owner_type_id) REFERENCES prf_owner_type(prf_owner_type_id)
);
CREATE INDEX organisations_idx_prf_id_prf_owner_type_id ON organisations (prf_id, prf_owner_type_id);
CREATE INDEX organisations_idx_prf_owner_type_id ON organisations (prf_owner_type_id);
--
-- Table: prf_default_values
--
CREATE TABLE prf_default_values (
  id INTEGER PRIMARY KEY NOT NULL,
  value text,
  prf_owner_type_id integer NOT NULL,
  name varchar NOT NULL,
  display_order int NOT NULL DEFAULT 1,
  FOREIGN KEY (prf_owner_type_id, name) REFERENCES prf_defaults(prf_owner_type_id, name) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX prf_default_values_idx_prf_owner_type_id_name ON prf_default_values (prf_owner_type_id, name);
--
-- Table: prf_preferences
--
CREATE TABLE prf_preferences (
  prf_preference_id INTEGER PRIMARY KEY NOT NULL,
  prf_owner_id integer NOT NULL,
  prf_owner_type_id integer NOT NULL,
  name varchar NOT NULL,
  value varchar,
  FOREIGN KEY (prf_owner_id, prf_owner_type_id) REFERENCES prf_owners(prf_owner_id, prf_owner_type_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX prf_preferences_idx_prf_owner_id_prf_owner_type_id ON prf_preferences (prf_owner_id, prf_owner_type_id);
CREATE UNIQUE INDEX prf_preferences_prf_preference_id_prf_owner_type_id_name ON prf_preferences (prf_preference_id, prf_owner_type_id, name);
--
-- Table: people
--
CREATE TABLE people (
  id INTEGER PRIMARY KEY NOT NULL,
  created timestamp NOT NULL,
  updated timestamp NOT NULL,
  username varchar NOT NULL,
  surname varchar,
  title varchar,
  first_name varchar,
  full_name varchar,
  email_address varchar NOT NULL,
  primary_organisation_id text,
  primary_organisation_other text,
  prf_owner_type_id integer,
  password_reset_hash text,
  password_reset_expiry timestamp,
  FOREIGN KEY (id, prf_owner_type_id) REFERENCES prf_owners(prf_owner_id, prf_owner_type_id),
  FOREIGN KEY (prf_owner_type_id) REFERENCES prf_owner_type(prf_owner_type_id),
  FOREIGN KEY (primary_organisation_id) REFERENCES organisations(code) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX people_idx_id_prf_owner_type_id ON people (id, prf_owner_type_id);
CREATE INDEX people_idx_prf_owner_type_id ON people (prf_owner_type_id);
CREATE INDEX people_idx_primary_organisation_id ON people (primary_organisation_id);
--
-- Table: prf_unique_vals
--
CREATE TABLE prf_unique_vals (
  id INTEGER PRIMARY KEY NOT NULL,
  value_id integer NOT NULL,
  value text,
  prf_owner_type_id integer NOT NULL,
  name varchar NOT NULL,
  FOREIGN KEY (prf_owner_type_id, name) REFERENCES prf_defaults(prf_owner_type_id, name),
  FOREIGN KEY (value_id, prf_owner_type_id, name) REFERENCES prf_preferences(prf_preference_id, prf_owner_type_id, name) ON DELETE CASCADE
);
CREATE INDEX prf_unique_vals_idx_prf_owner_type_id_name ON prf_unique_vals (prf_owner_type_id, name);
CREATE INDEX prf_unique_vals_idx_value_id_prf_owner_type_id_name ON prf_unique_vals (value_id, prf_owner_type_id, name);
CREATE UNIQUE INDEX prf_unique_vals_value_id_prf_owner_type_id_name ON prf_unique_vals (value_id, prf_owner_type_id, name);
CREATE UNIQUE INDEX prf_unique_vals_value_prf_owner_type_id_name ON prf_unique_vals (value, prf_owner_type_id, name);
--
-- Table: secondary_organisation_links
--
CREATE TABLE secondary_organisation_links (
  id INTEGER PRIMARY KEY NOT NULL,
  person_id integer NOT NULL,
  organisation_id text NOT NULL,
  created timestamp NOT NULL,
  FOREIGN KEY (organisation_id) REFERENCES organisations(code) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX secondary_organisation_links_idx_organisation_id ON secondary_organisation_links (organisation_id);
CREATE INDEX secondary_organisation_links_idx_person_id ON secondary_organisation_links (person_id);
COMMIT;

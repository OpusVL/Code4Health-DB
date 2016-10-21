-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Fri Oct 21 16:09:46 2016
-- 
;
--
-- Table: email_verifications
--
CREATE TABLE "email_verifications" (
  "hash" text NOT NULL,
  "expiry" timestamp NOT NULL,
  "email" text NOT NULL,
  PRIMARY KEY ("hash")
);

;
--
-- Table: prf_owner_type
--
CREATE TABLE "prf_owner_type" (
  "prf_owner_type_id" serial NOT NULL,
  "owner_table" character varying NOT NULL,
  "owner_resultset" character varying NOT NULL,
  PRIMARY KEY ("prf_owner_type_id"),
  CONSTRAINT "prf_owner_type__resultset" UNIQUE ("owner_resultset"),
  CONSTRAINT "prf_owner_type__table" UNIQUE ("owner_table")
);

;
--
-- Table: prf_defaults
--
CREATE TABLE "prf_defaults" (
  "prf_owner_type_id" integer NOT NULL,
  "name" character varying NOT NULL,
  "default_value" character varying NOT NULL,
  "data_type" character varying,
  "comment" character varying,
  "required" boolean DEFAULT '0',
  "active" boolean DEFAULT '1',
  "hidden" boolean,
  "audit" boolean,
  "display_on_search" boolean,
  "unique_field" boolean,
  "ajax_validate" boolean,
  "display_order" integer DEFAULT 1 NOT NULL,
  "confirmation_required" boolean,
  PRIMARY KEY ("prf_owner_type_id", "name")
);
CREATE INDEX "prf_defaults_idx_prf_owner_type_id" on "prf_defaults" ("prf_owner_type_id");

;
--
-- Table: prf_owners
--
CREATE TABLE "prf_owners" (
  "prf_owner_id" integer NOT NULL,
  "prf_owner_type_id" integer NOT NULL,
  PRIMARY KEY ("prf_owner_id", "prf_owner_type_id")
);
CREATE INDEX "prf_owners_idx_prf_owner_type_id" on "prf_owners" ("prf_owner_type_id");

;
--
-- Table: organisations
--
CREATE TABLE "organisations" (
  "code" text NOT NULL,
  "import_file" text,
  "created" timestamptz NOT NULL,
  "updated" timestamptz NOT NULL,
  "name" text,
  "national_grouping" text,
  "high_level_health_geography" text,
  "address1" text,
  "address2" text,
  "address3" text,
  "address4" text,
  "address5" text,
  "postcode" text,
  "open_date" text,
  "close_date" text,
  "organisation_sub_type_code" text,
  "parent_organisation_code" text,
  "join_parent_date" text,
  "left_parent_date" text,
  "contact_phone_number" text,
  "amended_record_indicator" text,
  "unknown1" text,
  "unknown2" text,
  "unknown3" text,
  "unknown4" text,
  "unknown5" text,
  "unknown6" text,
  "unknown7" text,
  "unknown8" text,
  "unknown9" text,
  "prf_id" serial NOT NULL,
  "prf_owner_type_id" integer,
  PRIMARY KEY ("code")
);
CREATE INDEX "organisations_idx_prf_id_prf_owner_type_id" on "organisations" ("prf_id", "prf_owner_type_id");
CREATE INDEX "organisations_idx_prf_owner_type_id" on "organisations" ("prf_owner_type_id");

;
--
-- Table: prf_default_values
--
CREATE TABLE "prf_default_values" (
  "id" serial NOT NULL,
  "value" text,
  "prf_owner_type_id" integer NOT NULL,
  "name" character varying NOT NULL,
  "display_order" integer DEFAULT 1 NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "prf_default_values_idx_prf_owner_type_id_name" on "prf_default_values" ("prf_owner_type_id", "name");

;
--
-- Table: prf_preferences
--
CREATE TABLE "prf_preferences" (
  "prf_preference_id" serial NOT NULL,
  "prf_owner_id" integer NOT NULL,
  "prf_owner_type_id" integer NOT NULL,
  "name" character varying NOT NULL,
  "value" character varying,
  PRIMARY KEY ("prf_preference_id"),
  CONSTRAINT "prf_preferences_prf_preference_id_prf_owner_type_id_name" UNIQUE ("prf_preference_id", "prf_owner_type_id", "name")
);
CREATE INDEX "prf_preferences_idx_prf_owner_id_prf_owner_type_id" on "prf_preferences" ("prf_owner_id", "prf_owner_type_id");

;
--
-- Table: people
--
CREATE TABLE "people" (
  "id" serial NOT NULL,
  "created" timestamp NOT NULL,
  "updated" timestamp NOT NULL,
  "username" character varying NOT NULL,
  "surname" character varying,
  "title" character varying,
  "first_name" character varying,
  "full_name" character varying,
  "email_address" character varying NOT NULL,
  "primary_organisation_id" text,
  "primary_organisation_other" text,
  "prf_owner_type_id" integer,
  "password_reset_hash" text,
  "password_reset_expiry" timestamp,
  PRIMARY KEY ("id")
);
CREATE INDEX "people_idx_id_prf_owner_type_id" on "people" ("id", "prf_owner_type_id");
CREATE INDEX "people_idx_prf_owner_type_id" on "people" ("prf_owner_type_id");
CREATE INDEX "people_idx_primary_organisation_id" on "people" ("primary_organisation_id");

;
--
-- Table: prf_unique_vals
--
CREATE TABLE "prf_unique_vals" (
  "id" serial NOT NULL,
  "value_id" integer NOT NULL,
  "value" text,
  "prf_owner_type_id" integer NOT NULL,
  "name" character varying NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "prf_unique_vals_value_id_prf_owner_type_id_name" UNIQUE ("value_id", "prf_owner_type_id", "name"),
  CONSTRAINT "prf_unique_vals_value_prf_owner_type_id_name" UNIQUE ("value", "prf_owner_type_id", "name")
);
CREATE INDEX "prf_unique_vals_idx_prf_owner_type_id_name" on "prf_unique_vals" ("prf_owner_type_id", "name");
CREATE INDEX "prf_unique_vals_idx_value_id_prf_owner_type_id_name" on "prf_unique_vals" ("value_id", "prf_owner_type_id", "name");

;
--
-- Table: secondary_organisation_links
--
CREATE TABLE "secondary_organisation_links" (
  "id" serial NOT NULL,
  "person_id" integer NOT NULL,
  "organisation_id" text NOT NULL,
  "created" timestamp NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "secondary_organisation_links_idx_organisation_id" on "secondary_organisation_links" ("organisation_id");
CREATE INDEX "secondary_organisation_links_idx_person_id" on "secondary_organisation_links" ("person_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "prf_defaults" ADD CONSTRAINT "prf_defaults_fk_prf_owner_type_id" FOREIGN KEY ("prf_owner_type_id")
  REFERENCES "prf_owner_type" ("prf_owner_type_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "prf_owners" ADD CONSTRAINT "prf_owners_fk_prf_owner_type_id" FOREIGN KEY ("prf_owner_type_id")
  REFERENCES "prf_owner_type" ("prf_owner_type_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "organisations" ADD CONSTRAINT "organisations_fk_prf_id_prf_owner_type_id" FOREIGN KEY ("prf_id", "prf_owner_type_id")
  REFERENCES "prf_owners" ("prf_owner_id", "prf_owner_type_id") DEFERRABLE;

;
ALTER TABLE "organisations" ADD CONSTRAINT "organisations_fk_prf_owner_type_id" FOREIGN KEY ("prf_owner_type_id")
  REFERENCES "prf_owner_type" ("prf_owner_type_id") DEFERRABLE;

;
ALTER TABLE "prf_default_values" ADD CONSTRAINT "prf_default_values_fk_prf_owner_type_id_name" FOREIGN KEY ("prf_owner_type_id", "name")
  REFERENCES "prf_defaults" ("prf_owner_type_id", "name") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "prf_preferences" ADD CONSTRAINT "prf_preferences_fk_prf_owner_id_prf_owner_type_id" FOREIGN KEY ("prf_owner_id", "prf_owner_type_id")
  REFERENCES "prf_owners" ("prf_owner_id", "prf_owner_type_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "people" ADD CONSTRAINT "people_fk_id_prf_owner_type_id" FOREIGN KEY ("id", "prf_owner_type_id")
  REFERENCES "prf_owners" ("prf_owner_id", "prf_owner_type_id") DEFERRABLE;

;
ALTER TABLE "people" ADD CONSTRAINT "people_fk_prf_owner_type_id" FOREIGN KEY ("prf_owner_type_id")
  REFERENCES "prf_owner_type" ("prf_owner_type_id") DEFERRABLE;

;
ALTER TABLE "people" ADD CONSTRAINT "people_fk_primary_organisation_id" FOREIGN KEY ("primary_organisation_id")
  REFERENCES "organisations" ("code") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "prf_unique_vals" ADD CONSTRAINT "prf_unique_vals_fk_prf_owner_type_id_name" FOREIGN KEY ("prf_owner_type_id", "name")
  REFERENCES "prf_defaults" ("prf_owner_type_id", "name") DEFERRABLE;

;
ALTER TABLE "prf_unique_vals" ADD CONSTRAINT "prf_unique_vals_fk_value_id_prf_owner_type_id_name" FOREIGN KEY ("value_id", "prf_owner_type_id", "name")
  REFERENCES "prf_preferences" ("prf_preference_id", "prf_owner_type_id", "name") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "secondary_organisation_links" ADD CONSTRAINT "secondary_organisation_links_fk_organisation_id" FOREIGN KEY ("organisation_id")
  REFERENCES "organisations" ("code") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "secondary_organisation_links" ADD CONSTRAINT "secondary_organisation_links_fk_person_id" FOREIGN KEY ("person_id")
  REFERENCES "people" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;

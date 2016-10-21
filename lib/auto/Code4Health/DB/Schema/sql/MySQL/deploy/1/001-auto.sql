-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Fri Oct 21 16:09:46 2016
-- 
;
SET foreign_key_checks=0;
--
-- Table: `email_verifications`
--
CREATE TABLE `email_verifications` (
  `hash` text NOT NULL,
  `expiry` timestamp NOT NULL,
  `email` text NOT NULL,
  PRIMARY KEY (`hash`)
);
--
-- Table: `prf_owner_type`
--
CREATE TABLE `prf_owner_type` (
  `prf_owner_type_id` integer NOT NULL auto_increment,
  `owner_table` varchar(255) NOT NULL,
  `owner_resultset` varchar(255) NOT NULL,
  PRIMARY KEY (`prf_owner_type_id`),
  UNIQUE `prf_owner_type__resultset` (`owner_resultset`),
  UNIQUE `prf_owner_type__table` (`owner_table`)
) ENGINE=InnoDB;
--
-- Table: `prf_defaults`
--
CREATE TABLE `prf_defaults` (
  `prf_owner_type_id` integer NOT NULL,
  `name` varchar(255) NOT NULL,
  `default_value` varchar(255) NOT NULL,
  `data_type` varchar(255) NULL,
  `comment` varchar(255) NULL,
  `required` enum('0','1') NULL DEFAULT '0',
  `active` enum('0','1') NULL DEFAULT '1',
  `hidden` enum('0','1') NULL,
  `audit` enum('0','1') NULL,
  `display_on_search` enum('0','1') NULL,
  `unique_field` enum('0','1') NULL,
  `ajax_validate` enum('0','1') NULL,
  `display_order` integer NOT NULL DEFAULT 1,
  `confirmation_required` enum('0','1') NULL,
  INDEX `prf_defaults_idx_prf_owner_type_id` (`prf_owner_type_id`),
  PRIMARY KEY (`prf_owner_type_id`, `name`),
  CONSTRAINT `prf_defaults_fk_prf_owner_type_id` FOREIGN KEY (`prf_owner_type_id`) REFERENCES `prf_owner_type` (`prf_owner_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `prf_owners`
--
CREATE TABLE `prf_owners` (
  `prf_owner_id` integer NOT NULL,
  `prf_owner_type_id` integer NOT NULL,
  INDEX `prf_owners_idx_prf_owner_type_id` (`prf_owner_type_id`),
  PRIMARY KEY (`prf_owner_id`, `prf_owner_type_id`),
  CONSTRAINT `prf_owners_fk_prf_owner_type_id` FOREIGN KEY (`prf_owner_type_id`) REFERENCES `prf_owner_type` (`prf_owner_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `organisations`
--
CREATE TABLE `organisations` (
  `code` text NOT NULL,
  `import_file` text NULL,
  `created` timestamptz NOT NULL,
  `updated` timestamptz NOT NULL,
  `name` text NULL,
  `national_grouping` text NULL,
  `high_level_health_geography` text NULL,
  `address1` text NULL,
  `address2` text NULL,
  `address3` text NULL,
  `address4` text NULL,
  `address5` text NULL,
  `postcode` text NULL,
  `open_date` text NULL,
  `close_date` text NULL,
  `organisation_sub_type_code` text NULL,
  `parent_organisation_code` text NULL,
  `join_parent_date` text NULL,
  `left_parent_date` text NULL,
  `contact_phone_number` text NULL,
  `amended_record_indicator` text NULL,
  `unknown1` text NULL,
  `unknown2` text NULL,
  `unknown3` text NULL,
  `unknown4` text NULL,
  `unknown5` text NULL,
  `unknown6` text NULL,
  `unknown7` text NULL,
  `unknown8` text NULL,
  `unknown9` text NULL,
  `prf_id` integer NOT NULL auto_increment,
  `prf_owner_type_id` integer NULL,
  INDEX `organisations_idx_prf_id_prf_owner_type_id` (`prf_id`, `prf_owner_type_id`),
  INDEX `organisations_idx_prf_owner_type_id` (`prf_owner_type_id`),
  PRIMARY KEY (`code`),
  CONSTRAINT `organisations_fk_prf_id_prf_owner_type_id` FOREIGN KEY (`prf_id`, `prf_owner_type_id`) REFERENCES `prf_owners` (`prf_owner_id`, `prf_owner_type_id`),
  CONSTRAINT `organisations_fk_prf_owner_type_id` FOREIGN KEY (`prf_owner_type_id`) REFERENCES `prf_owner_type` (`prf_owner_type_id`)
) ENGINE=InnoDB;
--
-- Table: `prf_default_values`
--
CREATE TABLE `prf_default_values` (
  `id` integer NOT NULL auto_increment,
  `value` text NULL,
  `prf_owner_type_id` integer NOT NULL,
  `name` varchar(255) NOT NULL,
  `display_order` integer NOT NULL DEFAULT 1,
  INDEX `prf_default_values_idx_prf_owner_type_id_name` (`prf_owner_type_id`, `name`),
  PRIMARY KEY (`id`),
  CONSTRAINT `prf_default_values_fk_prf_owner_type_id_name` FOREIGN KEY (`prf_owner_type_id`, `name`) REFERENCES `prf_defaults` (`prf_owner_type_id`, `name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `prf_preferences`
--
CREATE TABLE `prf_preferences` (
  `prf_preference_id` integer NOT NULL auto_increment,
  `prf_owner_id` integer NOT NULL,
  `prf_owner_type_id` integer NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NULL,
  INDEX `prf_preferences_idx_prf_owner_id_prf_owner_type_id` (`prf_owner_id`, `prf_owner_type_id`),
  PRIMARY KEY (`prf_preference_id`),
  UNIQUE `prf_preferences_prf_preference_id_prf_owner_type_id_name` (`prf_preference_id`, `prf_owner_type_id`, `name`),
  CONSTRAINT `prf_preferences_fk_prf_owner_id_prf_owner_type_id` FOREIGN KEY (`prf_owner_id`, `prf_owner_type_id`) REFERENCES `prf_owners` (`prf_owner_id`, `prf_owner_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `people`
--
CREATE TABLE `people` (
  `id` integer NOT NULL auto_increment,
  `created` timestamp NOT NULL,
  `updated` timestamp NOT NULL,
  `username` varchar(255) NOT NULL,
  `surname` varchar(255) NULL,
  `title` varchar(255) NULL,
  `first_name` varchar(255) NULL,
  `full_name` varchar(255) NULL,
  `email_address` varchar(255) NOT NULL,
  `primary_organisation_id` text NULL,
  `primary_organisation_other` text NULL,
  `prf_owner_type_id` integer NULL,
  `password_reset_hash` text NULL,
  `password_reset_expiry` timestamp NULL,
  INDEX `people_idx_id_prf_owner_type_id` (`id`, `prf_owner_type_id`),
  INDEX `people_idx_prf_owner_type_id` (`prf_owner_type_id`),
  INDEX `people_idx_primary_organisation_id` (`primary_organisation_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `people_fk_id_prf_owner_type_id` FOREIGN KEY (`id`, `prf_owner_type_id`) REFERENCES `prf_owners` (`prf_owner_id`, `prf_owner_type_id`),
  CONSTRAINT `people_fk_prf_owner_type_id` FOREIGN KEY (`prf_owner_type_id`) REFERENCES `prf_owner_type` (`prf_owner_type_id`),
  CONSTRAINT `people_fk_primary_organisation_id` FOREIGN KEY (`primary_organisation_id`) REFERENCES `organisations` (`code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `prf_unique_vals`
--
CREATE TABLE `prf_unique_vals` (
  `id` integer NOT NULL auto_increment,
  `value_id` integer NOT NULL,
  `value` text NULL,
  `prf_owner_type_id` integer NOT NULL,
  `name` varchar(255) NOT NULL,
  INDEX `prf_unique_vals_idx_prf_owner_type_id_name` (`prf_owner_type_id`, `name`),
  INDEX `prf_unique_vals_idx_value_id_prf_owner_type_id_name` (`value_id`, `prf_owner_type_id`, `name`),
  PRIMARY KEY (`id`),
  UNIQUE `prf_unique_vals_value_id_prf_owner_type_id_name` (`value_id`, `prf_owner_type_id`, `name`),
  UNIQUE `prf_unique_vals_value_prf_owner_type_id_name` (`value`, `prf_owner_type_id`, `name`),
  CONSTRAINT `prf_unique_vals_fk_prf_owner_type_id_name` FOREIGN KEY (`prf_owner_type_id`, `name`) REFERENCES `prf_defaults` (`prf_owner_type_id`, `name`),
  CONSTRAINT `prf_unique_vals_fk_value_id_prf_owner_type_id_name` FOREIGN KEY (`value_id`, `prf_owner_type_id`, `name`) REFERENCES `prf_preferences` (`prf_preference_id`, `prf_owner_type_id`, `name`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `secondary_organisation_links`
--
CREATE TABLE `secondary_organisation_links` (
  `id` integer NOT NULL auto_increment,
  `person_id` integer NOT NULL,
  `organisation_id` text NOT NULL,
  `created` timestamp NOT NULL,
  INDEX `secondary_organisation_links_idx_organisation_id` (`organisation_id`),
  INDEX `secondary_organisation_links_idx_person_id` (`person_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `secondary_organisation_links_fk_organisation_id` FOREIGN KEY (`organisation_id`) REFERENCES `organisations` (`code`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `secondary_organisation_links_fk_person_id` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;

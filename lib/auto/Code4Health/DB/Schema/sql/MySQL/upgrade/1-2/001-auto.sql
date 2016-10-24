-- Convert schema '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/1/001-auto.yml' to '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
SET foreign_key_checks=0;

;
CREATE TABLE `communities` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `created` timestamp NOT NULL,
  `updated` timestamp NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

;
CREATE TABLE `community_links` (
  `id` integer NOT NULL auto_increment,
  `person_id` integer NOT NULL,
  `community_id` integer NOT NULL,
  `created` timestamp NOT NULL,
  INDEX `community_links_idx_community_id` (`community_id`),
  INDEX `community_links_idx_person_id` (`person_id`),
  PRIMARY KEY (`id`),
  UNIQUE `comm_link` (`person_id`, `community_id`),
  CONSTRAINT `community_links_fk_community_id` FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `community_links_fk_person_id` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

;
SET foreign_key_checks=1;

;
ALTER TABLE people ADD COLUMN registrant_category text NULL,
                   ADD COLUMN registrant_category_other text NULL,
                   ADD COLUMN email_preferences text[] NULL,
                   ADD COLUMN show_membership enum('0','1') NOT NULL DEFAULT '0';

;

COMMIT;


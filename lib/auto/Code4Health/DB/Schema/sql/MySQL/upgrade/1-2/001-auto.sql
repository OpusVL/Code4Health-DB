-- Convert schema '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/1/001-auto.yml' to '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
DROP TABLE email_verifications;

;
DROP TABLE prf_owner_type;

;
ALTER TABLE prf_defaults DROP FOREIGN KEY prf_defaults_fk_prf_owner_type_id;

;
DROP TABLE prf_defaults;

;
ALTER TABLE prf_owners DROP FOREIGN KEY prf_owners_fk_prf_owner_type_id;

;
DROP TABLE prf_owners;

;
ALTER TABLE organisations DROP FOREIGN KEY organisations_fk_prf_id_prf_owner_type_id,
                          DROP FOREIGN KEY organisations_fk_prf_owner_type_id;

;
DROP TABLE organisations;

;
ALTER TABLE prf_default_values DROP FOREIGN KEY prf_default_values_fk_prf_owner_type_id_name;

;
DROP TABLE prf_default_values;

;
ALTER TABLE prf_preferences DROP FOREIGN KEY prf_preferences_fk_prf_owner_id_prf_owner_type_id;

;
DROP TABLE prf_preferences;

;
ALTER TABLE people DROP FOREIGN KEY people_fk_id_prf_owner_type_id,
                   DROP FOREIGN KEY people_fk_prf_owner_type_id,
                   DROP FOREIGN KEY people_fk_primary_organisation_id;

;
DROP TABLE people;

;
ALTER TABLE prf_unique_vals DROP FOREIGN KEY prf_unique_vals_fk_prf_owner_type_id_name,
                            DROP FOREIGN KEY prf_unique_vals_fk_value_id_prf_owner_type_id_name;

;
DROP TABLE prf_unique_vals;

;
ALTER TABLE secondary_organisation_links DROP FOREIGN KEY secondary_organisation_links_fk_organisation_id,
                                         DROP FOREIGN KEY secondary_organisation_links_fk_person_id;

;
DROP TABLE secondary_organisation_links;

;

COMMIT;


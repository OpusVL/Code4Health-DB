-- Convert schema '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/1/001-auto.yml' to '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
DROP TABLE email_verifications CASCADE;

;
DROP TABLE prf_owner_type CASCADE;

;
DROP TABLE prf_defaults CASCADE;

;
DROP TABLE prf_owners CASCADE;

;
DROP TABLE organisations CASCADE;

;
DROP TABLE prf_default_values CASCADE;

;
DROP TABLE prf_preferences CASCADE;

;
DROP TABLE people CASCADE;

;
DROP TABLE prf_unique_vals CASCADE;

;
DROP TABLE secondary_organisation_links CASCADE;

;

COMMIT;


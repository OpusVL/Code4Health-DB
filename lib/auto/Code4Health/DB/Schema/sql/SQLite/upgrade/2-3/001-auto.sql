-- Convert schema '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/2/001-auto.yml' to '/home/alastair.mcgowan/src/code4health/Code4Health/Code4Health-DB/lib/auto/Code4Health/DB/Schema/sql/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE people ADD COLUMN is_community_admin boolean NOT NULL DEFAULT 0;

;

COMMIT;


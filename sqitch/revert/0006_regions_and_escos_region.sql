-- Revert flows:0006_regions_and_escos_region from pg

BEGIN;

ALTER TABLE flows.escos DROP CONSTRAINT IF EXISTS esco_region_fkey;
DROP INDEX IF EXISTS flows.escos_region_idx;
ALTER TABLE flows.escos DROP COLUMN IF EXISTS region;
DROP TABLE IF EXISTS flows.regions;

COMMIT;
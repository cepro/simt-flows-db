-- Revert flows:0004_meter_shadows_clock_synced_at from pg

BEGIN;

ALTER TABLE flows.meter_shadows DROP COLUMN clock_time_diff_synced_at;

COMMIT;

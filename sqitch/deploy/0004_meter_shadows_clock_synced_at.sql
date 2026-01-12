-- Deploy flows:0004_meter_shadows_clock_synced_at to pg

BEGIN;

ALTER TABLE flows.meter_shadows ADD COLUMN clock_time_diff_synced_at timestamp with time zone;

COMMIT;

-- Verify flows:0004_meter_shadows_clock_synced_at on pg

BEGIN;

SELECT clock_time_diff_synced_at FROM flows.meter_shadows WHERE FALSE;

ROLLBACK;

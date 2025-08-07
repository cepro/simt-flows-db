-- Deploy flows:0003_meter_mode_active_default to pg

BEGIN;

ALTER TABLE flows.meter_registry ALTER COLUMN "mode" SET DEFAULT 'active'::flows."meter_mode_enum";

COMMIT;

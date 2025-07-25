BEGIN;

DROP TRIGGER meter_shadows_export_a_update ON flows.meter_shadows;
DROP TRIGGER meter_shadows_export_b_update ON flows.meter_shadows;
DROP TRIGGER meter_shadows_import_a_update ON flows.meter_shadows;
DROP TRIGGER meter_shadows_import_b_update ON flows.meter_shadows;

ALTER TABLE flows.meter_shadows ALTER COLUMN export_a TYPE float4 USING export_a::float4;
ALTER TABLE flows.meter_shadows ALTER COLUMN import_a TYPE float4 USING import_a::float4;
ALTER TABLE flows.meter_shadows ALTER COLUMN import_b TYPE float4 USING import_b::float4;
ALTER TABLE flows.meter_shadows ALTER COLUMN export_b TYPE float4 USING export_b::float4;

ALTER TABLE flows.register_export ALTER COLUMN "read" TYPE float4 USING "read"::float4;
ALTER TABLE flows.register_import ALTER COLUMN "read" TYPE float4 USING "read"::float4;

CREATE TRIGGER meter_shadows_export_a_update AFTER UPDATE OF export_a ON
    flows.meter_shadows for each row execute function flows.register_export_a_insert();
CREATE TRIGGER meter_shadows_export_b_update AFTER UPDATE OF export_b ON
    flows.meter_shadows for each row execute function flows.register_export_b_insert();
CREATE TRIGGER meter_shadows_import_a_update AFTER UPDATE OF import_a ON
    flows.meter_shadows for each row execute function flows.register_import_a_insert();
CREATE TRIGGER meter_shadows_import_b_update AFTER UPDATE OF import_b ON
    flows.meter_shadows for each row execute function flows.register_import_b_insert();

COMMIT;

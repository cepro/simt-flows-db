-- Deploy flows:0002_reads_insert_handle_no_register to pg

BEGIN;

-- Updated register_export_a_insert function
CREATE OR REPLACE FUNCTION flows.register_export_a_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    _register_id uuid;
BEGIN
    SELECT mr.register_id INTO _register_id
    FROM flows.meter_registers mr
    WHERE mr.meter_id = new.id AND mr.element = 'A';

    IF _register_id IS NULL THEN
        RAISE WARNING 'No register found for meter_id % element A - export_a insert 
skipped', new.id;
        RETURN new;
    END IF;

    INSERT INTO "flows"."register_export"(register_id, read, "timestamp")
    VALUES (_register_id, new.export_a, new.updated_at);

    RETURN new;
END;
$$;

-- Updated register_export_b_insert function
CREATE OR REPLACE FUNCTION flows.register_export_b_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    _register_id uuid;
BEGIN
    SELECT mr.register_id INTO _register_id
    FROM flows.meter_registers mr
    WHERE mr.meter_id = new.id AND mr.element = 'B';

    IF _register_id IS NULL THEN
        RAISE WARNING 'No register found for meter_id % element B - export_b insert 
skipped', new.id;
        RETURN new;
    END IF;

    INSERT INTO "flows"."register_export"(register_id, read, "timestamp")
    VALUES (_register_id, new.export_b, new.updated_at);

    RETURN new;
END;
$$;

-- Updated register_import_a_insert function
CREATE OR REPLACE FUNCTION flows.register_import_a_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    _register_id uuid;
BEGIN
    SELECT mr.register_id INTO _register_id
    FROM flows.meter_registers mr
    WHERE mr.meter_id = new.id AND mr.element = 'A';

    IF _register_id IS NULL THEN
        RAISE WARNING 'No register found for meter_id % element A - import_a insert 
skipped', new.id;
        RETURN new;
    END IF;

    INSERT INTO "flows"."register_import"(register_id, read, "timestamp")
    VALUES (_register_id, new.import_a, new.updated_at);

    RETURN new;
END;
$$;

-- Updated register_import_b_insert function
CREATE OR REPLACE FUNCTION flows.register_import_b_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    _register_id uuid;
BEGIN
    SELECT mr.register_id INTO _register_id
    FROM flows.meter_registers mr
    WHERE mr.meter_id = new.id AND mr.element = 'B';

    IF _register_id IS NULL THEN
        RAISE WARNING 'No register found for meter_id % element B - import_b insert 
skipped', new.id;
        RETURN new;
    END IF;

    INSERT INTO "flows"."register_import"(register_id, read, "timestamp")
    VALUES (_register_id, new.import_b, new.updated_at);

    RETURN new;
END;
$$;

COMMIT;

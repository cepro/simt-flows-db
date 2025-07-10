
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE EXTENSION IF NOT EXISTS timescaledb_toolkit with schema "extensions";

CREATE SCHEMA IF NOT EXISTS flows;


CREATE USER flows WITH PASSWORD :'flows_password';
CREATE USER grafanareader WITH PASSWORD :'grafanareader_password';
CREATE USER tableau WITH PASSWORD :'tableau_password';



CREATE TYPE flows.circuit_type_enum AS ENUM (
    'heat',
    'power',
    'solar'
);


CREATE TYPE flows.emnify_device_connectivity_status_enum AS ENUM (
    'online',
    'offline',
    'attached',
    'blocked'
);


CREATE TYPE flows.emnify_device_installation_status_enum AS ENUM (
    'enabled',
    'disabled',
    'deleted'
);


CREATE TYPE flows.health_check_status AS ENUM (
    'healthy',
    'unhealthy'
);


CREATE TYPE flows.meter_metric_run_frequency_enum AS ENUM (
    'hourly',
    'daily',
    '12hourly'
);


CREATE TYPE flows.meter_mode_enum AS ENUM (
    'active',
    'passive'
);



COMMENT ON TYPE flows.meter_mode_enum IS 'active - this meter will be kept in sync by calls to the actual hardware

passive (digital twin) - the meter will be kept in sync by syncing with another database that has the same meter in active mode';



CREATE TYPE flows.meter_register_element AS ENUM (
    'A',
    'B',
    'SINGLE'
);


CREATE TYPE flows.meter_register_status_enum AS ENUM (
    'enabled',
    'replaced'
);


CREATE TYPE flows.register_nature_enum AS ENUM (
    'heat',
    'power',
    'solar'
);


CREATE FUNCTION flows.meter_3p_voltage_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_3p_voltage"(meter_id, voltage_l1, voltage_l2, voltage_l3, "timestamp") VALUES (new.id, new."3p_voltage_l1", new."3p_voltage_l2", new."3p_voltage_l3", new.updated_at);
    return new;
END;
$$;


CREATE FUNCTION flows.meter_csq_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_csq"(meter_id, csq, "timestamp") VALUES (new.id, new.csq, new.updated_at);
    return new;
END;
$$;


CREATE FUNCTION flows.meter_health_history_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_health_history"(meter_id, health, "timestamp")
        VALUES (NEW.id, NEW.health, NEW.updated_at);
    IF NEW.health = 'healthy' THEN
        UPDATE "flows"."meter_shadows" 
            SET last_healthy_at = NEW.updated_at
            WHERE id = NEW.id;
    END IF;
    return NEW;

END;
$$;


CREATE FUNCTION flows.meter_prepay_balance_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_prepay_balance"(meter_id, balance, "timestamp") VALUES (new.id, new.balance, new.updated_at);
    return new;
END;
$$;


CREATE FUNCTION flows.meter_shadows_insert_new() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
	INSERT INTO flows.meter_shadows(id) VALUES (new.id);
	return new;
END;
$$;


CREATE FUNCTION flows.meter_voltage_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_voltage"(meter_id, voltage, "timestamp") VALUES (new.id, new.voltage, new.updated_at);
    return new;
END;
$$;


CREATE FUNCTION flows.refresh_register_interval_hh_missing(job_id integer DEFAULT NULL::integer, config jsonb DEFAULT NULL::jsonb) RETURNS void
    LANGUAGE sql
    AS $$
    REFRESH MATERIALIZED VIEW flows.register_interval_hh_missing;
$$;


CREATE FUNCTION flows.register_export_a_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
	INSERT INTO "flows"."register_export"(register_id, read, "timestamp") 
	VALUES (
	    (select mr.register_id from flows.meter_registers mr where mr.meter_id = new.id and mr.element = 'A'),
	    new.export_a,
	    new.updated_at
	);
    return new;
END;
$$;


CREATE FUNCTION flows.register_export_b_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
	INSERT INTO "flows"."register_export"(register_id, read, "timestamp") 
	VALUES (
	    (select mr.register_id from flows.meter_registers mr where mr.meter_id = new.id and mr.element = 'B'),
	    new.export_b,
	    new.updated_at
	);
    return new;
END;
$$;


CREATE FUNCTION flows.register_import_a_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
	INSERT INTO "flows"."register_import"(register_id, read, "timestamp") 
	VALUES (
	    (select mr.register_id from flows.meter_registers mr where mr.meter_id = new.id and mr.element = 'A'),
	    new.import_a,
	    new.updated_at
	);
    return new;
END;
$$;


CREATE FUNCTION flows.register_import_b_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
	INSERT INTO "flows"."register_import"(register_id, read, "timestamp") 
	VALUES (
	    (select mr.register_id from flows.meter_registers mr where mr.meter_id = new.id and mr.element = 'B'),
	    new.import_b,
	    new.updated_at
	);
    return new;
END;
$$;


CREATE FUNCTION flows.updated_at_now() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   -- statement_timestamp() NOT now() which is actually transaction_timestamp()
   -- in particular for pg_tap tests the timestamp won't move if using now()
   NEW.updated_at = statement_timestamp(); 
   RETURN NEW;
END;
$$;



SET default_tablespace = '';

SET default_table_access_method = heap;



CREATE TABLE flows.circuit_register (
    circuit uuid DEFAULT gen_random_uuid() NOT NULL,
    register uuid DEFAULT gen_random_uuid() NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    notes text,
    CONSTRAINT circuit_register_check_date_range CHECK (((start_time IS NULL) OR (end_time IS NULL) OR (end_time > start_time)))
);


CREATE TABLE flows.register_interval_hh (
    register_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    kwh numeric NOT NULL
);

ALTER TABLE flows.register_interval_hh 
ADD CONSTRAINT register_interval_hh_unique
UNIQUE (register_id, "timestamp");

SELECT public.create_hypertable('flows.register_interval_hh', 'timestamp');


CREATE MATERIALIZED VIEW flows.circuit_interval_hh
WITH (timescaledb.continuous) AS
SELECT cr.circuit AS circuit_id,
    time_bucket('00:30:00'::interval, ri."timestamp") AS "timestamp",
    sum(ri.kwh) AS kwh
   FROM (flows.circuit_register cr
     JOIN flows.register_interval_hh ri ON ((ri.register_id = cr.register)))
  WHERE ((ri."timestamp" >= cr.start_time) AND ((ri."timestamp" < cr.end_time) OR (cr.end_time IS NULL)))
  GROUP BY cr.circuit, (time_bucket('00:30:00'::interval, ri."timestamp"));



CREATE MATERIALIZED VIEW flows.circuit_interval_daily
WITH (timescaledb.continuous) AS
SELECT circuit_interval_hh.circuit_id,
    time_bucket('1 day'::interval, circuit_interval_hh."timestamp") AS day,
    sum(circuit_interval_hh.kwh) AS kwh
   FROM flows.circuit_interval_hh
  GROUP BY circuit_interval_hh.circuit_id, (time_bucket('1 day'::interval, circuit_interval_hh."timestamp"));


CREATE TABLE flows.meter_csq (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    csq integer
);


CREATE TABLE flows.meter_health_history (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    health flows.health_check_status NOT NULL
);


CREATE TABLE flows.meter_voltage (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    voltage real
);


CREATE TABLE flows.meter_3p_voltage (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    voltage_l1 real,
    voltage_l2 real,
    voltage_l3 real
);


CREATE TABLE flows.meter_prepay_balance (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    balance numeric
);


SELECT public.create_hypertable('flows.meter_csq', 'timestamp');
SELECT public.create_hypertable('flows.meter_health_history', 'timestamp');
SELECT public.create_hypertable('flows.meter_voltage', 'timestamp');
SELECT public.create_hypertable('flows.meter_3p_voltage', 'timestamp');
SELECT public.create_hypertable('flows.meter_prepay_balance', 'timestamp');



CREATE MATERIALIZED VIEW flows.circuit_interval_monthly
WITH (timescaledb.continuous) AS
SELECT circuit_interval_daily.circuit_id,
    time_bucket('1 mon'::interval, circuit_interval_daily.day) AS month,
    sum(circuit_interval_daily.kwh) AS kwh
   FROM flows.circuit_interval_daily
  GROUP BY circuit_interval_daily.circuit_id, (time_bucket('1 mon'::interval, circuit_interval_daily.day));


CREATE TABLE flows.circuits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type flows.circuit_type_enum NOT NULL,
    name text,
    created_at timestamp with time zone DEFAULT now()
);


CREATE TABLE flows.escos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text,
    code text,
    app_url text
);


CREATE TABLE flows.ev_chargers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    esco uuid NOT NULL,
    serial text NOT NULL,
    pin text NOT NULL,
    "position" text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chargers_pin_check CHECK ((length(pin) = 4)),
    CONSTRAINT chargers_serial_check CHECK ((length(serial) = 8))
);


CREATE TABLE flows.feeder_registry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    esco uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);



CREATE TABLE flows.meter_event_log (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    event_type integer NOT NULL,
    event_set integer NOT NULL
);



COMMENT ON TABLE flows.meter_event_log IS 'Log of events inside each meter. see section 2.5 of the specification "Meter and Smart Module Obis Commands".';


COMMENT ON COLUMN flows.meter_event_log.event_type IS 'Corresponds to meter_event_log_type although we don''t yet have a foreign key as there at this stge some unknown types';


COMMENT ON COLUMN flows.meter_event_log.event_set IS 'Incrementing count corresponding to the event_type';



CREATE TABLE flows.meter_event_log_type (
    id integer NOT NULL,
    name text NOT NULL
);


CREATE TABLE flows.meter_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    notes text,
    enabled boolean NOT NULL,
    run_frequency flows.meter_metric_run_frequency_enum NOT NULL
);


CREATE TABLE flows.meter_registers (
    register_id uuid NOT NULL,
    meter_id uuid NOT NULL,
    nature flows.register_nature_enum,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    status flows.meter_register_status_enum DEFAULT 'enabled'::flows.meter_register_status_enum,
    element flows.meter_register_element,
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    notes text,
    CONSTRAINT meter_registers_check_date_range CHECK (((end_time IS NULL) OR (start_time IS NULL) OR (end_time > start_time)))
);


CREATE TABLE flows.meter_registry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    serial text,
    emnify_id integer,
    ip_address inet,
    name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    installation_status flows.emnify_device_installation_status_enum,
    commissioned_iso_week_date text,
    hardware text,
    prepay_enabled boolean,
    iccid text,
    site uuid,
    mode flows.meter_mode_enum,
    firmware_version text,
    esco uuid,
    daylight_savings_correction_enabled boolean,
    single_meter_app boolean DEFAULT false NOT NULL
);



COMMENT ON COLUMN flows.meter_registry.mode IS 'see comments on the meter_mode_enum type for details';


COMMENT ON COLUMN flows.meter_registry.daylight_savings_correction_enabled IS 'Is daylight savings correction mode enabled? If checked than BST timezone will be used in summer for things like the future tariffs activation timestamp.';


COMMENT ON COLUMN flows.meter_registry.single_meter_app IS 'If deployed as a single meter in a single app. As opposed to multiple meters per app as we do with most esco deployments. Single meter app is to expose the app publicly and use mutual tls auth to connect.';



CREATE TABLE flows.meter_shadows (
    id uuid NOT NULL,
    balance numeric,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    clock_time_diff_seconds integer,
    csq integer,
    emnify_connectivity_status flows.emnify_device_connectivity_status_enum,
    health flows.health_check_status,
    health_details text,
    last_healthy_at timestamp with time zone,
    "3p_voltage_l1" real,
    "3p_voltage_l2" real,
    "3p_voltage_l3" real,
    voltage numeric,
    import_a bigint,
    export_a bigint,
    import_b bigint,
    export_b bigint,
    tariffs_active jsonb,
    tariffs_future jsonb,
    backlight text,
    load_switch text
);


CREATE VIEW flows.meter_shadows_tariffs AS
 SELECT ms.id,
    mr.serial,
    ((ms.tariffs_active ->> 'standing_charge'::text))::numeric AS active_standing_charge,
    ((ms.tariffs_active ->> 'unit_rate_element_a'::text))::numeric AS active_unit_rate_a,
    ((ms.tariffs_active ->> 'unit_rate_element_b'::text))::numeric AS active_unit_rate_b,
    ((ms.tariffs_active ->> 'prepayment_ecredit_availability'::text))::numeric AS active_ecredit_availability,
    ((ms.tariffs_active ->> 'prepayment_debt_recovery_rate'::text))::numeric AS active_debt_recovery_rate,
    ((ms.tariffs_active ->> 'prepayment_emergency_credit'::text))::numeric AS active_emergency_credit,
    ((ms.tariffs_future ->> 'standing_charge'::text))::numeric AS future_standing_charge,
    ((ms.tariffs_future ->> 'unit_rate_element_a'::text))::numeric AS future_unit_rate_a,
    ((ms.tariffs_future ->> 'unit_rate_element_b'::text))::numeric AS future_unit_rate_b,
    ((ms.tariffs_future ->> 'activation_datetime'::text))::timestamp without time zone AS future_activation_datetime,
    ((ms.tariffs_future ->> 'prepayment_ecredit_availability'::text))::numeric AS future_ecredit_availability,
    ((ms.tariffs_future ->> 'prepayment_debt_recovery_rate'::text))::numeric AS future_debt_recovery_rate,
    ((ms.tariffs_future ->> 'prepayment_emergency_credit'::text))::numeric AS future_emergency_credit
   FROM flows.meter_shadows ms,
    flows.meter_registry mr
  WHERE ((ms.id = mr.id) AND (mr.hardware <> 'P1.ax'::text));


CREATE TABLE flows.meter_tophat_registry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    meter uuid NOT NULL,
    emnify_id integer,
    ip_address inet,
    iccid text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


CREATE VIEW flows.meters_clock_drift AS
 SELECT ms.clock_time_diff_seconds,
    mr.serial,
    mr.name
   FROM flows.meter_shadows ms,
    flows.meter_registry mr
  WHERE ((ms.clock_time_diff_seconds >= 60) AND (ms.id = mr.id))
  ORDER BY ms.clock_time_diff_seconds DESC;


CREATE VIEW flows.meters_low_balance AS
 SELECT mr.id,
    mr.serial,
    mr.name,
    ms.balance
   FROM flows.meter_shadows ms,
    flows.meter_registry mr
  WHERE ((ms.id = mr.id) AND (mr.prepay_enabled IS TRUE) AND (ms.balance < 15.0));


CREATE VIEW flows.meters_offline_all AS
 SELECT max(mc."timestamp") AS last_online,
    mr.serial,
    mr.name
   FROM flows.meter_csq mc,
    flows.meter_registry mr
  WHERE ((mc.csq IS NOT NULL) AND (mc.meter_id = mr.id))
  GROUP BY mr.serial, mr.name
 HAVING (max(mc."timestamp") < (now() - '03:00:00'::interval))
  ORDER BY (max(mc."timestamp"));


CREATE VIEW flows.meters_offline_recently AS
 SELECT max(mc."timestamp") AS last_online,
    mr.serial,
    mr.name
   FROM flows.meter_csq mc,
    flows.meter_registry mr
  WHERE ((mc.csq IS NOT NULL) AND (mc.meter_id = mr.id))
  GROUP BY mr.serial, mr.name
 HAVING ((max(mc."timestamp") < (now() - '03:00:00'::interval)) AND (max(mc."timestamp") > (now() - '24:00:00'::interval)))
  ORDER BY (max(mc."timestamp"));




CREATE TABLE flows.properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    plot text,
    created_at timestamp with time zone DEFAULT now()
);


CREATE TABLE flows.properties_service_head (
    property uuid NOT NULL,
    service_head uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


CREATE TABLE flows.register_export (
    register_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    read bigint
);



COMMENT ON TABLE flows.register_export IS 'Periodically import and export reads are read from the meters and updated in meter_shadows. This table tracks the history of export reads.';



CREATE TABLE flows.register_import (
    register_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    read bigint
);



COMMENT ON TABLE flows.register_import IS 'Periodically import and export reads are read from the meters and updated in meter_shadows. This table tracks the history of import reads.';



CREATE MATERIALIZED VIEW flows.register_interval_hh_missing AS
 WITH date_range AS (
         SELECT generate_series((date_trunc('day'::text, (CURRENT_DATE - '1 year'::interval)))::timestamp with time zone, date_trunc('day'::text, (CURRENT_DATE)::timestamp with time zone), '1 day'::interval) AS day
        ), expected_counts AS (
         SELECT meter_registers.register_id,
            date_trunc('day'::text, date_range.day) AS date,
            48 AS expected_count
           FROM (flows.meter_registers
             CROSS JOIN date_range)
        ), actual_counts AS (
         SELECT register_interval_hh.register_id,
            date_trunc('day'::text, register_interval_hh."timestamp") AS date,
            count(*) AS actual_count
           FROM flows.register_interval_hh
          WHERE ((register_interval_hh."timestamp" >= (CURRENT_DATE - '1 year'::interval)) AND (register_interval_hh."timestamp" < CURRENT_DATE))
          GROUP BY register_interval_hh.register_id, (date_trunc('day'::text, register_interval_hh."timestamp"))
        )
 SELECT e.register_id,
    e.date,
    COALESCE(a.actual_count, (0)::bigint) AS record_count,
    (e.expected_count - COALESCE(a.actual_count, (0)::bigint)) AS missing_count
   FROM (expected_counts e
     LEFT JOIN actual_counts a ON (((e.register_id = a.register_id) AND (e.date = a.date))))
  ORDER BY e.register_id, e.date
  WITH NO DATA;


CREATE TABLE flows.service_head_meter (
    service_head uuid NOT NULL,
    meter uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


CREATE TABLE flows.service_head_registry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    feeder uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    phase integer,
    fuse_rating smallint,
    type text,
    CONSTRAINT service_head_registry_phase_check CHECK ((phase = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT service_head_registry_type_check CHECK (((type IS NULL) OR (type = 'customer_owned'::text) OR (type = 'network_owned'::text)))
);


CREATE TABLE flows.sites_new (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    code text,
    esco uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);



COMMENT ON TABLE flows.sites_new IS 'An ESCO can have one more sites defined in this table. The site groups meters under a single boundary settlement meter.';



ALTER TABLE ONLY flows.ev_chargers
    ADD CONSTRAINT chargers_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.circuits
    ADD CONSTRAINT circuit_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.circuit_register
    ADD CONSTRAINT circuit_registers_pkey PRIMARY KEY (circuit, register, start_time);



ALTER TABLE ONLY flows.escos
    ADD CONSTRAINT escos_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.escos
    ADD CONSTRAINT escos_unique_code UNIQUE (code);



ALTER TABLE ONLY flows.feeder_registry
    ADD CONSTRAINT feeder_registry_name_unique UNIQUE (name);



ALTER TABLE ONLY flows.feeder_registry
    ADD CONSTRAINT feeder_registry_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.meter_event_log_type
    ADD CONSTRAINT meter_event_log_type_name_unique UNIQUE (name);



ALTER TABLE ONLY flows.meter_event_log_type
    ADD CONSTRAINT meter_event_log_type_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.meter_event_log
    ADD CONSTRAINT meter_event_type_pkey PRIMARY KEY (meter_id, "timestamp", event_type);



ALTER TABLE ONLY flows.meter_metrics
    ADD CONSTRAINT meter_metrics_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.meter_registers
    ADD CONSTRAINT meter_registers_pkey PRIMARY KEY (register_id);



ALTER TABLE ONLY flows.meter_registers
    ADD CONSTRAINT meter_registers_register_id_meter_id_unique UNIQUE (register_id, meter_id);



ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meter_registry_iccid_unique UNIQUE (iccid);



ALTER TABLE ONLY flows.meter_shadows
    ADD CONSTRAINT meter_shadows_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_emnify_id_unique UNIQUE (emnify_id);



ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_iccid_unique UNIQUE (iccid);



ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_ip_address_unique UNIQUE (ip_address);



ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_emnify_id_unique UNIQUE (emnify_id);



ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_ip_address_unique UNIQUE (ip_address);



ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_serial_unique UNIQUE (serial);



ALTER TABLE ONLY flows.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.properties_service_head
    ADD CONSTRAINT properties_service_head_pkey PRIMARY KEY (property, service_head);



ALTER TABLE ONLY flows.register_export
    ADD CONSTRAINT register_export_unique UNIQUE (register_id, "timestamp");



ALTER TABLE ONLY flows.register_import
    ADD CONSTRAINT register_import_unique UNIQUE (register_id, "timestamp");



ALTER TABLE ONLY flows.service_head_meter
    ADD CONSTRAINT service_head_pkey PRIMARY KEY (service_head, meter);



ALTER TABLE ONLY flows.service_head_registry
    ADD CONSTRAINT service_head_registry_name_unique UNIQUE (name);



ALTER TABLE ONLY flows.service_head_registry
    ADD CONSTRAINT service_head_registry_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.sites_new
    ADD CONSTRAINT sites_new_pkey PRIMARY KEY (id);



ALTER TABLE ONLY flows.sites_new
    ADD CONSTRAINT sites_new_unique_code UNIQUE (code);




CREATE UNIQUE INDEX meter_csq_meter_time_idx ON flows.meter_csq USING btree (meter_id, "timestamp");



CREATE INDEX meter_interval_hh_timestamp_idx ON flows.register_interval_hh USING btree ("timestamp" DESC);



CREATE UNIQUE INDEX meter_prepay_balance_meter_time_idx ON flows.meter_prepay_balance USING btree (meter_id, "timestamp");




CREATE TRIGGER chargers_updated_at BEFORE UPDATE ON flows.ev_chargers FOR EACH ROW EXECUTE FUNCTION flows.updated_at_now();



CREATE TRIGGER meter_registry_insert_shadow AFTER INSERT ON flows.meter_registry FOR EACH ROW EXECUTE FUNCTION flows.meter_shadows_insert_new();



CREATE TRIGGER meter_registry_updated_at BEFORE UPDATE ON flows.meter_registry FOR EACH ROW EXECUTE FUNCTION flows.updated_at_now();



CREATE TRIGGER meter_shadows_3p_voltage_update AFTER UPDATE OF "3p_voltage_l1", "3p_voltage_l2", "3p_voltage_l3" ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_3p_voltage_insert();



CREATE TRIGGER meter_shadows_csq_update AFTER UPDATE OF csq ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_csq_insert();



CREATE TRIGGER meter_shadows_export_a_update AFTER UPDATE OF export_a ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_export_a_insert();



CREATE TRIGGER meter_shadows_export_b_update AFTER UPDATE OF export_b ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_export_b_insert();



CREATE TRIGGER meter_shadows_health_update AFTER UPDATE OF health ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_health_history_insert();



CREATE TRIGGER meter_shadows_import_a_update AFTER UPDATE OF import_a ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_import_a_insert();



CREATE TRIGGER meter_shadows_import_b_update AFTER UPDATE OF import_b ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_import_b_insert();



CREATE TRIGGER meter_shadows_prepay_balance_update AFTER UPDATE OF balance ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_prepay_balance_insert();



CREATE TRIGGER meter_shadows_updated_at BEFORE UPDATE ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.updated_at_now();



CREATE TRIGGER meter_shadows_voltage_update AFTER UPDATE OF voltage ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_voltage_insert();



ALTER TABLE ONLY flows.ev_chargers
    ADD CONSTRAINT chargers_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id);



ALTER TABLE ONLY flows.circuit_register
    ADD CONSTRAINT circuit_registers_circuit_fkey FOREIGN KEY (circuit) REFERENCES flows.circuits(id);



ALTER TABLE ONLY flows.circuit_register
    ADD CONSTRAINT circuit_registers_register_fkey FOREIGN KEY (register) REFERENCES flows.meter_registers(register_id);



ALTER TABLE ONLY flows.feeder_registry
    ADD CONSTRAINT feeder_registry_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE flows.meter_3p_voltage
    ADD CONSTRAINT meter_3p_voltage_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE flows.meter_csq
    ADD CONSTRAINT meter_csq_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT;



ALTER TABLE ONLY flows.meter_event_log
    ADD CONSTRAINT meter_event_log_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE flows.meter_health_history
    ADD CONSTRAINT meter_health_history_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE flows.register_interval_hh
    ADD CONSTRAINT meter_interval_register_id_fkey FOREIGN KEY (register_id) REFERENCES flows.meter_registers(register_id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE flows.meter_prepay_balance
    ADD CONSTRAINT meter_prepay_balance_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT;



ALTER TABLE ONLY flows.meter_registers
    ADD CONSTRAINT meter_registers_meter_registry_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id);



ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meter_registry_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.meter_shadows
    ADD CONSTRAINT meter_shadows_meters_registry_fkey FOREIGN KEY (id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_meter_fkey FOREIGN KEY (meter) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE flows.meter_voltage
    ADD CONSTRAINT meter_voltage_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.properties_service_head
    ADD CONSTRAINT properties_service_head_properties_fkey FOREIGN KEY (property) REFERENCES flows.properties(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.properties_service_head
    ADD CONSTRAINT properties_service_head_service_head_fkey FOREIGN KEY (service_head) REFERENCES flows.service_head_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.register_export
    ADD CONSTRAINT register_export_meter_id_fkey FOREIGN KEY (register_id) REFERENCES flows.meter_registers(register_id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.register_import
    ADD CONSTRAINT register_import_meter_id_fkey FOREIGN KEY (register_id) REFERENCES flows.meter_registers(register_id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.service_head_meter
    ADD CONSTRAINT service_head_meter_meter_fkey FOREIGN KEY (meter) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.service_head_meter
    ADD CONSTRAINT service_head_meter_service_head_fkey FOREIGN KEY (service_head) REFERENCES flows.service_head_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.service_head_registry
    ADD CONSTRAINT service_head_registry_feeder_fkey FOREIGN KEY (feeder) REFERENCES flows.feeder_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY flows.sites_new
    ADD CONSTRAINT sites_new_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


SELECT add_job(
    'flows.refresh_register_interval_hh_missing', 
    '1d', 
    -- first run is 3am the day after the migration is run:
    initial_start => (date_trunc('day', now()) + interval '27 hours')::timestamptz);



GRANT USAGE ON SCHEMA flows TO flows;
GRANT USAGE ON SCHEMA flows TO grafanareader;
GRANT USAGE ON SCHEMA flows TO tableau;



GRANT SELECT ON TABLE flows.circuit_register TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_register TO flows;
GRANT SELECT ON TABLE flows.circuit_register TO tableau;



GRANT SELECT ON TABLE flows.register_interval_hh TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_interval_hh TO flows;
GRANT SELECT ON TABLE flows.register_interval_hh TO tableau;



GRANT SELECT ON TABLE flows.circuit_interval_hh TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_interval_hh TO flows;
GRANT SELECT ON TABLE flows.circuit_interval_hh TO tableau;



GRANT SELECT ON TABLE flows.circuit_interval_daily TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_interval_daily TO flows;
GRANT SELECT ON TABLE flows.circuit_interval_daily TO tableau;



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_csq TO flows;
GRANT SELECT ON TABLE flows.meter_csq TO grafanareader;
GRANT SELECT ON TABLE flows.meter_csq TO tableau;



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_health_history TO flows;
GRANT SELECT ON TABLE flows.meter_health_history TO grafanareader;
GRANT SELECT ON TABLE flows.meter_health_history TO tableau;



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_voltage TO flows;
GRANT SELECT ON TABLE flows.meter_voltage TO grafanareader;
GRANT SELECT ON TABLE flows.meter_voltage TO tableau;



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_3p_voltage TO flows;
GRANT SELECT ON TABLE flows.meter_3p_voltage TO grafanareader;
GRANT SELECT ON TABLE flows.meter_3p_voltage TO tableau;



GRANT SELECT ON TABLE flows.meter_prepay_balance TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_prepay_balance TO flows;
GRANT SELECT ON TABLE flows.meter_prepay_balance TO tableau;



GRANT SELECT ON TABLE flows.circuit_interval_monthly TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_interval_monthly TO flows;
GRANT SELECT ON TABLE flows.circuit_interval_monthly TO tableau;



GRANT SELECT ON TABLE flows.circuits TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuits TO flows;
GRANT SELECT ON TABLE flows.circuits TO tableau;



GRANT SELECT ON TABLE flows.escos TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.escos TO flows;
GRANT SELECT ON TABLE flows.escos TO tableau;



GRANT SELECT ON TABLE flows.ev_chargers TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.ev_chargers TO flows;
GRANT SELECT ON TABLE flows.ev_chargers TO tableau;



GRANT SELECT ON TABLE flows.feeder_registry TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.feeder_registry TO flows;
GRANT SELECT ON TABLE flows.feeder_registry TO tableau;




GRANT SELECT ON TABLE flows.meter_event_log TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_event_log TO flows;
GRANT SELECT ON TABLE flows.meter_event_log TO tableau;



GRANT SELECT ON TABLE flows.meter_event_log_type TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_event_log_type TO flows;
GRANT SELECT ON TABLE flows.meter_event_log_type TO tableau;



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_metrics TO flows;
GRANT SELECT ON TABLE flows.meter_metrics TO tableau;



GRANT SELECT ON TABLE flows.meter_registers TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_registers TO flows;
GRANT SELECT ON TABLE flows.meter_registers TO tableau;



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_registry TO flows;
GRANT SELECT ON TABLE flows.meter_registry TO grafanareader;
GRANT SELECT ON TABLE flows.meter_registry TO tableau;



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_shadows TO flows;
GRANT SELECT ON TABLE flows.meter_shadows TO grafanareader;
GRANT SELECT ON TABLE flows.meter_shadows TO tableau;



GRANT SELECT ON TABLE flows.meter_shadows_tariffs TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_shadows_tariffs TO flows;
GRANT SELECT ON TABLE flows.meter_shadows_tariffs TO tableau;



GRANT SELECT ON TABLE flows.meter_tophat_registry TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_tophat_registry TO flows;
GRANT SELECT ON TABLE flows.meter_tophat_registry TO tableau;



GRANT SELECT ON TABLE flows.meters_clock_drift TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_clock_drift TO flows;
GRANT SELECT ON TABLE flows.meters_clock_drift TO tableau;



GRANT SELECT ON TABLE flows.meters_low_balance TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_low_balance TO flows;
GRANT SELECT ON TABLE flows.meters_low_balance TO tableau;



GRANT SELECT ON TABLE flows.meters_offline_all TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_offline_all TO flows;
GRANT SELECT ON TABLE flows.meters_offline_all TO tableau;



GRANT SELECT ON TABLE flows.meters_offline_recently TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_offline_recently TO flows;
GRANT SELECT ON TABLE flows.meters_offline_recently TO tableau;




GRANT SELECT ON TABLE flows.properties TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.properties TO flows;
GRANT SELECT ON TABLE flows.properties TO tableau;



GRANT SELECT ON TABLE flows.properties_service_head TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.properties_service_head TO flows;
GRANT SELECT ON TABLE flows.properties_service_head TO tableau;



GRANT SELECT ON TABLE flows.register_export TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_export TO flows;
GRANT SELECT ON TABLE flows.register_export TO tableau;



GRANT SELECT ON TABLE flows.register_import TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_import TO flows;
GRANT SELECT ON TABLE flows.register_import TO tableau;



GRANT SELECT ON TABLE flows.register_interval_hh_missing TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_interval_hh_missing TO flows;
GRANT SELECT ON TABLE flows.register_interval_hh_missing TO tableau;



GRANT SELECT ON TABLE flows.service_head_meter TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.service_head_meter TO flows;
GRANT SELECT ON TABLE flows.service_head_meter TO tableau;



GRANT SELECT ON TABLE flows.service_head_registry TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.service_head_registry TO flows;
GRANT SELECT ON TABLE flows.service_head_registry TO tableau;



GRANT SELECT ON TABLE flows.sites_new TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.sites_new TO flows;
GRANT SELECT ON TABLE flows.sites_new TO tableau;


BEGIN;

-- if local add this function for half hourly data generation from seed.sql

SELECT (:'env' = 'local') AS is_local \gset
\if :is_local
    DO $$
    BEGIN
        CREATE OR REPLACE FUNCTION flows.generate_register_intervals(
            p_register_id UUID,
            p_start_time TIMESTAMPTZ,
            p_end_time TIMESTAMPTZ,
            p_min_kwh NUMERIC,
            p_max_kwh NUMERIC
        )
        RETURNS VOID AS $function$
        DECLARE
            v_current_time TIMESTAMPTZ;
            v_random_kwh NUMERIC;
        BEGIN
            v_current_time := p_start_time;
            
            WHILE v_current_time <= p_end_time LOOP
                -- Generate a random kWh value within the specified range
                v_random_kwh := p_min_kwh + (random() * (p_max_kwh - p_min_kwh));
                
                -- Insert the row
                INSERT INTO flows.register_interval_hh (register_id, "timestamp", kwh)
                VALUES (p_register_id, v_current_time, v_random_kwh)
                ON CONFLICT (register_id, "timestamp") DO NOTHING;
                
                -- Move to the next half-hour
                v_current_time := v_current_time + INTERVAL '30 minutes';
            END LOOP;
        END;
        $function$ LANGUAGE plpgsql;
        END;
    $$;
\endif

COMMIT;


CREATE FUNCTION flows.get_meters_for_cli(esco_filter text, feeder_filter text) RETURNS TABLE(id uuid, ip_address text, serial text, name text, esco text, csq integer, health text, hardware text, feeder text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
		SELECT 
			mr.id as id, host(mr.ip_address) as ip_address,
			mr.serial as serial,
			mr.name as name, 
			e.code as esco,
			ms.csq as csq,
			ms.health::text as health,
			mr.hardware as hardware,
			fr."name" 
		FROM 
			flows.meter_registry mr
			JOIN flows.meter_shadows ms ON mr.id = ms.id
			LEFT JOIN flows.escos e ON mr.esco = e.id
			LEFT JOIN flows.service_head_meter shm ON mr.id = shm.meter
			LEFT JOIN flows.service_head_registry shr ON shr.id = shm.service_head
			LEFT JOIN flows.feeder_registry fr ON shr.feeder = fr.id
		WHERE 
			(esco_filter is null OR e.code = esco_filter) AND
			mr.mode = 'active' AND
			(feeder_filter is null OR fr.name = feeder_filter OR (feeder_filter = 'null' AND shr.feeder IS NULL));
	END;
	$$;


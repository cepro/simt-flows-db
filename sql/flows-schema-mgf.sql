--
-- PostgreSQL database dump
--

-- Dumped from database version 17.6 (Ubuntu 17.6-2.pgdg22.04+1)
-- Dumped by pg_dump version 17.5

-- Started on 2026-01-07 23:34:59 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY flows.sites_new DROP CONSTRAINT IF EXISTS sites_new_esco_fkey;
ALTER TABLE IF EXISTS ONLY flows.service_head_registry DROP CONSTRAINT IF EXISTS service_head_registry_feeder_fkey;
ALTER TABLE IF EXISTS ONLY flows.service_head_meter DROP CONSTRAINT IF EXISTS service_head_meter_service_head_fkey;
ALTER TABLE IF EXISTS ONLY flows.service_head_meter DROP CONSTRAINT IF EXISTS service_head_meter_meter_fkey;
ALTER TABLE IF EXISTS ONLY flows.register_import DROP CONSTRAINT IF EXISTS register_import_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.register_export DROP CONSTRAINT IF EXISTS register_export_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.properties_service_head DROP CONSTRAINT IF EXISTS properties_service_head_service_head_fkey;
ALTER TABLE IF EXISTS ONLY flows.properties_service_head DROP CONSTRAINT IF EXISTS properties_service_head_properties_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_voltage DROP CONSTRAINT IF EXISTS meter_voltage_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_tophat_registry DROP CONSTRAINT IF EXISTS meter_tophat_registry_meter_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_shadows DROP CONSTRAINT IF EXISTS meter_shadows_meters_registry_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_registry DROP CONSTRAINT IF EXISTS meter_registry_esco_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_registers DROP CONSTRAINT IF EXISTS meter_registers_meter_registry_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_prepay_balance DROP CONSTRAINT IF EXISTS meter_prepay_balance_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.register_interval_hh DROP CONSTRAINT IF EXISTS meter_interval_register_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_health_history DROP CONSTRAINT IF EXISTS meter_health_history_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_event_log DROP CONSTRAINT IF EXISTS meter_event_log_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_csq DROP CONSTRAINT IF EXISTS meter_csq_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.meter_3p_voltage DROP CONSTRAINT IF EXISTS meter_3p_voltage_meter_id_fkey;
ALTER TABLE IF EXISTS ONLY flows.feeder_registry DROP CONSTRAINT IF EXISTS feeder_registry_esco_fkey;
ALTER TABLE IF EXISTS ONLY flows.circuit_register DROP CONSTRAINT IF EXISTS circuit_registers_register_fkey;
ALTER TABLE IF EXISTS ONLY flows.circuit_register DROP CONSTRAINT IF EXISTS circuit_registers_circuit_fkey;
ALTER TABLE IF EXISTS ONLY flows.ev_chargers DROP CONSTRAINT IF EXISTS chargers_esco_fkey;
DROP TRIGGER IF EXISTS meter_shadows_voltage_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_updated_at ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_prepay_balance_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_import_b_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_import_a_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_health_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_export_b_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_export_a_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_csq_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_shadows_3p_voltage_update ON flows.meter_shadows;
DROP TRIGGER IF EXISTS meter_registry_updated_at ON flows.meter_registry;
DROP TRIGGER IF EXISTS meter_registry_insert_shadow ON flows.meter_registry;
DROP TRIGGER IF EXISTS chargers_updated_at ON flows.ev_chargers;
DROP INDEX IF EXISTS flows.register_interval_hh_timestamp_idx;
DROP INDEX IF EXISTS flows.meter_voltage_timestamp_idx;
DROP INDEX IF EXISTS flows.meter_prepay_balance_timestamp_idx;
DROP INDEX IF EXISTS flows.meter_prepay_balance_meter_time_idx;
DROP INDEX IF EXISTS flows.meter_interval_hh_timestamp_idx;
DROP INDEX IF EXISTS flows.meter_health_history_timestamp_idx;
DROP INDEX IF EXISTS flows.meter_csq_timestamp_idx;
DROP INDEX IF EXISTS flows.meter_csq_meter_time_idx;
DROP INDEX IF EXISTS flows.meter_3p_voltage_timestamp_idx;
ALTER TABLE IF EXISTS ONLY flows.sites_new DROP CONSTRAINT IF EXISTS sites_new_unique_code;
ALTER TABLE IF EXISTS ONLY flows.sites_new DROP CONSTRAINT IF EXISTS sites_new_pkey;
ALTER TABLE IF EXISTS ONLY flows.service_head_registry DROP CONSTRAINT IF EXISTS service_head_registry_pkey;
ALTER TABLE IF EXISTS ONLY flows.service_head_registry DROP CONSTRAINT IF EXISTS service_head_registry_name_unique;
ALTER TABLE IF EXISTS ONLY flows.service_head_meter DROP CONSTRAINT IF EXISTS service_head_pkey;
ALTER TABLE IF EXISTS ONLY flows.register_interval_hh DROP CONSTRAINT IF EXISTS register_interval_hh_unique;
ALTER TABLE IF EXISTS ONLY flows.register_import DROP CONSTRAINT IF EXISTS register_import_unique;
ALTER TABLE IF EXISTS ONLY flows.register_export DROP CONSTRAINT IF EXISTS register_export_unique;
ALTER TABLE IF EXISTS ONLY flows.properties_service_head DROP CONSTRAINT IF EXISTS properties_service_head_pkey;
ALTER TABLE IF EXISTS ONLY flows.properties DROP CONSTRAINT IF EXISTS properties_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_registry DROP CONSTRAINT IF EXISTS meters_registry_serial_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_registry DROP CONSTRAINT IF EXISTS meters_registry_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_registry DROP CONSTRAINT IF EXISTS meters_registry_ip_address_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_registry DROP CONSTRAINT IF EXISTS meters_registry_emnify_id_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_tophat_registry DROP CONSTRAINT IF EXISTS meter_tophat_registry_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_tophat_registry DROP CONSTRAINT IF EXISTS meter_tophat_registry_ip_address_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_tophat_registry DROP CONSTRAINT IF EXISTS meter_tophat_registry_iccid_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_tophat_registry DROP CONSTRAINT IF EXISTS meter_tophat_registry_emnify_id_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_shadows DROP CONSTRAINT IF EXISTS meter_shadows_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_registry DROP CONSTRAINT IF EXISTS meter_registry_iccid_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_registers DROP CONSTRAINT IF EXISTS meter_registers_register_id_meter_id_unique;
ALTER TABLE IF EXISTS ONLY flows.meter_registers DROP CONSTRAINT IF EXISTS meter_registers_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_metrics DROP CONSTRAINT IF EXISTS meter_metrics_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_event_log DROP CONSTRAINT IF EXISTS meter_event_type_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_event_log_type DROP CONSTRAINT IF EXISTS meter_event_log_type_pkey;
ALTER TABLE IF EXISTS ONLY flows.meter_event_log_type DROP CONSTRAINT IF EXISTS meter_event_log_type_name_unique;
ALTER TABLE IF EXISTS ONLY flows.feeder_registry DROP CONSTRAINT IF EXISTS feeder_registry_pkey;
ALTER TABLE IF EXISTS ONLY flows.feeder_registry DROP CONSTRAINT IF EXISTS feeder_registry_name_unique;
ALTER TABLE IF EXISTS ONLY flows.escos DROP CONSTRAINT IF EXISTS escos_unique_code;
ALTER TABLE IF EXISTS ONLY flows.escos DROP CONSTRAINT IF EXISTS escos_pkey;
ALTER TABLE IF EXISTS ONLY flows.circuit_register DROP CONSTRAINT IF EXISTS circuit_registers_pkey;
ALTER TABLE IF EXISTS ONLY flows.circuits DROP CONSTRAINT IF EXISTS circuit_pkey;
ALTER TABLE IF EXISTS ONLY flows.ev_chargers DROP CONSTRAINT IF EXISTS chargers_pkey;
DROP TABLE IF EXISTS flows.sites_new;
DROP TABLE IF EXISTS flows.service_head_registry;
DROP TABLE IF EXISTS flows.service_head_meter;
DROP MATERIALIZED VIEW IF EXISTS flows.register_interval_hh_missing;
DROP MATERIALIZED VIEW IF EXISTS flows.register_import_missing;
DROP TABLE IF EXISTS flows.register_import;
DROP MATERIALIZED VIEW IF EXISTS flows.register_export_missing;
DROP TABLE IF EXISTS flows.register_export;
DROP TABLE IF EXISTS flows.properties_service_head;
DROP TABLE IF EXISTS flows.properties;
DROP VIEW IF EXISTS flows.meters_offline_recently;
DROP VIEW IF EXISTS flows.meters_offline_all;
DROP VIEW IF EXISTS flows.meters_low_balance;
DROP VIEW IF EXISTS flows.meters_clock_drift;
DROP TABLE IF EXISTS flows.meter_tophat_registry;
DROP VIEW IF EXISTS flows.meter_shadows_tariffs;
DROP TABLE IF EXISTS flows.meter_shadows;
DROP TABLE IF EXISTS flows.meter_registry;
DROP TABLE IF EXISTS flows.meter_registers;
DROP TABLE IF EXISTS flows.meter_metrics;
DROP TABLE IF EXISTS flows.meter_event_log_type;
DROP TABLE IF EXISTS flows.meter_event_log;
DROP TABLE IF EXISTS flows.feeder_registry;
DROP TABLE IF EXISTS flows.ev_chargers;
DROP TABLE IF EXISTS flows.escos;
DROP TABLE IF EXISTS flows.circuits;
DROP VIEW IF EXISTS flows.circuit_interval_monthly;
DROP TABLE IF EXISTS flows.meter_prepay_balance;
DROP TABLE IF EXISTS flows.meter_3p_voltage;
DROP TABLE IF EXISTS flows.meter_voltage;
DROP TABLE IF EXISTS flows.meter_health_history;
DROP TABLE IF EXISTS flows.meter_csq;
DROP VIEW IF EXISTS flows.circuit_interval_daily;
DROP VIEW IF EXISTS flows.circuit_interval_hh;
DROP TABLE IF EXISTS flows.register_interval_hh;
DROP TABLE IF EXISTS flows.circuit_register;
DROP FUNCTION IF EXISTS flows.updated_at_now();
DROP FUNCTION IF EXISTS flows.register_import_b_insert();
DROP FUNCTION IF EXISTS flows.register_import_a_insert();
DROP FUNCTION IF EXISTS flows.register_export_b_insert();
DROP FUNCTION IF EXISTS flows.register_export_a_insert();
DROP FUNCTION IF EXISTS flows.refresh_register_interval_hh_missing(job_id integer, config jsonb);
DROP FUNCTION IF EXISTS flows.refresh_register_import_missing(job_id integer, config jsonb);
DROP FUNCTION IF EXISTS flows.refresh_register_export_missing(job_id integer, config jsonb);
DROP FUNCTION IF EXISTS flows.meter_voltage_insert();
DROP FUNCTION IF EXISTS flows.meter_shadows_insert_new();
DROP FUNCTION IF EXISTS flows.meter_prepay_balance_insert();
DROP FUNCTION IF EXISTS flows.meter_health_history_insert();
DROP FUNCTION IF EXISTS flows.meter_csq_insert();
DROP FUNCTION IF EXISTS flows.meter_3p_voltage_insert();
DROP FUNCTION IF EXISTS flows.get_meters_for_cli(esco_filter text, feeder_filter text);
DROP TYPE IF EXISTS flows.register_nature_enum;
DROP TYPE IF EXISTS flows.meter_register_status_enum;
DROP TYPE IF EXISTS flows.meter_register_element;
DROP TYPE IF EXISTS flows.meter_mode_enum;
DROP TYPE IF EXISTS flows.meter_metric_run_frequency_enum;
DROP TYPE IF EXISTS flows.health_check_status;
DROP TYPE IF EXISTS flows.emnify_device_installation_status_enum;
DROP TYPE IF EXISTS flows.emnify_device_connectivity_status_enum;
DROP TYPE IF EXISTS flows.circuit_type_enum;
DROP SCHEMA IF EXISTS flows;
--
-- TOC entry 29 (class 2615 OID 20174)
-- Name: flows; Type: SCHEMA; Schema: -; Owner: tsdbadmin
--

CREATE SCHEMA flows;


ALTER SCHEMA flows OWNER TO tsdbadmin;

--
-- TOC entry 3447 (class 1247 OID 20183)
-- Name: circuit_type_enum; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.circuit_type_enum AS ENUM (
    'heat',
    'power',
    'solar'
);


ALTER TYPE flows.circuit_type_enum OWNER TO tsdbadmin;

--
-- TOC entry 3487 (class 1247 OID 20190)
-- Name: emnify_device_connectivity_status_enum; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.emnify_device_connectivity_status_enum AS ENUM (
    'online',
    'offline',
    'attached',
    'blocked'
);


ALTER TYPE flows.emnify_device_connectivity_status_enum OWNER TO tsdbadmin;

--
-- TOC entry 3490 (class 1247 OID 20200)
-- Name: emnify_device_installation_status_enum; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.emnify_device_installation_status_enum AS ENUM (
    'enabled',
    'disabled',
    'deleted'
);


ALTER TYPE flows.emnify_device_installation_status_enum OWNER TO tsdbadmin;

--
-- TOC entry 3493 (class 1247 OID 20208)
-- Name: health_check_status; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.health_check_status AS ENUM (
    'healthy',
    'unhealthy'
);


ALTER TYPE flows.health_check_status OWNER TO tsdbadmin;

--
-- TOC entry 3500 (class 1247 OID 20214)
-- Name: meter_metric_run_frequency_enum; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.meter_metric_run_frequency_enum AS ENUM (
    'hourly',
    'daily',
    '12hourly'
);


ALTER TYPE flows.meter_metric_run_frequency_enum OWNER TO tsdbadmin;

--
-- TOC entry 3503 (class 1247 OID 20222)
-- Name: meter_mode_enum; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.meter_mode_enum AS ENUM (
    'active',
    'passive'
);


ALTER TYPE flows.meter_mode_enum OWNER TO tsdbadmin;

--
-- TOC entry 8658 (class 0 OID 0)
-- Dependencies: 3503
-- Name: TYPE meter_mode_enum; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON TYPE flows.meter_mode_enum IS 'active - this meter will be kept in sync by calls to the actual hardware

passive (digital twin) - the meter will be kept in sync by syncing with another database that has the same meter in active mode';


--
-- TOC entry 3540 (class 1247 OID 20228)
-- Name: meter_register_element; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.meter_register_element AS ENUM (
    'A',
    'B',
    'SINGLE'
);


ALTER TYPE flows.meter_register_element OWNER TO tsdbadmin;

--
-- TOC entry 3543 (class 1247 OID 20236)
-- Name: meter_register_status_enum; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.meter_register_status_enum AS ENUM (
    'enabled',
    'replaced'
);


ALTER TYPE flows.meter_register_status_enum OWNER TO tsdbadmin;

--
-- TOC entry 3546 (class 1247 OID 20242)
-- Name: register_nature_enum; Type: TYPE; Schema: flows; Owner: tsdbadmin
--

CREATE TYPE flows.register_nature_enum AS ENUM (
    'heat',
    'power',
    'solar'
);


ALTER TYPE flows.register_nature_enum OWNER TO tsdbadmin;

--
-- TOC entry 2540 (class 1255 OID 20719)
-- Name: get_meters_for_cli(text, text); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.get_meters_for_cli(esco_filter text, feeder_filter text) RETURNS TABLE(id uuid, ip_address text, serial text, name text, single_meter_app boolean, esco text, csq integer, health text, hardware text, feeder text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
		SELECT 
			mr.id as id, host(mr.ip_address) as ip_address,
			mr.serial as serial,
			mr.name as name, 
			mr.single_meter_app,
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


ALTER FUNCTION flows.get_meters_for_cli(esco_filter text, feeder_filter text) OWNER TO tsdbadmin;

--
-- TOC entry 2503 (class 1255 OID 20249)
-- Name: meter_3p_voltage_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.meter_3p_voltage_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_3p_voltage"(meter_id, voltage_l1, voltage_l2, voltage_l3, "timestamp") VALUES (new.id, new."3p_voltage_l1", new."3p_voltage_l2", new."3p_voltage_l3", new.updated_at);
    return new;
END;
$$;


ALTER FUNCTION flows.meter_3p_voltage_insert() OWNER TO tsdbadmin;

--
-- TOC entry 1599 (class 1255 OID 20250)
-- Name: meter_csq_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.meter_csq_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_csq"(meter_id, csq, "timestamp") VALUES (new.id, new.csq, new.updated_at);
    return new;
END;
$$;


ALTER FUNCTION flows.meter_csq_insert() OWNER TO tsdbadmin;

--
-- TOC entry 1895 (class 1255 OID 20251)
-- Name: meter_health_history_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

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


ALTER FUNCTION flows.meter_health_history_insert() OWNER TO tsdbadmin;

--
-- TOC entry 2143 (class 1255 OID 20252)
-- Name: meter_prepay_balance_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.meter_prepay_balance_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_prepay_balance"(meter_id, balance, "timestamp") VALUES (new.id, new.balance, new.updated_at);
    return new;
END;
$$;


ALTER FUNCTION flows.meter_prepay_balance_insert() OWNER TO tsdbadmin;

--
-- TOC entry 1272 (class 1255 OID 20253)
-- Name: meter_shadows_insert_new(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.meter_shadows_insert_new() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
	INSERT INTO flows.meter_shadows(id) VALUES (new.id);
	return new;
END;
$$;


ALTER FUNCTION flows.meter_shadows_insert_new() OWNER TO tsdbadmin;

--
-- TOC entry 1456 (class 1255 OID 20254)
-- Name: meter_voltage_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.meter_voltage_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO "flows"."meter_voltage"(meter_id, voltage, "timestamp") VALUES (new.id, new.voltage, new.updated_at);
    return new;
END;
$$;


ALTER FUNCTION flows.meter_voltage_insert() OWNER TO tsdbadmin;

--
-- TOC entry 2009 (class 1255 OID 36387)
-- Name: refresh_register_export_missing(integer, jsonb); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.refresh_register_export_missing(job_id integer DEFAULT NULL::integer, config jsonb DEFAULT NULL::jsonb) RETURNS void
    LANGUAGE sql
    AS $$
    REFRESH MATERIALIZED VIEW flows.register_export_missing;
$$;


ALTER FUNCTION flows.refresh_register_export_missing(job_id integer, config jsonb) OWNER TO tsdbadmin;

--
-- TOC entry 2259 (class 1255 OID 36388)
-- Name: refresh_register_import_missing(integer, jsonb); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.refresh_register_import_missing(job_id integer DEFAULT NULL::integer, config jsonb DEFAULT NULL::jsonb) RETURNS void
    LANGUAGE sql
    AS $$
    REFRESH MATERIALIZED VIEW flows.register_import_missing;
$$;


ALTER FUNCTION flows.refresh_register_import_missing(job_id integer, config jsonb) OWNER TO tsdbadmin;

--
-- TOC entry 1388 (class 1255 OID 20255)
-- Name: refresh_register_interval_hh_missing(integer, jsonb); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.refresh_register_interval_hh_missing(job_id integer DEFAULT NULL::integer, config jsonb DEFAULT NULL::jsonb) RETURNS void
    LANGUAGE sql
    AS $$
    REFRESH MATERIALIZED VIEW flows.register_interval_hh_missing;
$$;


ALTER FUNCTION flows.refresh_register_interval_hh_missing(job_id integer, config jsonb) OWNER TO tsdbadmin;

--
-- TOC entry 1348 (class 1255 OID 20256)
-- Name: register_export_a_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.register_export_a_insert() RETURNS trigger
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


ALTER FUNCTION flows.register_export_a_insert() OWNER TO tsdbadmin;

--
-- TOC entry 2524 (class 1255 OID 20257)
-- Name: register_export_b_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.register_export_b_insert() RETURNS trigger
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


ALTER FUNCTION flows.register_export_b_insert() OWNER TO tsdbadmin;

--
-- TOC entry 2481 (class 1255 OID 20258)
-- Name: register_import_a_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.register_import_a_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    _register_id uuid;
BEGIN
    -- Skip if import_a is NULL
    IF new.import_a IS NULL THEN
        RETURN new;
    END IF;

    SELECT mr.register_id INTO _register_id
    FROM flows.meter_registers mr
    WHERE mr.meter_id = new.id AND mr.element = 'A';

    IF _register_id IS NULL THEN
        RAISE WARNING 'No register found for meter_id % element A - import_a 
insert skipped', new.id;
        RETURN new;
    END IF;

    -- Double-check register_id is not NULL before insert
    IF _register_id IS NOT NULL THEN
        INSERT INTO "flows"."register_import"(register_id, read, "timestamp")
        VALUES (_register_id, new.import_a, new.updated_at)
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN new;
END;
$$;


ALTER FUNCTION flows.register_import_a_insert() OWNER TO tsdbadmin;

--
-- TOC entry 1661 (class 1255 OID 20259)
-- Name: register_import_b_insert(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

CREATE FUNCTION flows.register_import_b_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    _register_id uuid;
BEGIN
    -- Skip if import_b is NULL
    IF new.import_b IS NULL THEN
        RETURN new;
    END IF;

    SELECT mr.register_id INTO _register_id
    FROM flows.meter_registers mr
    WHERE mr.meter_id = new.id AND mr.element = 'B';

    IF _register_id IS NULL THEN
        RAISE WARNING 'No register found for meter_id % element B - import_b 
insert skipped', new.id;
        RETURN new;
    END IF;

    -- Double-check register_id is not NULL before insert
    IF _register_id IS NOT NULL THEN
        INSERT INTO "flows"."register_import"(register_id, read, "timestamp")
        VALUES (_register_id, new.import_b, new.updated_at)
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN new;
END;
$$;


ALTER FUNCTION flows.register_import_b_insert() OWNER TO tsdbadmin;

--
-- TOC entry 2433 (class 1255 OID 20260)
-- Name: updated_at_now(); Type: FUNCTION; Schema: flows; Owner: tsdbadmin
--

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


ALTER FUNCTION flows.updated_at_now() OWNER TO tsdbadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 332 (class 1259 OID 20261)
-- Name: circuit_register; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.circuit_register (
    circuit uuid DEFAULT gen_random_uuid() NOT NULL,
    register uuid DEFAULT gen_random_uuid() NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    notes text,
    CONSTRAINT circuit_register_check_date_range CHECK (((start_time IS NULL) OR (end_time IS NULL) OR (end_time > start_time)))
);


ALTER TABLE flows.circuit_register OWNER TO tsdbadmin;

--
-- TOC entry 333 (class 1259 OID 20270)
-- Name: register_interval_hh; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.register_interval_hh (
    register_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    kwh numeric NOT NULL
);


ALTER TABLE flows.register_interval_hh OWNER TO tsdbadmin;

--
-- TOC entry 335 (class 1259 OID 20287)
-- Name: circuit_interval_hh; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

CREATE VIEW flows.circuit_interval_hh AS
 SELECT circuit_id,
    "timestamp",
    kwh
   FROM _timescaledb_internal._materialized_hypertable_11;


ALTER VIEW flows.circuit_interval_hh OWNER TO tsdbadmin;

--
-- TOC entry 339 (class 1259 OID 20310)
-- Name: circuit_interval_daily; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

CREATE VIEW flows.circuit_interval_daily AS
 SELECT circuit_id,
    day,
    kwh
   FROM _timescaledb_internal._materialized_hypertable_12;


ALTER VIEW flows.circuit_interval_daily OWNER TO tsdbadmin;

--
-- TOC entry 342 (class 1259 OID 20323)
-- Name: meter_csq; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_csq (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    csq integer
);


ALTER TABLE flows.meter_csq OWNER TO tsdbadmin;

--
-- TOC entry 343 (class 1259 OID 20326)
-- Name: meter_health_history; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_health_history (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    health flows.health_check_status NOT NULL
);


ALTER TABLE flows.meter_health_history OWNER TO tsdbadmin;

--
-- TOC entry 344 (class 1259 OID 20329)
-- Name: meter_voltage; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_voltage (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    voltage real
);


ALTER TABLE flows.meter_voltage OWNER TO tsdbadmin;

--
-- TOC entry 345 (class 1259 OID 20333)
-- Name: meter_3p_voltage; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_3p_voltage (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    voltage_l1 real,
    voltage_l2 real,
    voltage_l3 real
);


ALTER TABLE flows.meter_3p_voltage OWNER TO tsdbadmin;

--
-- TOC entry 346 (class 1259 OID 20336)
-- Name: meter_prepay_balance; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_prepay_balance (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    balance numeric
);


ALTER TABLE flows.meter_prepay_balance OWNER TO tsdbadmin;

--
-- TOC entry 348 (class 1259 OID 20359)
-- Name: circuit_interval_monthly; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

CREATE VIEW flows.circuit_interval_monthly AS
 SELECT circuit_id,
    month,
    kwh
   FROM _timescaledb_internal._materialized_hypertable_18;


ALTER VIEW flows.circuit_interval_monthly OWNER TO tsdbadmin;

--
-- TOC entry 351 (class 1259 OID 20372)
-- Name: circuits; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.circuits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type flows.circuit_type_enum NOT NULL,
    name text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE flows.circuits OWNER TO tsdbadmin;

--
-- TOC entry 352 (class 1259 OID 20379)
-- Name: escos; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.escos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text,
    code text,
    app_url text
);


ALTER TABLE flows.escos OWNER TO tsdbadmin;

--
-- TOC entry 353 (class 1259 OID 20386)
-- Name: ev_chargers; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

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


ALTER TABLE flows.ev_chargers OWNER TO tsdbadmin;

--
-- TOC entry 354 (class 1259 OID 20396)
-- Name: feeder_registry; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.feeder_registry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    esco uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE flows.feeder_registry OWNER TO tsdbadmin;

--
-- TOC entry 355 (class 1259 OID 20403)
-- Name: meter_event_log; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_event_log (
    meter_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    event_type integer NOT NULL,
    event_set integer NOT NULL
);


ALTER TABLE flows.meter_event_log OWNER TO tsdbadmin;

--
-- TOC entry 8673 (class 0 OID 0)
-- Dependencies: 355
-- Name: TABLE meter_event_log; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON TABLE flows.meter_event_log IS 'Log of events inside each meter. see section 2.5 of the specification "Meter and Smart Module Obis Commands".';


--
-- TOC entry 8674 (class 0 OID 0)
-- Dependencies: 355
-- Name: COLUMN meter_event_log.event_type; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON COLUMN flows.meter_event_log.event_type IS 'Corresponds to meter_event_log_type although we don''t yet have a foreign key as there at this stge some unknown types';


--
-- TOC entry 8675 (class 0 OID 0)
-- Dependencies: 355
-- Name: COLUMN meter_event_log.event_set; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON COLUMN flows.meter_event_log.event_set IS 'Incrementing count corresponding to the event_type';


--
-- TOC entry 356 (class 1259 OID 20406)
-- Name: meter_event_log_type; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_event_log_type (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE flows.meter_event_log_type OWNER TO tsdbadmin;

--
-- TOC entry 357 (class 1259 OID 20411)
-- Name: meter_metrics; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    notes text,
    enabled boolean NOT NULL,
    run_frequency flows.meter_metric_run_frequency_enum NOT NULL
);


ALTER TABLE flows.meter_metrics OWNER TO tsdbadmin;

--
-- TOC entry 358 (class 1259 OID 20417)
-- Name: meter_registers; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

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


ALTER TABLE flows.meter_registers OWNER TO tsdbadmin;

--
-- TOC entry 359 (class 1259 OID 20425)
-- Name: meter_registry; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

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
    mode flows.meter_mode_enum DEFAULT 'active'::flows.meter_mode_enum,
    firmware_version text,
    esco uuid,
    daylight_savings_correction_enabled boolean,
    single_meter_app boolean DEFAULT false NOT NULL
);


ALTER TABLE flows.meter_registry OWNER TO tsdbadmin;

--
-- TOC entry 8680 (class 0 OID 0)
-- Dependencies: 359
-- Name: COLUMN meter_registry.mode; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON COLUMN flows.meter_registry.mode IS 'see comments on the meter_mode_enum type for details';


--
-- TOC entry 8681 (class 0 OID 0)
-- Dependencies: 359
-- Name: COLUMN meter_registry.daylight_savings_correction_enabled; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON COLUMN flows.meter_registry.daylight_savings_correction_enabled IS 'Is daylight savings correction mode enabled? If checked than BST timezone will be used in summer for things like the future tariffs activation timestamp.';


--
-- TOC entry 8682 (class 0 OID 0)
-- Dependencies: 359
-- Name: COLUMN meter_registry.single_meter_app; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON COLUMN flows.meter_registry.single_meter_app IS 'If deployed as a single meter in a single app. As opposed to multiple meters per app as we do with most esco deployments. Single meter app is to expose the app publicly and use mutual tls auth to connect.';


--
-- TOC entry 360 (class 1259 OID 20434)
-- Name: meter_shadows; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

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
    import_a real,
    export_a real,
    import_b real,
    export_b real,
    tariffs_active jsonb,
    tariffs_future jsonb,
    backlight text,
    load_switch text
);


ALTER TABLE flows.meter_shadows OWNER TO tsdbadmin;

--
-- TOC entry 361 (class 1259 OID 20441)
-- Name: meter_shadows_tariffs; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

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


ALTER VIEW flows.meter_shadows_tariffs OWNER TO tsdbadmin;

--
-- TOC entry 362 (class 1259 OID 20446)
-- Name: meter_tophat_registry; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.meter_tophat_registry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    meter uuid NOT NULL,
    emnify_id integer,
    ip_address inet,
    iccid text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE flows.meter_tophat_registry OWNER TO tsdbadmin;

--
-- TOC entry 363 (class 1259 OID 20454)
-- Name: meters_clock_drift; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

CREATE VIEW flows.meters_clock_drift AS
 SELECT ms.clock_time_diff_seconds,
    mr.serial,
    mr.name
   FROM flows.meter_shadows ms,
    flows.meter_registry mr
  WHERE ((ms.clock_time_diff_seconds >= 60) AND (ms.id = mr.id))
  ORDER BY ms.clock_time_diff_seconds DESC;


ALTER VIEW flows.meters_clock_drift OWNER TO tsdbadmin;

--
-- TOC entry 364 (class 1259 OID 20459)
-- Name: meters_low_balance; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

CREATE VIEW flows.meters_low_balance AS
 SELECT mr.id,
    mr.serial,
    mr.name,
    ms.balance
   FROM flows.meter_shadows ms,
    flows.meter_registry mr
  WHERE ((ms.id = mr.id) AND (ms.balance < 15.0));


ALTER VIEW flows.meters_low_balance OWNER TO tsdbadmin;

--
-- TOC entry 365 (class 1259 OID 20464)
-- Name: meters_offline_all; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

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


ALTER VIEW flows.meters_offline_all OWNER TO tsdbadmin;

--
-- TOC entry 366 (class 1259 OID 20469)
-- Name: meters_offline_recently; Type: VIEW; Schema: flows; Owner: tsdbadmin
--

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


ALTER VIEW flows.meters_offline_recently OWNER TO tsdbadmin;

--
-- TOC entry 367 (class 1259 OID 20474)
-- Name: properties; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    plot text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE flows.properties OWNER TO tsdbadmin;

--
-- TOC entry 368 (class 1259 OID 20481)
-- Name: properties_service_head; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.properties_service_head (
    property uuid NOT NULL,
    service_head uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE flows.properties_service_head OWNER TO tsdbadmin;

--
-- TOC entry 369 (class 1259 OID 20488)
-- Name: register_export; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.register_export (
    register_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    read real
);


ALTER TABLE flows.register_export OWNER TO tsdbadmin;

--
-- TOC entry 8693 (class 0 OID 0)
-- Dependencies: 369
-- Name: TABLE register_export; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON TABLE flows.register_export IS 'Periodically import and export reads are read from the meters and updated in meter_shadows. This table tracks the history of export reads.';


--
-- TOC entry 1215 (class 1259 OID 36371)
-- Name: register_export_missing; Type: MATERIALIZED VIEW; Schema: flows; Owner: tsdbadmin
--

CREATE MATERIALIZED VIEW flows.register_export_missing AS
 WITH date_range AS (
         SELECT generate_series((date_trunc('day'::text, (CURRENT_DATE - '1 year'::interval)))::timestamp with time zone, date_trunc('day'::text, (CURRENT_DATE)::timestamp with time zone), '1 day'::interval) AS day
        ), expected_counts AS (
         SELECT meter_registers.register_id,
            date_trunc('day'::text, date_range.day) AS date,
            1 AS expected_count
           FROM (flows.meter_registers
             CROSS JOIN date_range)
        ), actual_counts AS (
         SELECT register_export.register_id,
            date_trunc('day'::text, register_export."timestamp") AS date,
            count(*) AS actual_count
           FROM flows.register_export
          WHERE ((register_export."timestamp" >= (CURRENT_DATE - '1 year'::interval)) AND (register_export."timestamp" < CURRENT_DATE))
          GROUP BY register_export.register_id, (date_trunc('day'::text, register_export."timestamp"))
        )
 SELECT e.register_id,
    e.date,
    COALESCE(a.actual_count, (0)::bigint) AS record_count,
    GREATEST((0)::bigint, (e.expected_count - COALESCE(a.actual_count, (0)::bigint))) AS missing_count
   FROM (expected_counts e
     LEFT JOIN actual_counts a ON (((e.register_id = a.register_id) AND (e.date = a.date))))
  ORDER BY e.register_id, e.date
  WITH NO DATA;


ALTER MATERIALIZED VIEW flows.register_export_missing OWNER TO tsdbadmin;

--
-- TOC entry 370 (class 1259 OID 20491)
-- Name: register_import; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.register_import (
    register_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    read real
);


ALTER TABLE flows.register_import OWNER TO tsdbadmin;

--
-- TOC entry 8696 (class 0 OID 0)
-- Dependencies: 370
-- Name: TABLE register_import; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON TABLE flows.register_import IS 'Periodically import and export reads are read from the meters and updated in meter_shadows. This table tracks the history of import reads.';


--
-- TOC entry 1216 (class 1259 OID 36376)
-- Name: register_import_missing; Type: MATERIALIZED VIEW; Schema: flows; Owner: tsdbadmin
--

CREATE MATERIALIZED VIEW flows.register_import_missing AS
 WITH date_range AS (
         SELECT generate_series((date_trunc('day'::text, (CURRENT_DATE - '1 year'::interval)))::timestamp with time zone, date_trunc('day'::text, (CURRENT_DATE)::timestamp with time zone), '1 day'::interval) AS day
        ), expected_counts AS (
         SELECT meter_registers.register_id,
            date_trunc('day'::text, date_range.day) AS date,
            1 AS expected_count
           FROM (flows.meter_registers
             CROSS JOIN date_range)
        ), actual_counts AS (
         SELECT register_import.register_id,
            date_trunc('day'::text, register_import."timestamp") AS date,
            count(*) AS actual_count
           FROM flows.register_import
          WHERE ((register_import."timestamp" >= (CURRENT_DATE - '1 year'::interval)) AND (register_import."timestamp" < CURRENT_DATE))
          GROUP BY register_import.register_id, (date_trunc('day'::text, register_import."timestamp"))
        )
 SELECT e.register_id,
    e.date,
    COALESCE(a.actual_count, (0)::bigint) AS record_count,
    GREATEST((0)::bigint, (e.expected_count - COALESCE(a.actual_count, (0)::bigint))) AS missing_count
   FROM (expected_counts e
     LEFT JOIN actual_counts a ON (((e.register_id = a.register_id) AND (e.date = a.date))))
  ORDER BY e.register_id, e.date
  WITH NO DATA;


ALTER MATERIALIZED VIEW flows.register_import_missing OWNER TO tsdbadmin;

--
-- TOC entry 371 (class 1259 OID 20494)
-- Name: register_interval_hh_missing; Type: MATERIALIZED VIEW; Schema: flows; Owner: tsdbadmin
--

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


ALTER MATERIALIZED VIEW flows.register_interval_hh_missing OWNER TO tsdbadmin;

--
-- TOC entry 372 (class 1259 OID 20499)
-- Name: service_head_meter; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.service_head_meter (
    service_head uuid NOT NULL,
    meter uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE flows.service_head_meter OWNER TO tsdbadmin;

--
-- TOC entry 373 (class 1259 OID 20503)
-- Name: service_head_registry; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

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


ALTER TABLE flows.service_head_registry OWNER TO tsdbadmin;

--
-- TOC entry 374 (class 1259 OID 20512)
-- Name: sites_new; Type: TABLE; Schema: flows; Owner: tsdbadmin
--

CREATE TABLE flows.sites_new (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    code text,
    esco uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE flows.sites_new OWNER TO tsdbadmin;

--
-- TOC entry 8702 (class 0 OID 0)
-- Dependencies: 374
-- Name: TABLE sites_new; Type: COMMENT; Schema: flows; Owner: tsdbadmin
--

COMMENT ON TABLE flows.sites_new IS 'An ESCO can have one more sites defined in this table. The site groups meters under a single boundary settlement meter.';


--
-- TOC entry 8359 (class 2606 OID 20520)
-- Name: ev_chargers chargers_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.ev_chargers
    ADD CONSTRAINT chargers_pkey PRIMARY KEY (id);


--
-- TOC entry 8353 (class 2606 OID 20522)
-- Name: circuits circuit_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.circuits
    ADD CONSTRAINT circuit_pkey PRIMARY KEY (id);


--
-- TOC entry 8340 (class 2606 OID 20524)
-- Name: circuit_register circuit_registers_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.circuit_register
    ADD CONSTRAINT circuit_registers_pkey PRIMARY KEY (circuit, register, start_time);


--
-- TOC entry 8355 (class 2606 OID 20526)
-- Name: escos escos_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.escos
    ADD CONSTRAINT escos_pkey PRIMARY KEY (id);


--
-- TOC entry 8357 (class 2606 OID 20528)
-- Name: escos escos_unique_code; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.escos
    ADD CONSTRAINT escos_unique_code UNIQUE (code);


--
-- TOC entry 8361 (class 2606 OID 20530)
-- Name: feeder_registry feeder_registry_name_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.feeder_registry
    ADD CONSTRAINT feeder_registry_name_unique UNIQUE (name);


--
-- TOC entry 8363 (class 2606 OID 20532)
-- Name: feeder_registry feeder_registry_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.feeder_registry
    ADD CONSTRAINT feeder_registry_pkey PRIMARY KEY (id);


--
-- TOC entry 8367 (class 2606 OID 20534)
-- Name: meter_event_log_type meter_event_log_type_name_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_event_log_type
    ADD CONSTRAINT meter_event_log_type_name_unique UNIQUE (name);


--
-- TOC entry 8369 (class 2606 OID 20536)
-- Name: meter_event_log_type meter_event_log_type_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_event_log_type
    ADD CONSTRAINT meter_event_log_type_pkey PRIMARY KEY (id);


--
-- TOC entry 8365 (class 2606 OID 20538)
-- Name: meter_event_log meter_event_type_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_event_log
    ADD CONSTRAINT meter_event_type_pkey PRIMARY KEY (meter_id, "timestamp", event_type);


--
-- TOC entry 8371 (class 2606 OID 20540)
-- Name: meter_metrics meter_metrics_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_metrics
    ADD CONSTRAINT meter_metrics_pkey PRIMARY KEY (id);


--
-- TOC entry 8373 (class 2606 OID 20542)
-- Name: meter_registers meter_registers_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registers
    ADD CONSTRAINT meter_registers_pkey PRIMARY KEY (register_id);


--
-- TOC entry 8375 (class 2606 OID 20544)
-- Name: meter_registers meter_registers_register_id_meter_id_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registers
    ADD CONSTRAINT meter_registers_register_id_meter_id_unique UNIQUE (register_id, meter_id);


--
-- TOC entry 8377 (class 2606 OID 20546)
-- Name: meter_registry meter_registry_iccid_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meter_registry_iccid_unique UNIQUE (iccid);


--
-- TOC entry 8387 (class 2606 OID 20548)
-- Name: meter_shadows meter_shadows_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_shadows
    ADD CONSTRAINT meter_shadows_pkey PRIMARY KEY (id);


--
-- TOC entry 8389 (class 2606 OID 20550)
-- Name: meter_tophat_registry meter_tophat_registry_emnify_id_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_emnify_id_unique UNIQUE (emnify_id);


--
-- TOC entry 8391 (class 2606 OID 20552)
-- Name: meter_tophat_registry meter_tophat_registry_iccid_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_iccid_unique UNIQUE (iccid);


--
-- TOC entry 8393 (class 2606 OID 20554)
-- Name: meter_tophat_registry meter_tophat_registry_ip_address_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_ip_address_unique UNIQUE (ip_address);


--
-- TOC entry 8395 (class 2606 OID 20556)
-- Name: meter_tophat_registry meter_tophat_registry_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_pkey PRIMARY KEY (id);


--
-- TOC entry 8379 (class 2606 OID 20558)
-- Name: meter_registry meters_registry_emnify_id_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_emnify_id_unique UNIQUE (emnify_id);


--
-- TOC entry 8381 (class 2606 OID 20560)
-- Name: meter_registry meters_registry_ip_address_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_ip_address_unique UNIQUE (ip_address);


--
-- TOC entry 8383 (class 2606 OID 20562)
-- Name: meter_registry meters_registry_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_pkey PRIMARY KEY (id);


--
-- TOC entry 8385 (class 2606 OID 20564)
-- Name: meter_registry meters_registry_serial_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meters_registry_serial_unique UNIQUE (serial);


--
-- TOC entry 8397 (class 2606 OID 20566)
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- TOC entry 8399 (class 2606 OID 20568)
-- Name: properties_service_head properties_service_head_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.properties_service_head
    ADD CONSTRAINT properties_service_head_pkey PRIMARY KEY (property, service_head);


--
-- TOC entry 8401 (class 2606 OID 20571)
-- Name: register_export register_export_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.register_export
    ADD CONSTRAINT register_export_unique UNIQUE (register_id, "timestamp");


--
-- TOC entry 8403 (class 2606 OID 20573)
-- Name: register_import register_import_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.register_import
    ADD CONSTRAINT register_import_unique UNIQUE (register_id, "timestamp");


--
-- TOC entry 8344 (class 2606 OID 20276)
-- Name: register_interval_hh register_interval_hh_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.register_interval_hh
    ADD CONSTRAINT register_interval_hh_unique UNIQUE (register_id, "timestamp");


--
-- TOC entry 8405 (class 2606 OID 20575)
-- Name: service_head_meter service_head_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.service_head_meter
    ADD CONSTRAINT service_head_pkey PRIMARY KEY (service_head, meter);


--
-- TOC entry 8407 (class 2606 OID 20577)
-- Name: service_head_registry service_head_registry_name_unique; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.service_head_registry
    ADD CONSTRAINT service_head_registry_name_unique UNIQUE (name);


--
-- TOC entry 8409 (class 2606 OID 20579)
-- Name: service_head_registry service_head_registry_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.service_head_registry
    ADD CONSTRAINT service_head_registry_pkey PRIMARY KEY (id);


--
-- TOC entry 8411 (class 2606 OID 20581)
-- Name: sites_new sites_new_pkey; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.sites_new
    ADD CONSTRAINT sites_new_pkey PRIMARY KEY (id);


--
-- TOC entry 8413 (class 2606 OID 20583)
-- Name: sites_new sites_new_unique_code; Type: CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.sites_new
    ADD CONSTRAINT sites_new_unique_code UNIQUE (code);


--
-- TOC entry 8349 (class 1259 OID 20347)
-- Name: meter_3p_voltage_timestamp_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE INDEX meter_3p_voltage_timestamp_idx ON flows.meter_3p_voltage USING btree ("timestamp" DESC);


--
-- TOC entry 8345 (class 1259 OID 20584)
-- Name: meter_csq_meter_time_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE UNIQUE INDEX meter_csq_meter_time_idx ON flows.meter_csq USING btree (meter_id, "timestamp");


--
-- TOC entry 8346 (class 1259 OID 20341)
-- Name: meter_csq_timestamp_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE INDEX meter_csq_timestamp_idx ON flows.meter_csq USING btree ("timestamp" DESC);


--
-- TOC entry 8347 (class 1259 OID 20343)
-- Name: meter_health_history_timestamp_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE INDEX meter_health_history_timestamp_idx ON flows.meter_health_history USING btree ("timestamp" DESC);


--
-- TOC entry 8341 (class 1259 OID 20585)
-- Name: meter_interval_hh_timestamp_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE INDEX meter_interval_hh_timestamp_idx ON flows.register_interval_hh USING btree ("timestamp" DESC);


--
-- TOC entry 8350 (class 1259 OID 20586)
-- Name: meter_prepay_balance_meter_time_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE UNIQUE INDEX meter_prepay_balance_meter_time_idx ON flows.meter_prepay_balance USING btree (meter_id, "timestamp");


--
-- TOC entry 8351 (class 1259 OID 20349)
-- Name: meter_prepay_balance_timestamp_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE INDEX meter_prepay_balance_timestamp_idx ON flows.meter_prepay_balance USING btree ("timestamp" DESC);


--
-- TOC entry 8348 (class 1259 OID 20345)
-- Name: meter_voltage_timestamp_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE INDEX meter_voltage_timestamp_idx ON flows.meter_voltage USING btree ("timestamp" DESC);


--
-- TOC entry 8342 (class 1259 OID 20277)
-- Name: register_interval_hh_timestamp_idx; Type: INDEX; Schema: flows; Owner: tsdbadmin
--

CREATE INDEX register_interval_hh_timestamp_idx ON flows.register_interval_hh USING btree ("timestamp" DESC);


--
-- TOC entry 8437 (class 2620 OID 20587)
-- Name: ev_chargers chargers_updated_at; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER chargers_updated_at BEFORE UPDATE ON flows.ev_chargers FOR EACH ROW EXECUTE FUNCTION flows.updated_at_now();


--
-- TOC entry 8438 (class 2620 OID 20588)
-- Name: meter_registry meter_registry_insert_shadow; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_registry_insert_shadow AFTER INSERT ON flows.meter_registry FOR EACH ROW EXECUTE FUNCTION flows.meter_shadows_insert_new();


--
-- TOC entry 8439 (class 2620 OID 20589)
-- Name: meter_registry meter_registry_updated_at; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_registry_updated_at BEFORE UPDATE ON flows.meter_registry FOR EACH ROW EXECUTE FUNCTION flows.updated_at_now();


--
-- TOC entry 8440 (class 2620 OID 20590)
-- Name: meter_shadows meter_shadows_3p_voltage_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_3p_voltage_update AFTER UPDATE OF "3p_voltage_l1", "3p_voltage_l2", "3p_voltage_l3" ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_3p_voltage_insert();


--
-- TOC entry 8441 (class 2620 OID 20591)
-- Name: meter_shadows meter_shadows_csq_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_csq_update AFTER UPDATE OF csq ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_csq_insert();


--
-- TOC entry 8442 (class 2620 OID 20752)
-- Name: meter_shadows meter_shadows_export_a_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_export_a_update AFTER UPDATE OF export_a ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_export_a_insert();


--
-- TOC entry 8443 (class 2620 OID 20753)
-- Name: meter_shadows meter_shadows_export_b_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_export_b_update AFTER UPDATE OF export_b ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_export_b_insert();


--
-- TOC entry 8444 (class 2620 OID 20594)
-- Name: meter_shadows meter_shadows_health_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_health_update AFTER UPDATE OF health ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_health_history_insert();


--
-- TOC entry 8445 (class 2620 OID 20754)
-- Name: meter_shadows meter_shadows_import_a_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_import_a_update AFTER UPDATE OF import_a ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_import_a_insert();


--
-- TOC entry 8446 (class 2620 OID 20755)
-- Name: meter_shadows meter_shadows_import_b_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_import_b_update AFTER UPDATE OF import_b ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.register_import_b_insert();


--
-- TOC entry 8447 (class 2620 OID 20597)
-- Name: meter_shadows meter_shadows_prepay_balance_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_prepay_balance_update AFTER UPDATE OF balance ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_prepay_balance_insert();


--
-- TOC entry 8448 (class 2620 OID 20598)
-- Name: meter_shadows meter_shadows_updated_at; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_updated_at BEFORE UPDATE ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.updated_at_now();


--
-- TOC entry 8449 (class 2620 OID 20599)
-- Name: meter_shadows meter_shadows_voltage_update; Type: TRIGGER; Schema: flows; Owner: tsdbadmin
--

CREATE TRIGGER meter_shadows_voltage_update AFTER UPDATE OF voltage ON flows.meter_shadows FOR EACH ROW EXECUTE FUNCTION flows.meter_voltage_insert();


--
-- TOC entry 8422 (class 2606 OID 20600)
-- Name: ev_chargers chargers_esco_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.ev_chargers
    ADD CONSTRAINT chargers_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id);


--
-- TOC entry 8414 (class 2606 OID 20605)
-- Name: circuit_register circuit_registers_circuit_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.circuit_register
    ADD CONSTRAINT circuit_registers_circuit_fkey FOREIGN KEY (circuit) REFERENCES flows.circuits(id);


--
-- TOC entry 8415 (class 2606 OID 20610)
-- Name: circuit_register circuit_registers_register_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.circuit_register
    ADD CONSTRAINT circuit_registers_register_fkey FOREIGN KEY (register) REFERENCES flows.meter_registers(register_id);


--
-- TOC entry 8423 (class 2606 OID 20615)
-- Name: feeder_registry feeder_registry_esco_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.feeder_registry
    ADD CONSTRAINT feeder_registry_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8420 (class 2606 OID 20620)
-- Name: meter_3p_voltage meter_3p_voltage_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_3p_voltage
    ADD CONSTRAINT meter_3p_voltage_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8417 (class 2606 OID 20625)
-- Name: meter_csq meter_csq_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_csq
    ADD CONSTRAINT meter_csq_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 8424 (class 2606 OID 20630)
-- Name: meter_event_log meter_event_log_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_event_log
    ADD CONSTRAINT meter_event_log_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8418 (class 2606 OID 20635)
-- Name: meter_health_history meter_health_history_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_health_history
    ADD CONSTRAINT meter_health_history_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8416 (class 2606 OID 20640)
-- Name: register_interval_hh meter_interval_register_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.register_interval_hh
    ADD CONSTRAINT meter_interval_register_id_fkey FOREIGN KEY (register_id) REFERENCES flows.meter_registers(register_id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8421 (class 2606 OID 20645)
-- Name: meter_prepay_balance meter_prepay_balance_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_prepay_balance
    ADD CONSTRAINT meter_prepay_balance_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 8425 (class 2606 OID 20650)
-- Name: meter_registers meter_registers_meter_registry_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registers
    ADD CONSTRAINT meter_registers_meter_registry_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id);


--
-- TOC entry 8426 (class 2606 OID 20655)
-- Name: meter_registry meter_registry_esco_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_registry
    ADD CONSTRAINT meter_registry_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8427 (class 2606 OID 20660)
-- Name: meter_shadows meter_shadows_meters_registry_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_shadows
    ADD CONSTRAINT meter_shadows_meters_registry_fkey FOREIGN KEY (id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8428 (class 2606 OID 20665)
-- Name: meter_tophat_registry meter_tophat_registry_meter_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_tophat_registry
    ADD CONSTRAINT meter_tophat_registry_meter_fkey FOREIGN KEY (meter) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8419 (class 2606 OID 20670)
-- Name: meter_voltage meter_voltage_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.meter_voltage
    ADD CONSTRAINT meter_voltage_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8429 (class 2606 OID 20675)
-- Name: properties_service_head properties_service_head_properties_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.properties_service_head
    ADD CONSTRAINT properties_service_head_properties_fkey FOREIGN KEY (property) REFERENCES flows.properties(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8430 (class 2606 OID 20680)
-- Name: properties_service_head properties_service_head_service_head_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.properties_service_head
    ADD CONSTRAINT properties_service_head_service_head_fkey FOREIGN KEY (service_head) REFERENCES flows.service_head_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8431 (class 2606 OID 20685)
-- Name: register_export register_export_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.register_export
    ADD CONSTRAINT register_export_meter_id_fkey FOREIGN KEY (register_id) REFERENCES flows.meter_registers(register_id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8432 (class 2606 OID 20690)
-- Name: register_import register_import_meter_id_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.register_import
    ADD CONSTRAINT register_import_meter_id_fkey FOREIGN KEY (register_id) REFERENCES flows.meter_registers(register_id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8433 (class 2606 OID 20695)
-- Name: service_head_meter service_head_meter_meter_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.service_head_meter
    ADD CONSTRAINT service_head_meter_meter_fkey FOREIGN KEY (meter) REFERENCES flows.meter_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8434 (class 2606 OID 20700)
-- Name: service_head_meter service_head_meter_service_head_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.service_head_meter
    ADD CONSTRAINT service_head_meter_service_head_fkey FOREIGN KEY (service_head) REFERENCES flows.service_head_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8435 (class 2606 OID 20705)
-- Name: service_head_registry service_head_registry_feeder_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.service_head_registry
    ADD CONSTRAINT service_head_registry_feeder_fkey FOREIGN KEY (feeder) REFERENCES flows.feeder_registry(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8436 (class 2606 OID 20710)
-- Name: sites_new sites_new_esco_fkey; Type: FK CONSTRAINT; Schema: flows; Owner: tsdbadmin
--

ALTER TABLE ONLY flows.sites_new
    ADD CONSTRAINT sites_new_esco_fkey FOREIGN KEY (esco) REFERENCES flows.escos(id) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 8657 (class 0 OID 0)
-- Dependencies: 29
-- Name: SCHEMA flows; Type: ACL; Schema: -; Owner: tsdbadmin
--

GRANT USAGE ON SCHEMA flows TO tsdbexplorer;
GRANT USAGE ON SCHEMA flows TO flows;
GRANT USAGE ON SCHEMA flows TO grafanareader;
GRANT USAGE ON SCHEMA flows TO tableau;
GRANT USAGE ON SCHEMA flows TO public_backend;
GRANT USAGE ON SCHEMA flows TO supabase_admin;


--
-- TOC entry 8659 (class 0 OID 0)
-- Dependencies: 332
-- Name: TABLE circuit_register; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.circuit_register TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_register TO flows;
GRANT SELECT ON TABLE flows.circuit_register TO tableau;
GRANT SELECT ON TABLE flows.circuit_register TO public_backend;
GRANT SELECT ON TABLE flows.circuit_register TO supabase_admin;


--
-- TOC entry 8660 (class 0 OID 0)
-- Dependencies: 333
-- Name: TABLE register_interval_hh; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.register_interval_hh TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_interval_hh TO flows;
GRANT SELECT ON TABLE flows.register_interval_hh TO tableau;
GRANT SELECT ON TABLE flows.register_interval_hh TO public_backend;
GRANT SELECT ON TABLE flows.register_interval_hh TO supabase_admin;


--
-- TOC entry 8661 (class 0 OID 0)
-- Dependencies: 335
-- Name: TABLE circuit_interval_hh; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.circuit_interval_hh TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_interval_hh TO flows;
GRANT SELECT ON TABLE flows.circuit_interval_hh TO tableau;
GRANT SELECT ON TABLE flows.circuit_interval_hh TO public_backend;
GRANT SELECT ON TABLE flows.circuit_interval_hh TO supabase_admin;


--
-- TOC entry 8662 (class 0 OID 0)
-- Dependencies: 339
-- Name: TABLE circuit_interval_daily; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.circuit_interval_daily TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_interval_daily TO flows;
GRANT SELECT ON TABLE flows.circuit_interval_daily TO tableau;
GRANT SELECT ON TABLE flows.circuit_interval_daily TO public_backend;
GRANT SELECT ON TABLE flows.circuit_interval_daily TO supabase_admin;


--
-- TOC entry 8663 (class 0 OID 0)
-- Dependencies: 342
-- Name: TABLE meter_csq; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_csq TO flows;
GRANT SELECT ON TABLE flows.meter_csq TO grafanareader;
GRANT SELECT ON TABLE flows.meter_csq TO tableau;
GRANT SELECT ON TABLE flows.meter_csq TO public_backend;
GRANT SELECT ON TABLE flows.meter_csq TO supabase_admin;


--
-- TOC entry 8664 (class 0 OID 0)
-- Dependencies: 343
-- Name: TABLE meter_health_history; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_health_history TO flows;
GRANT SELECT ON TABLE flows.meter_health_history TO grafanareader;
GRANT SELECT ON TABLE flows.meter_health_history TO tableau;
GRANT SELECT ON TABLE flows.meter_health_history TO public_backend;
GRANT SELECT ON TABLE flows.meter_health_history TO supabase_admin;


--
-- TOC entry 8665 (class 0 OID 0)
-- Dependencies: 344
-- Name: TABLE meter_voltage; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_voltage TO flows;
GRANT SELECT ON TABLE flows.meter_voltage TO grafanareader;
GRANT SELECT ON TABLE flows.meter_voltage TO tableau;
GRANT SELECT ON TABLE flows.meter_voltage TO public_backend;
GRANT SELECT ON TABLE flows.meter_voltage TO supabase_admin;


--
-- TOC entry 8666 (class 0 OID 0)
-- Dependencies: 345
-- Name: TABLE meter_3p_voltage; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_3p_voltage TO flows;
GRANT SELECT ON TABLE flows.meter_3p_voltage TO grafanareader;
GRANT SELECT ON TABLE flows.meter_3p_voltage TO tableau;
GRANT SELECT ON TABLE flows.meter_3p_voltage TO public_backend;
GRANT SELECT ON TABLE flows.meter_3p_voltage TO supabase_admin;


--
-- TOC entry 8667 (class 0 OID 0)
-- Dependencies: 346
-- Name: TABLE meter_prepay_balance; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meter_prepay_balance TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_prepay_balance TO flows;
GRANT SELECT ON TABLE flows.meter_prepay_balance TO tableau;
GRANT SELECT ON TABLE flows.meter_prepay_balance TO public_backend;
GRANT SELECT ON TABLE flows.meter_prepay_balance TO supabase_admin;


--
-- TOC entry 8668 (class 0 OID 0)
-- Dependencies: 348
-- Name: TABLE circuit_interval_monthly; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.circuit_interval_monthly TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuit_interval_monthly TO flows;
GRANT SELECT ON TABLE flows.circuit_interval_monthly TO tableau;
GRANT SELECT ON TABLE flows.circuit_interval_monthly TO public_backend;
GRANT SELECT ON TABLE flows.circuit_interval_monthly TO supabase_admin;


--
-- TOC entry 8669 (class 0 OID 0)
-- Dependencies: 351
-- Name: TABLE circuits; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.circuits TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.circuits TO flows;
GRANT SELECT ON TABLE flows.circuits TO tableau;
GRANT SELECT ON TABLE flows.circuits TO public_backend;
GRANT SELECT ON TABLE flows.circuits TO supabase_admin;


--
-- TOC entry 8670 (class 0 OID 0)
-- Dependencies: 352
-- Name: TABLE escos; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.escos TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.escos TO flows;
GRANT SELECT ON TABLE flows.escos TO tableau;
GRANT SELECT ON TABLE flows.escos TO public_backend;
GRANT SELECT ON TABLE flows.escos TO supabase_admin;


--
-- TOC entry 8671 (class 0 OID 0)
-- Dependencies: 353
-- Name: TABLE ev_chargers; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.ev_chargers TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.ev_chargers TO flows;
GRANT SELECT ON TABLE flows.ev_chargers TO tableau;
GRANT SELECT ON TABLE flows.ev_chargers TO public_backend;
GRANT SELECT ON TABLE flows.ev_chargers TO supabase_admin;


--
-- TOC entry 8672 (class 0 OID 0)
-- Dependencies: 354
-- Name: TABLE feeder_registry; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.feeder_registry TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.feeder_registry TO flows;
GRANT SELECT ON TABLE flows.feeder_registry TO tableau;
GRANT SELECT ON TABLE flows.feeder_registry TO public_backend;
GRANT SELECT ON TABLE flows.feeder_registry TO supabase_admin;


--
-- TOC entry 8676 (class 0 OID 0)
-- Dependencies: 355
-- Name: TABLE meter_event_log; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meter_event_log TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_event_log TO flows;
GRANT SELECT ON TABLE flows.meter_event_log TO tableau;
GRANT SELECT ON TABLE flows.meter_event_log TO public_backend;
GRANT SELECT ON TABLE flows.meter_event_log TO supabase_admin;


--
-- TOC entry 8677 (class 0 OID 0)
-- Dependencies: 356
-- Name: TABLE meter_event_log_type; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meter_event_log_type TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_event_log_type TO flows;
GRANT SELECT ON TABLE flows.meter_event_log_type TO tableau;
GRANT SELECT ON TABLE flows.meter_event_log_type TO public_backend;
GRANT SELECT ON TABLE flows.meter_event_log_type TO supabase_admin;


--
-- TOC entry 8678 (class 0 OID 0)
-- Dependencies: 357
-- Name: TABLE meter_metrics; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_metrics TO flows;
GRANT SELECT ON TABLE flows.meter_metrics TO tableau;
GRANT SELECT ON TABLE flows.meter_metrics TO public_backend;
GRANT SELECT ON TABLE flows.meter_metrics TO supabase_admin;


--
-- TOC entry 8679 (class 0 OID 0)
-- Dependencies: 358
-- Name: TABLE meter_registers; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meter_registers TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_registers TO flows;
GRANT SELECT ON TABLE flows.meter_registers TO tableau;
GRANT SELECT ON TABLE flows.meter_registers TO public_backend;
GRANT SELECT ON TABLE flows.meter_registers TO supabase_admin;


--
-- TOC entry 8683 (class 0 OID 0)
-- Dependencies: 359
-- Name: TABLE meter_registry; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_registry TO flows;
GRANT SELECT ON TABLE flows.meter_registry TO grafanareader;
GRANT SELECT ON TABLE flows.meter_registry TO tableau;
GRANT SELECT ON TABLE flows.meter_registry TO public_backend;
GRANT SELECT ON TABLE flows.meter_registry TO supabase_admin;


--
-- TOC entry 8684 (class 0 OID 0)
-- Dependencies: 360
-- Name: TABLE meter_shadows; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_shadows TO flows;
GRANT SELECT ON TABLE flows.meter_shadows TO grafanareader;
GRANT SELECT ON TABLE flows.meter_shadows TO tableau;
GRANT SELECT ON TABLE flows.meter_shadows TO public_backend;
GRANT SELECT ON TABLE flows.meter_shadows TO supabase_admin;


--
-- TOC entry 8685 (class 0 OID 0)
-- Dependencies: 361
-- Name: TABLE meter_shadows_tariffs; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meter_shadows_tariffs TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_shadows_tariffs TO flows;
GRANT SELECT ON TABLE flows.meter_shadows_tariffs TO tableau;
GRANT SELECT ON TABLE flows.meter_shadows_tariffs TO public_backend;
GRANT SELECT ON TABLE flows.meter_shadows_tariffs TO supabase_admin;


--
-- TOC entry 8686 (class 0 OID 0)
-- Dependencies: 362
-- Name: TABLE meter_tophat_registry; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meter_tophat_registry TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meter_tophat_registry TO flows;
GRANT SELECT ON TABLE flows.meter_tophat_registry TO tableau;
GRANT SELECT ON TABLE flows.meter_tophat_registry TO public_backend;
GRANT SELECT ON TABLE flows.meter_tophat_registry TO supabase_admin;


--
-- TOC entry 8687 (class 0 OID 0)
-- Dependencies: 363
-- Name: TABLE meters_clock_drift; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meters_clock_drift TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_clock_drift TO flows;
GRANT SELECT ON TABLE flows.meters_clock_drift TO tableau;
GRANT SELECT ON TABLE flows.meters_clock_drift TO public_backend;
GRANT SELECT ON TABLE flows.meters_clock_drift TO supabase_admin;


--
-- TOC entry 8688 (class 0 OID 0)
-- Dependencies: 364
-- Name: TABLE meters_low_balance; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meters_low_balance TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_low_balance TO flows;
GRANT SELECT ON TABLE flows.meters_low_balance TO tableau;
GRANT SELECT ON TABLE flows.meters_low_balance TO public_backend;
GRANT SELECT ON TABLE flows.meters_low_balance TO supabase_admin;


--
-- TOC entry 8689 (class 0 OID 0)
-- Dependencies: 365
-- Name: TABLE meters_offline_all; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meters_offline_all TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_offline_all TO flows;
GRANT SELECT ON TABLE flows.meters_offline_all TO tableau;
GRANT SELECT ON TABLE flows.meters_offline_all TO public_backend;
GRANT SELECT ON TABLE flows.meters_offline_all TO supabase_admin;


--
-- TOC entry 8690 (class 0 OID 0)
-- Dependencies: 366
-- Name: TABLE meters_offline_recently; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.meters_offline_recently TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.meters_offline_recently TO flows;
GRANT SELECT ON TABLE flows.meters_offline_recently TO tableau;
GRANT SELECT ON TABLE flows.meters_offline_recently TO public_backend;
GRANT SELECT ON TABLE flows.meters_offline_recently TO supabase_admin;


--
-- TOC entry 8691 (class 0 OID 0)
-- Dependencies: 367
-- Name: TABLE properties; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.properties TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.properties TO flows;
GRANT SELECT ON TABLE flows.properties TO tableau;
GRANT SELECT ON TABLE flows.properties TO public_backend;
GRANT SELECT ON TABLE flows.properties TO supabase_admin;


--
-- TOC entry 8692 (class 0 OID 0)
-- Dependencies: 368
-- Name: TABLE properties_service_head; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.properties_service_head TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.properties_service_head TO flows;
GRANT SELECT ON TABLE flows.properties_service_head TO tableau;
GRANT SELECT ON TABLE flows.properties_service_head TO public_backend;
GRANT SELECT ON TABLE flows.properties_service_head TO supabase_admin;


--
-- TOC entry 8694 (class 0 OID 0)
-- Dependencies: 369
-- Name: TABLE register_export; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.register_export TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_export TO flows;
GRANT SELECT ON TABLE flows.register_export TO tableau;
GRANT SELECT ON TABLE flows.register_export TO public_backend;
GRANT SELECT ON TABLE flows.register_export TO supabase_admin;


--
-- TOC entry 8695 (class 0 OID 0)
-- Dependencies: 1215
-- Name: TABLE register_export_missing; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.register_export_missing TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_export_missing TO flows;
GRANT SELECT ON TABLE flows.register_export_missing TO tableau;


--
-- TOC entry 8697 (class 0 OID 0)
-- Dependencies: 370
-- Name: TABLE register_import; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.register_import TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_import TO flows;
GRANT SELECT ON TABLE flows.register_import TO tableau;
GRANT SELECT ON TABLE flows.register_import TO public_backend;
GRANT SELECT ON TABLE flows.register_import TO supabase_admin;


--
-- TOC entry 8698 (class 0 OID 0)
-- Dependencies: 1216
-- Name: TABLE register_import_missing; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.register_import_missing TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_import_missing TO flows;
GRANT SELECT ON TABLE flows.register_import_missing TO tableau;


--
-- TOC entry 8699 (class 0 OID 0)
-- Dependencies: 371
-- Name: TABLE register_interval_hh_missing; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.register_interval_hh_missing TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_interval_hh_missing TO flows;
GRANT SELECT ON TABLE flows.register_interval_hh_missing TO tableau;
GRANT SELECT ON TABLE flows.register_interval_hh_missing TO public_backend;
GRANT SELECT ON TABLE flows.register_interval_hh_missing TO supabase_admin;


--
-- TOC entry 8700 (class 0 OID 0)
-- Dependencies: 372
-- Name: TABLE service_head_meter; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.service_head_meter TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.service_head_meter TO flows;
GRANT SELECT ON TABLE flows.service_head_meter TO tableau;
GRANT SELECT ON TABLE flows.service_head_meter TO public_backend;
GRANT SELECT ON TABLE flows.service_head_meter TO supabase_admin;


--
-- TOC entry 8701 (class 0 OID 0)
-- Dependencies: 373
-- Name: TABLE service_head_registry; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.service_head_registry TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.service_head_registry TO flows;
GRANT SELECT ON TABLE flows.service_head_registry TO tableau;
GRANT SELECT ON TABLE flows.service_head_registry TO public_backend;
GRANT SELECT ON TABLE flows.service_head_registry TO supabase_admin;


--
-- TOC entry 8703 (class 0 OID 0)
-- Dependencies: 374
-- Name: TABLE sites_new; Type: ACL; Schema: flows; Owner: tsdbadmin
--

GRANT SELECT ON TABLE flows.sites_new TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.sites_new TO flows;
GRANT SELECT ON TABLE flows.sites_new TO tableau;
GRANT SELECT ON TABLE flows.sites_new TO public_backend;
GRANT SELECT ON TABLE flows.sites_new TO supabase_admin;


-- Completed on 2026-01-07 23:35:53 UTC

--
-- PostgreSQL database dump complete
--


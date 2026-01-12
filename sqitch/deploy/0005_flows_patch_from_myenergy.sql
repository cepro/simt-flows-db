-- Deploy flows:0005_flows_patch_from_myenergy to pg

BEGIN;

CREATE OR REPLACE VIEW flows.meters_low_balance as 
    select mr.id, mr.serial, mr.name, ms.balance
    from flows.meter_shadows ms, flows.meter_registry mr
    where ms.id = mr.id and 
    ms.balance < 15.0;


    -- Fix register_import_a_insert function
CREATE OR REPLACE FUNCTION flows.register_import_a_insert()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
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
$function$;

-- Fix register_import_b_insert function  
CREATE OR REPLACE FUNCTION flows.register_import_b_insert()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
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
$function$;


INSERT INTO flows.meter_event_log_type (id, name) VALUES 
    (1, 'BM_OVER_CURRENT'), 
    (2, 'BM_FAULTY_CONTACTOR'), 
    (3, 'BM_REVERSE_ENERGY_DETECT'), 
    (4, 'BM_TERMINAL_COVER_REMOVED'), 
    (5, 'BM_WATCHDOG_RESET'), 
    (6, 'BM_NV_WRITE_EXCEEDED'), 
    (7, 'BM_METROLOGY_ERROR'), 
    (8, 'BM_MEMORY_ERROR'), 
    (9, 'BM_MODULE_REMOVED'), 
    (10, 'BM_MAGNETIC_FRAUD'), 
    (11, 'BM_NON_LEGAL_TIME'), 
    (15, 'BM_SPAD_1_WRITE'), 
    (16, 'BM_SPAD_2_WRITE'), 
    (17, 'DSP_ERROR'), 
    (18, 'BM_COMMS_ERROR'), 
    (19, 'GW_COMMS_ERROR'), 
    (20, 'PF_TAG_1_ERROR'), 
    (21, 'PF_TAG_2_ERROR'), 
    (22, 'SPARE_0020'), 
    (23, 'SPARE_0040'), 
    (24, 'SPARE_0080'), 
    (25, 'NON_LEGAL_TIME'), 
    (26, 'MEMORY_TYPE'), 
    (27, 'MEMORY_ERROR'), 
    (28, 'WATCHDOG_RESET'), 
    (29, 'SW_IMAGE_WDOG'), 
    (30, 'SW_IMAGE_HES_PREVIOUS'), 
    (31, 'SW_IMAGE_APPLIED'), 
    (32, 'SW_IMAGE_BAD'), 
    (33, 'EVENT_POWER_UP'), 
    (34, 'EVENT_POWER_DN'), 
    (35, 'EVENT_IMAGE_RECEIVED'), 
    (36, 'EVENT_LOG_RESET_ID'), 
    (37, 'EVENT_IMAGE_ERROR'), 
    (38, 'DAILY_LOG_SNAPSHOT'), 
    (39, 'BILLING_LOG_SNAPSHOT'), 
    (40, 'DO_BIND_COMMAND'), 
    (41, 'DO_UNBIND_COMMAND'), 
    (42, 'NEW_IMAGE_APPLIED'), 
    (43, 'WATCHDOG_IMAGE_APPLIED'), 
    (44, 'PREVIOUS_IMAGE_APPLIED'), 
    (61, 'HES_MSG_PENDING'), 
    (62, 'SM_COMMS_ERROR'), 
    (63, 'WAN_COMMS_ERROR'), 
    (64, 'HAN_COMMS_ERROR_GAS'), 
    (65, 'HAN_COMMS_ERROR_IHU'), 
    (66, 'HAN_API_NOT_RESPONDING'), 
    (67, 'SPARE_0040_2'), 
    (68, 'SPARE_0080_2'), 
    (69, 'NON_LEGAL_TIME_2'), 
    (70, 'MEMORY_TYPE_2'), 
    (71, 'MEMORY_ERROR_2'), 
    (72, 'WATCHDOG_RESET_2'), 
    (73, 'SW_IMAGE_WDOG_2'), 
    (74, 'SW_IMAGE_HES_PREVIOUS_2'), 
    (75, 'SW_IMAGE_APPLIED_2'), 
    (76, 'SW_IMAGE_BAD_2'), 
    (77, 'EVENT_IMAGE_RECEIVED_2'), 
    (78, 'EVENT_LOG_RESET_ID_2'), 
    (80, 'HAN_DEVICE_JOINED'), 
    (81, 'HAN_DEVICE_LEFT'), 
    (83, 'INVALID_WAN_MESSAGE'), 
    (84, 'EVENT_POWER_UP_2'), 
    (85, 'EVENT_POWER_DOWN'), 
    (86, 'LAST_GASP_SENT_TO_HES'), 
    (87, 'ALARM_SENT_TO_HES'), 
    (88, 'EVENT_IMAGE_ERROR_2'), 
    (89, 'GW_DO_UNBIND_COMMAND'), 
    (90, 'GW_DO_BIND_COMMAND'), 
    (91, 'GW_NEW_IMAGE_APPLIED'), 
    (92, 'GW_WATCHDOG_IMAGE_APPLIED'), 
    (93, 'GW_PREVIOUS_IMAGE_APPLIED'), 
    (94, 'GSM_RESET_NO_CONNECTION'), 
    (95, 'STATUS_WORD_RESET'), 
    (96, 'ZIGBEE_GET_SW_VER_ERR'), 
    (97, 'ZIGBEE_SEND_MAC_LINK_ERR'), 
    (98, 'ZIGBEE_SHUTODWN_ERR'), 
    (99, 'ZIGBEE_ACTIVE_IMAGE_ERR'), 
    (104, 'LISTENING_SOCKET_ABORTED'), 
    (105, 'AUTO_ROAMING_DISABLE')
ON CONFLICT (id) DO NOTHING;

DROP MATERIALIZED VIEW IF EXISTS flows.register_export_missing;

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
    GREATEST(0, (e.expected_count - COALESCE(a.actual_count, (0)::bigint))) AS missing_count
   FROM (expected_counts e
     LEFT JOIN actual_counts a ON (((e.register_id = a.register_id) AND (e.date = a.date))))
  ORDER BY e.register_id, e.date
  WITH NO DATA;


DROP MATERIALIZED VIEW IF EXISTS flows.register_import_missing;

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
    GREATEST(0, (e.expected_count - COALESCE(a.actual_count, (0)::bigint))) AS missing_count
   FROM (expected_counts e
     LEFT JOIN actual_counts a ON (((e.register_id = a.register_id) AND (e.date = a.date))))
  ORDER BY e.register_id, e.date
  WITH NO DATA;


REFRESH MATERIALIZED view flows.register_export_missing; 
REFRESH MATERIALIZED view flows.register_import_missing; 

CREATE OR REPLACE FUNCTION flows.refresh_register_export_missing(
    job_id integer DEFAULT NULL::integer,
    config jsonb DEFAULT NULL::jsonb
) RETURNS void
    LANGUAGE sql
    AS $$
    REFRESH MATERIALIZED VIEW flows.register_export_missing;
$$;

CREATE OR REPLACE FUNCTION flows.refresh_register_import_missing(
    job_id integer DEFAULT NULL::integer,
    config jsonb DEFAULT NULL::jsonb
) RETURNS void
    LANGUAGE sql
    AS $$
    REFRESH MATERIALIZED VIEW flows.register_import_missing;
$$;

SELECT add_job(
    'flows.refresh_register_export_missing',
    '1d',
    -- first run is 3am the day after the migration is run:
    initial_start => (date_trunc('day', now()) + interval '27 hours')::timestamptz);
SELECT add_job(
    'flows.refresh_register_import_missing',
    '1d',
    -- first run is 3am the day after the migration is run:
    initial_start => (date_trunc('day', now()) + interval '27 hours')::timestamptz);

GRANT SELECT ON TABLE flows.register_export_missing TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_export_missing TO flows;
GRANT SELECT ON TABLE flows.register_export_missing TO tableau;

GRANT SELECT ON TABLE flows.register_import_missing TO grafanareader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flows.register_import_missing TO flows;
GRANT SELECT ON TABLE flows.register_import_missing TO tableau;

COMMIT;

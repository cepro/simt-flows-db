BEGIN;

DROP USER flows;
DROP USER grafanareader;
DROP USER taleau;

DROP SCHEMA flows CASCADE;

COMMIT;
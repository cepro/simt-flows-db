-- Deploy flows:0006_regions_and_escos_region to pg

BEGIN;

CREATE TABLE flows.regions (
    code text NOT NULL,
    name text NOT NULL,
    CONSTRAINT regions_pkey PRIMARY KEY (code)
);

ALTER TABLE flows.regions OWNER TO :"adminrole";

COMMENT ON TABLE flows.regions IS 'Regions of UK as used in the Ofgem energy price caps: https://www.ofgem.gov.uk/energy-advice-households/get-energy-price-cap-standing-charges-and-unit-rates-region';

ALTER TABLE flows.escos ADD COLUMN region text;

ALTER TABLE flows.escos OWNER TO :"adminrole";

CREATE INDEX escos_region_idx ON flows.escos USING btree (region);

ALTER TABLE ONLY flows.escos
    ADD CONSTRAINT esco_region_fkey FOREIGN KEY (region) REFERENCES flows.regions(code) ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE flows.escos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users" ON flows.regions FOR SELECT USING (true);
ALTER TABLE flows.regions ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE flows.regions TO flows;
GRANT SELECT ON TABLE flows.regions TO tableau;
GRANT SELECT ON TABLE flows.regions TO grafanareader;

INSERT INTO flows.regions (code, name) VALUES
    ('south_west', 'South West'),
    ('south_east', 'South East'),
    ('london', 'London');

UPDATE flows.escos SET region = 'south_west' WHERE code in ('wlce', 'hmce', 'bec', 'bpc', 'lab');

COMMIT;
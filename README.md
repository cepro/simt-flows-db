# flows-db

[![DB CI](https://github.com/cepro/flows-db/actions/workflows/db-ci.yml/badge.svg)](https://github.com/cepro/flows-db/actions/workflows/db-ci.yml)

Config, SQL, functions for the flows database.

## Scripts

- db-up - start flows timescaledb local
- db-down - stop flows timescaledb local
- db-reset - run ts-reset
- ts-up - start timescaledb local
- ts-down - stop timescaledb local
- ts-reset - run 'sqitch revert' and 'sqitch deploy' to reset the db
- flows-diff-local - diff local flows database for schema changes
- template-flows-migrations - substitute variables into flows sqitch migration scripts

## Migrations

A set of migration scripts is maintained.

[Sqitch](https://sqitch.org) is used to manage migrations include applying
deployments and rollbacks.

### Run migrations

```sh
# setup secrets - edit this file with new passwords
sqitch> cp sqitch_secrets.conf.example sqitch_secrets.conf

# run the migrations - add your timescale-<org> connection details to sqitch.conf
SQITCH_USER_CONFIG=sqitch_secrets.conf sqitch deploy --target timescale-<org>
```

### Generate Migration from Diff

see bin/flows-diff-local which will generate a SQL diff between the currently
running local database and a database at the state of the migration files.
## Migrating v1 database to v2

*Adapted from https://github.com/umami-software/migrate-v1-v2/*

**Important:**
- Any event data will not be migrated into v2, nor keeped in a specific table.
- v1 tables are all dropped after the migration is complete.

**Running migration:**

After making a copy of the database (obviously not mandatory, but so simple to do with SQLite),

put `migrate-v1-v2` folder inside Umami 1.40.0 folder\
and run from there (Umami's root):

```
node migrate-v1-v2/migrate.js
```

The database file will then be ready to be used in Umami v2.
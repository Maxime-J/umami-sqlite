# SQLite support for [Umami](https://github.com/umami-software/umami)

This repository contains patches to bring SQLite support to Umami, keeping all other features intact.\
Patches are named after the supported, tested Umami version.

One patch file per major version.\
Updates will be supported within each.\
Can't guarantee migration scripts between major ones will be provided (eg. v1 to v2)

## Why not a fork ?
A way to keep the official repository as the main source.\
Plus, I consider this as an experimental feature, whereas being totally stable and useable (I use it myself in production).

## How ?
The following has to be done before building Umami:

- Place the patch file in Umami's root, and apply it from there with:\
`patch -p1 < version.patch`

- In `.env`, configure Umami to use SQLite with\
`DATABASE_URL=file:`*path*

Path can be absolute `DATABASE_URL=file:/absolute/path/to/database.db`\
or relative `DATABASE_URL=file:./database.db`.\
In normal conditions, a relative path is relative to the prisma folder, but not necesseraly, so an absolute one is recommended.

## How to update ?
Reverse the patch before pulling updates
```
patch -p1 -R < version.patch
git pull
```
Then download and apply the new patch.

## Will Umami support it?
Probably not, they already support multiple databases, and have their cloud offer.\
Which is a lot to maintain, and a cool thing (not to mention that it's open source).\
Thanks to them for all of that!

Moreover, SQLite has some technical aspects which don't make it a very good candidate for Umami's usage.

## SQLite specificities
Time data is stored as integer in Unix timestamp format (SQLite doesn't have a storage class set aside for dates/times).

Initial admin user is added through `scripts/check-db.js` in order to have a non fixed, app generated uuid (SQLite doesn't natively support UUIDs).

Data intended to be stored with JSON Prisma field is stored as text, using `JSON.stringify` (JSON field with SQLite isn't supported by Prisma https://github.com/prisma/prisma/issues/3786).

`uniexpoch` function is not supported in the SQLite version shipped with Prisma, `strftime` is used instead.

For non raw db requests, needed manipulations are done with Prisma Client extensions feature (https://www.prisma.io/docs/concepts/components/prisma-client/client-extensions).

SQLite documentation:\
https://www.sqlite.org/lang_datefunc.html \
https://www.sqlite.org/json1.html
# SQLite support for [Umami](https://github.com/umami-software/umami)
This repository contains patches to bring SQLite support to Umami, keeping all other features intact.\
Patches are named after the supported, tested Umami version.

One patch file per major version, renamed on a new update.\
Needed migration scripts provided in their own folder (see README inside for instructions).

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

Using Docker, that path should likely lead to the mount point of a volume, for data persistence.

## How to update ?
Reverse the patch before pulling updates
```
patch -p1 -R < version.patch
git pull
```
Then download and apply the new patch.

## Will Umami support it?
Probably not, they already support multiple databases, and run their cloud offer.\
Which is already a cool thing (not to mention that it's open source).\
Thanks to them for all of that!

Moreover, SQLite has some technical aspects which don't make it a very good candidate for Umami's usage.

## SQLite specificities in latest version

Time data is stored as integer in Unix timestamp format (SQLite doesn't have a storage class set aside for dates/times).

`uniexpoch` function is not supported in the SQLite version shipped with Prisma, `strftime` is used instead.

updatedAt timestamps are handled manually for them to have the appropriate format (@updatedAt removed in Prisma schema).

Prisma client `createMany` query isn't supported with SQLite, an equivalent function is added.

Needed format manipulations are done with Prisma Client extensions feature ([https://www.prisma.io/docs/concepts/components/prisma-client/client-extensions](https://www.prisma.io/docs/concepts/components/prisma-client/client-extensions)).\
This is handled in `lib/prisma-client.ts`, brought it back from @umami/prisma-client.

SQLite documentation:\
https://www.sqlite.org/lang_datefunc.html
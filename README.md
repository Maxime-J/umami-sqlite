# SQLite support for [Umami](https://github.com/umami-software/umami)
This repository contains a patch to bring SQLite support to Umami, keeping all other features intact.\
Patch is named after the supported, tested Umami released version.

Updates are supported, and eventually needed scripts are provided with their README in the scripts folder.

## Why not a fork ?
A way to keep the official repository as the main source.\
Plus, although being totally stable and useable, I consider this an experimental feature, which requires some workarounds.

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

## Could Umami support it ?
Probably not, they already support multiple databases, and run their cloud offer.\
Which is already a cool thing (not to mention that it's open source).\
Thanks to them for all of that!

Moreover, SQLite has some technical aspects which don't make it a very good candidate for Umami's usage.

## SQLite specificities in latest version
Time data is stored as integer in Unix timestamp format (SQLite doesn't have a storage class set aside for dates/times).

updatedAt timestamps are handled manually for them to have the appropriate format (no @updatedAt in Prisma schema).

Prisma client `createMany` query isn't supported with SQLite, an equivalent function is added.

Needed format manipulations are done with Prisma Client extensions feature ([https://www.prisma.io/docs/concepts/components/prisma-client/client-extensions](https://www.prisma.io/docs/concepts/components/prisma-client/client-extensions)).\
This is handled in `lib/prisma-client.ts`, brought back from @umami/prisma-client.

`sqlite-vacuum.js` is added in Umami scripts folder to execute VACUUM command on the database. You might want to launch it sometimes:
>-Frequent inserts, updates, and deletes can cause the database file to become fragmented - where data for a single table or index is scattered around the database file. Running VACUUM ensures that each table and index is largely stored contiguously within the database file. In some cases, VACUUM may also reduce the number of partially filled pages in the database, reducing the size of the database file further.
>
>-When content is deleted from an SQLite database, the content is not usually erased but rather the space used to hold the content is marked as being available for reuse. [...] Running VACUUM will clean the database of all traces of deleted content.
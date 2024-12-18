# SQLite support for [Umami](https://github.com/umami-software/umami)
This repository contains a patch to bring SQLite support to Umami, keeping all other features intact.\
Patch is named after the supported, tested Umami released version.

Although being totally stable and useable, I consider this an experimental feature.

## Getting Umami with SQLite
Latest patched Umami is available in the releases.

Patch can also be applied manually, by placing it in Umami's root, and applying from there with:\
`patch -p1 < version.patch` (reversible with `patch -p1 -R < version.patch`)

## Configuration
Before building, in `.env`configure Umami to use SQLite with\
`DATABASE_URL=file:`*path*

An absolute path is recommended `DATABASE_URL=file:/absolute/path/to/database.db`\
Using Docker, that path should likely lead to the mount point of a volume, for data persistence.

## Could Umami support it ?
Probably not, they already support multiple databases, and run their cloud offer.\
Which is already a cool thing (not to mention that it's open source).\
Thanks to them for all of that!

## SQLite specificities in latest version
Rowid tables are used, WITHOUT ROWID leading to a larger database file with Umami.

Using SQLite, Prisma stores `DateTime` fields as Unix timestamps in ms.\
This patch uses an `Int` field for time data, storing it as Unix timestamp in seconds, for convenience with the date functions in use.\
(SQLite doesn't have a storage class set aside for dates/times).

updatedAt timestamps are handled manually for them to have the appropriate format.

All of this is mainly handled in `lib/prisma-client.ts`, brought back from @umami/prisma-client, using Prisma Client extensions feature.

`sqlite-vacuum.js` is added in Umami scripts folder to execute VACUUM command on the database. You might want to launch it sometimes:
>-Frequent inserts, updates, and deletes can cause the database file to become fragmented - where data for a single table or index is scattered around the database file. Running VACUUM ensures that each table and index is largely stored contiguously within the database file. In some cases, VACUUM may also reduce the number of partially filled pages in the database, reducing the size of the database file further.
>
>-When content is deleted from an SQLite database, the content is not usually erased but rather the space used to hold the content is marked as being available for reuse. [...] Running VACUUM will clean the database of all traces of deleted content.

# SQLite support for [Umami](https://github.com/umami-software/umami)
This repository contains a patch bringing SQLite support to Umami.\
Patch is named after the supported Umami released version.

## Getting Umami with SQLite
Multiple ways are possible:

- Latest patched Umami is available in the releases.

- Patch can be applied manually by placing it in Umami's root and applying from there with:\
`patch -p1 < version.patch` (reversible with `patch -p1 -R < version.patch`)

- A pre-built Docker image is available on `ghcr.io/maxime-j/umami-sqlite:latest`

## Configuration
Before building, in `.env` configure Umami to use SQLite with\
`DATABASE_URL=file:`*path*

An absolute path is recommended `DATABASE_URL=file:/absolute/path/to/database.db`

With the Docker image, `DATABASE_URL` needs to be set as an env var and should lead to a volume mounted on `/db`.\
A Compose file and a Kubernetes YAML (designed for Podman use) are available in the [examples](examples).

## Could it be officially supported?
Probably not.\
Each database eventually requires tailoring to match its specificities, or lack of features, like SQLite not having a storage class for dates/times.\
Supporting it officially could represent a significant amount of time, and it would add another source of issues (they already had a bunch because of their multiple db support).

## Added scripts
SQLite specific scripts are added in `scripts/sqlite` folder:

`vacuum.js` to execute VACUUM command on the database. You might want to run it sometimes:
>-Frequent inserts, updates, and deletes can cause the database file to become fragmented - where data for a single table or index is scattered around the database file. Running VACUUM ensures that each table and index is largely stored contiguously within the database file. In some cases, VACUUM may also reduce the number of partially filled pages in the database, reducing the size of the database file further.
>
>-When content is deleted from an SQLite database, the content is not usually erased but rather the space used to hold the content is marked as being available for reuse. [...] Running VACUUM will clean the database of all traces of deleted content.

`convert-utm-clid-columns.js` to convert unprocessed data from versions 2.18 and earlier.

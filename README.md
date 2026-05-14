# SQLite version of [Umami](https://github.com/umami-software/umami)
Docker image available on `ghcr.io/maxime-j/umami-sqlite:latest`\
Full sources in releases, this repository only holds the changes made to Umami.

## Configuration
`DATABASE_URL` env var must be set in the form of\
 `file:/absolute/path/to/database.db`\
*An absolute path is recommended*

Using Docker image, that path should lead to a volume mounted on `/db`.\
Usage examples are available in the [examples](examples) folder.

## Running from source requirements
Node.js v26\
CMake and a C compiler, SQLite regexp extension being automatically built on postinstall
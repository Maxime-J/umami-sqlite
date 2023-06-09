require('dotenv').config();
const fse = require('fs-extra');
const path = require('path');
const { execSync } = require('child_process');
const { PrismaClient } = require('@prisma/client');
const chalk = require('chalk');
const { v4 } = require('uuid');

let prisma;

function error(msg) {
  console.log(chalk.redBright(`✗ ${msg}`));
}

function inProgress(msg) {
  console.log(chalk.yellowBright(`✓ ${msg}`));
}

function success(msg) {
  console.log(chalk.greenBright(`✓ ${msg}`));
}
  
async function checkEnv() {
  if (!process.env.DATABASE_URL) {
    throw new Error('DATABASE_URL is not defined.');
  } else {
    success('DATABASE_URL is defined.');
  }
}

async function checkConnection() {
  try {
    await prisma.$connect();

    success('Database connection successful.');
  } catch (e) {
    throw new Error('Unable to connect to the database:' + e.message);
  }
}

async function prepareMigration() {
  try {
    console.log('Preparing migration');

    await prisma.$executeRaw`PRAGMA foreign_keys = false;`
    await dropV1Indexes();
    await renameV1Tables();
  } catch (e) {
    // Ignore
  }
}

async function checkV1TablesReady() {
  try {
    await prisma.$queryRaw`select * from v1_account limit 1`;

    success('Database v1 tables ready for migration.');
  } catch (e) {
    throw new Error('Database v1 tables have not been detected.');
  }
}


async function addV2Tables() {
  console.log('Database v2 tables not found.');
  console.log('Adding v2 tables...');

  // run v2 prisma migration steps
  await runSqlFile(`/v2.sql`);
  console.log(execSync('npx prisma migrate resolve --applied 01_init').toString());
  await prisma.$executeRaw`UPDATE _prisma_migrations SET checksum = '4faf36cfba70e8cd69f62b02305e21a34aef7a5c027863ed17c3a3322c6c71a6' WHERE migration_name = '01_init';`;
}

async function checkMigrationReady() {
  try {
    await prisma.$queryRaw`select * from website_event limit 1`;
    await prisma.$queryRaw`select * from v1_account limit 1`;

    success('Database is ready for migration.');
  } catch (e) {
    throw new Error('Database is not ready for migration.');
  }
}

async function migrateData() {
  const filePath = `/data-migration-v2.sql`;
  inProgress('Starting v2 data migration. Please do no cancel this process, it may take a while.');
  await runSqlFile(filePath);
  try {
    let pageviews = await prisma.$queryRaw`SELECT event_id, referrer_path FROM website_event WHERE event_type = 1;`;
    let requests = [];
    pageviews.forEach(pageview => {
      const { event_id, referrer_path: referrer } = pageview;
      const uuid = v4();
      let updates = [`event_id = '${uuid}'`];
      if(referrer.startsWith('http')){
        const refUrl = new URL(referrer);
        let referrerPath = refUrl.pathname;
        let referrerDomain = refUrl.hostname.replace(/www\./, '');
        updates.push(`referrer_path = '${referrerPath}'`);
        updates.push(`referrer_domain = '${referrerDomain}'`);
      }
      requests.push(prisma.$executeRawUnsafe(`UPDATE website_event SET ${updates.join(', ')} WHERE event_id = '${event_id}';`));
    });
    await prisma.$transaction(requests);
  } catch (e) {
    console.log(e);
    throw new Error('Migration is incomplete');
  }

  success('Data migration from v1 to v2 tables completed.');
}

async function dropV1Indexes() {
  try {
    // drop indexes
    await prisma.$transaction([
      prisma.$executeRaw`DROP INDEX session_created_at_idx;`,
      prisma.$executeRaw`DROP INDEX session_website_id_idx;`,
      prisma.$executeRaw`DROP INDEX website_user_id_idx;`, 
    ]);

    success('Dropped v1 database indexes.');
  } catch (e) {
    console.log(e);
    error('Failed to drop v1 database indexes.');
    process.exit(1);
  }
}

async function renameV1Tables() {
  try {
    // rename tables
    await prisma.$transaction([
      prisma.$executeRaw`ALTER TABLE _prisma_migrations RENAME TO v1_prisma_migrations;`,
      prisma.$executeRaw`ALTER TABLE account RENAME TO v1_account;`,
      prisma.$executeRaw`ALTER TABLE event RENAME TO v1_event;`,
      prisma.$executeRaw`ALTER TABLE event_data RENAME TO v1_event_data;`,
      prisma.$executeRaw`ALTER TABLE pageview RENAME TO v1_pageview;`,
      prisma.$executeRaw`ALTER TABLE session RENAME TO v1_session;`,
      prisma.$executeRaw`ALTER TABLE website RENAME TO v1_website;`,
    ]);

    success('Renamed v1 database tables.');
  } catch (e) {
    console.log(e);
    error('Failed to rename v1 database tables.');
    process.exit(1);
  }
}

async function deleteV1Tables() {
  try {
    // drop tables
    await prisma.$transaction([
      prisma.$executeRaw`DROP TABLE v1_prisma_migrations;`,
      prisma.$executeRaw`DROP TABLE v1_event;`,
      prisma.$executeRaw`DROP TABLE v1_pageview;`,
      prisma.$executeRaw`DROP TABLE v1_session;`,
      prisma.$executeRaw`DROP TABLE v1_website;`,
      prisma.$executeRaw`DROP TABLE v1_account;`,
      prisma.$executeRaw`DROP TABLE v1_event_data;`,
    ]);

    success('Dropped v1 database tables.');
    success('Migration successfully completed.');
  } catch (e) {
    console.log(e);
    throw new Error('Failed to drop v1 database tables.');
  }
}

async function runSqlFile(filePath) {
  try {
    const rawSql = await fse.promises.readFile(path.join(__dirname, filePath));

    const sqlStatements = rawSql
      .toString()
      .split('\n')
      .filter(line => !line.startsWith('--')) // remove comments-only lines
      .join('\n')
      .replace(/\r\n|\n|\r/g, ' ') // remove newlines
      .replace(/\s+/g, ' ') // excess white space
      .split(';');

    for (const sql of sqlStatements) {
      if (sql.length > 0) {
        await prisma.$executeRawUnsafe(sql);
      }
    }

    success(`Ran sql file ${filePath}.`);
  } catch (e) {
    console.log(e);
    throw new Error(`Failed to run sql file ${filePath}.`);
  }
}

// migration workflow
(async () => {
  console.log(`Running migration`);

  prisma = new PrismaClient();

  let err = false;
  for (let fn of [
    checkEnv,
    checkConnection,
    prepareMigration,
    checkV1TablesReady,
    addV2Tables,
    checkMigrationReady,
    migrateData,
    deleteV1Tables,
  ]) {
    try {
      await fn();
    } catch (e) {
      error(e.message);
      err = true;
    } finally {
      await prisma.$disconnect();
      if (err) {
        process.exit(1);
      }
    }
  }
})();
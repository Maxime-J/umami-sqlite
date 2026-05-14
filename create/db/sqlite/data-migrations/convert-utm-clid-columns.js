/*
* < v2.18 data conversion
*/

import 'dotenv/config';
import { PrismaClient } from '../generated/prisma/client.js';
import { PrismaSqlite } from 'prisma-adapter-sqlite';

const UTM_CLID_LENGTH = 255;

const columns = [
  'fbclid',
  'gclid',
  'li_fat_id',
  'msclkid',
  'ttclid',
  'twclid',
  'utm_campaign',
  'utm_content',
  'utm_medium',
  'utm_source',
  'utm_term',
];

const regexes = columns.reduce((acc, column) => {
  acc[column] = new RegExp(`(?:[&?]|^)${column}=([^&]+)`, 'i');
  return acc;
}, {});

const url = process.env.DATABASE_URL;
const adapter = new PrismaSqlite({ url });
const prisma = new PrismaClient({ adapter });

(async () => {
  try {
    const queries = [];
    const websiteEvents = await prisma.$queryRaw`SELECT event_id, url_query FROM website_event WHERE url_query <> ''`;

    websiteEvents.forEach(({ event_id, url_query }) => {
      const updates = [];

      for (const column of columns) {
        const match = url_query.match(regexes[column]);

        if (match) {
          updates.push(`${column} = '${match[1].substring(0, UTM_CLID_LENGTH)}'`);
        }
      }

      if (updates.length != 0) {
        queries.push(prisma.$executeRawUnsafe(
          `UPDATE website_event SET ${updates.join(', ')} WHERE event_id = '${event_id}'`
        ));
      }
    });

    await prisma.$transaction(queries);
    await prisma.$disconnect();
    console.log('Conversion completed.');
  } catch (e) {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  }
})();

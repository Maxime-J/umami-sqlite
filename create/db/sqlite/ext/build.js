import { spawnSync } from 'node:child_process';
import { rmSync } from 'node:fs';
import { join } from 'node:path';

const { dirname } = import.meta;

function cmake(args = []) {
  const { status } = spawnSync('cmake', args, {
    cwd: dirname,
    stdio: ['ignore', 'inherit', 'inherit']
  });
  if (status !== 0) throw new Error('SQLite extension build failed.');
}

try {
  cmake(['-B', 'build', '-DCMAKE_BUILD_TYPE=Release']);
  cmake(['--build', 'build', '--config', 'Release']);
} finally {
  rmSync(join(dirname, 'build'), { recursive: true });
}

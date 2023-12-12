import { registerPlugin } from '@capacitor/core';

import type { KaizenHealthkitPlugin } from './definitions';

const KaizenHealthkit = registerPlugin<KaizenHealthkitPlugin>(
  'KaizenHealthkit',
  {
    web: () => import('./web').then(m => new m.KaizenHealthkitWeb()),
  },
);

export * from './definitions';
export { KaizenHealthkit };

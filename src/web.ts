import { WebPlugin } from '@capacitor/core';

import type { KaizenHealthkitPlugin } from './definitions';

export class KaizenHealthkitWeb
  extends WebPlugin
  implements KaizenHealthkitPlugin
{
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

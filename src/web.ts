import { WebPlugin } from '@capacitor/core';

import type { KaizenHealthkitPlugin, QueryOutput, StatisticsData } from './definitions';

export class KaizenHealthkitWeb
  extends WebPlugin
  implements KaizenHealthkitPlugin
{
  async isAvailable(): Promise<void> {
    throw this.unimplemented('Not implemented on web.');
  }

  async requestAuthorization(): Promise<void> {
    throw this.unimplemented('Not implemented on web.');
  }

  async queryHKitStatistics(): Promise<StatisticsData> {
    throw this.unimplemented('Not implemented on web.');
  }

  async queryHKitSampleType<T>(): Promise<QueryOutput<T>> {
    throw this.unimplemented('Not implemented on web.');
  }
}

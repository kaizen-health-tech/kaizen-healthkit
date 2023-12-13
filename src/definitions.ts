export interface AuthorizationQueryOptions {
  read: string[];
  write: string[];
  all: string[];
}

export enum HealthCategories {
  STEP_COUNT = 'stepCount',
  SLEEP_ANALYSIS = 'sleepAnalysis',
  ACTIVE_ENERGY_BURNED = 'activeEnergyBurned',
  WEIGHT = 'weight',
  HEART_RATE = 'heartRate',
  OXYGEN_SATURATION = 'oxygenSaturation',
}

/**
 * These Basequeryoptions are always necessary for a query, they are extended by SingleQueryOptions and StatisticsQueryOptions.
 */
export interface BaseQueryOptions {
  startDate: string;
  endDate: string;
  operations: string[];
}

/**
 * This extends the Basequeryoptions for a statistics.
 */
export interface StatisticsQueryOptions extends BaseQueryOptions {
  quantityType: string;
}

export interface StatisticsData {
  sum?: number;
  average?: number;
  min?: number;
  max?: number;
  latest?: number;
  unitName: string;
}

export interface KaizenHealthkitPlugin {
  isAvailable(): Promise<void>;
  requestAuthorization(authOptions: AuthorizationQueryOptions): Promise<void>;
  queryHKitStatistics(queryOptions: StatisticsQueryOptions): Promise<StatisticsData>;
}

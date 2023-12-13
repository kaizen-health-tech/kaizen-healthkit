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

export interface DeviceInformation {
  name: string;
  manufacturer: string;
  model: string;
  hardwareVersion: string;
  softwareVersion: string;
}

/**
 * These data points are returned for every entry.
 */
export interface BaseData {
  startDate: string;
  endDate: string;
  source: string;
  uuid: string;
  sourceBundleId: string;
  device: DeviceInformation | null;
  duration: number;
}

/**
 * These data points are specific for sleep data.
 */
export interface SleepData extends BaseData  {
  sleepState: string;
  timeZone: string;
}

/**
 * These data points are specific for activities - not every activity automatically has a corresponding entry. 
 */
export interface ActivityData extends BaseData {
  totalFlightsClimbed: number;
  totalSwimmingStrokeCount: number;
  totalEnergyBurned: number;
  totalDistance: number;
  workoutActivityId: number;
  workoutActivityName: string;
}

/**
 * These datapoints are used in the plugin for ACTIVE_ENERGY_BURNED and STEP_COUNT.
 */
export interface OtherData extends BaseData {
  unitName: string;
  value: number;
}

/**
 * These Basequeryoptions are always necessary for a query, they are extended by SingleQueryOptions and StatisticsQueryOptions.
 */
export interface BaseQueryOptions {
  startDate: string;
  endDate: string;
}

/**
 * This extends the Basequeryoptions for a statistics.
 */
export interface StatisticsQueryOptions extends BaseQueryOptions {
  quantityType: string;
  operations: string[];
}

/**
 * This extends the Basequeryoptions for a single sample type.
 */
export interface SingleQueryOptions extends BaseQueryOptions {
  sampleName: string;
  limit: number;
}

/**
 * This interface is used for any results coming from HealthKit. It always has a count and the actual results.
 */
export interface QueryOutput<T = SleepData | ActivityData | OtherData> {
  countReturn: number;
  resultData: T[];
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
  queryHKitSampleType<T>(queryOptions:SingleQueryOptions): Promise<QueryOutput<T>>;
}

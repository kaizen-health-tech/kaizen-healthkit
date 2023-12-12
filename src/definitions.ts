export interface KaizenHealthkitPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}

import { WebPlugin } from '@capacitor/core';

import type {
  CapacitorSQLitePlugin,
  capEchoOptions,
  capSQLiteOptions,
  capSQLiteExecuteOptions,
  capSQLiteSetOptions,
  capSQLiteRunOptions,
  capSQLiteQueryOptions,
  capSQLiteImportOptions,
  capSQLiteExportOptions,
  capSQLiteSyncDateOptions,
  capSQLiteUpgradeOptions,
  capSQLiteTableOptions,
  capSQLitePathOptions,
  capEchoResult,
  capVersionResult,
  capSQLiteResult,
  capSQLiteChanges,
  capSQLiteValues,
  capSQLiteJson,
  capSQLiteSyncDate,
  capAllConnectionsOptions,
  capSetSecretOptions,
  capChangeSecretOptions,
  capSQLiteFromAssetsOptions,
} from './definitions';

export class CapacitorSQLiteWeb
  extends WebPlugin
  implements CapacitorSQLitePlugin {
  async echo(_options: capEchoOptions): Promise<capEchoResult> {
    throw new Error('Web platform is not supported.');
  }

  async isSecretStored(): Promise<capSQLiteResult> {
    throw new Error('Web platform is not supported.');
  }

  async setEncryptionSecret(_options: capSetSecretOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async changeEncryptionSecret(
    _options: capChangeSecretOptions,
  ): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async createConnection(_options: capSQLiteOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async open(_options: capSQLiteOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async closeConnection(_options: capSQLiteOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async getVersion(_options: capSQLiteOptions): Promise<capVersionResult> {
    throw new Error('Web platform is not supported.');
  }

  async checkConnectionsConsistency(
    _options: capAllConnectionsOptions,
  ): Promise<capSQLiteResult> {
    throw new Error('Web platform is not supported.');
  }

  async close(_options: capSQLiteOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async execute(_options: capSQLiteExecuteOptions): Promise<capSQLiteChanges> {
    throw new Error('Web platform is not supported.');
  }

  async executeSet(_options: capSQLiteSetOptions): Promise<capSQLiteChanges> {
    throw new Error('Web platform is not supported.');
  }

  async run(_options: capSQLiteRunOptions): Promise<capSQLiteChanges> {
    throw new Error('Web platform is not supported.');
  }

  async query(_options: capSQLiteQueryOptions): Promise<capSQLiteValues> {
    throw new Error('Web platform is not supported.');
  }

  async isDBExists(_options: capSQLiteOptions): Promise<capSQLiteResult> {
    throw new Error('Web platform is not supported.');
  }

  async isDBOpen(_options: capSQLiteOptions): Promise<capSQLiteResult> {
    throw new Error('Web platform is not supported.');
  }

  async isDatabase(_options: capSQLiteOptions): Promise<capSQLiteResult> {
    throw new Error('Web platform is not supported.');
  }

  async isTableExists(
    _options: capSQLiteTableOptions,
  ): Promise<capSQLiteResult> {
    throw new Error('Web platform is not supported.');
  }

  async deleteDatabase(_options: capSQLiteOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async isJsonValid(
    _options: capSQLiteImportOptions,
  ): Promise<capSQLiteResult> {
    throw new Error('Web platform is not supported.');
  }

  async importFromJson(
    _options: capSQLiteImportOptions,
  ): Promise<capSQLiteChanges> {
    throw new Error('Web platform is not supported.');
  }

  async exportToJson(_options: capSQLiteExportOptions): Promise<capSQLiteJson> {
    throw new Error('Web platform is not supported.');
  }

  async createSyncTable(_options: capSQLiteOptions): Promise<capSQLiteChanges> {
    throw new Error('Web platform is not supported.');
  }

  async setSyncDate(_options: capSQLiteSyncDateOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async getSyncDate(_options: capSQLiteOptions): Promise<capSQLiteSyncDate> {
    throw new Error('Web platform is not supported.');
  }

  async addUpgradeStatement(_options: capSQLiteUpgradeOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async copyFromAssets(_options: capSQLiteFromAssetsOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async getDatabaseList(): Promise<capSQLiteValues> {
    throw new Error('Web platform is not supported.');
  }

  async getMigratableDbList(
    _options: capSQLitePathOptions,
  ): Promise<capSQLiteValues> {
    throw new Error('Web platform is not supported.');
  }

  async addSQLiteSuffix(_options: capSQLitePathOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }

  async deleteOldDatabases(_options: capSQLitePathOptions): Promise<void> {
    throw new Error('Web platform is not supported.');
  }
}

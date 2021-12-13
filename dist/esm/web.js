import { WebPlugin } from '@capacitor/core';
export class CapacitorSQLiteWeb extends WebPlugin {
    async echo(_options) {
        throw new Error('Web platform is not supported.');
    }
    async isSecretStored() {
        throw new Error('Web platform is not supported.');
    }
    async setEncryptionSecret(_options) {
        throw new Error('Web platform is not supported.');
    }
    async changeEncryptionSecret(_options) {
        throw new Error('Web platform is not supported.');
    }
    async createConnection(_options) {
        throw new Error('Web platform is not supported.');
    }
    async open(_options) {
        throw new Error('Web platform is not supported.');
    }
    async closeConnection(_options) {
        throw new Error('Web platform is not supported.');
    }
    async getVersion(_options) {
        throw new Error('Web platform is not supported.');
    }
    async checkConnectionsConsistency(_options) {
        throw new Error('Web platform is not supported.');
    }
    async close(_options) {
        throw new Error('Web platform is not supported.');
    }
    async execute(_options) {
        throw new Error('Web platform is not supported.');
    }
    async executeSet(_options) {
        throw new Error('Web platform is not supported.');
    }
    async run(_options) {
        throw new Error('Web platform is not supported.');
    }
    async query(_options) {
        throw new Error('Web platform is not supported.');
    }
    async isDBExists(_options) {
        throw new Error('Web platform is not supported.');
    }
    async isDBOpen(_options) {
        throw new Error('Web platform is not supported.');
    }
    async isDatabase(_options) {
        throw new Error('Web platform is not supported.');
    }
    async isTableExists(_options) {
        throw new Error('Web platform is not supported.');
    }
    async deleteDatabase(_options) {
        throw new Error('Web platform is not supported.');
    }
    async isJsonValid(_options) {
        throw new Error('Web platform is not supported.');
    }
    async importFromJson(_options) {
        throw new Error('Web platform is not supported.');
    }
    async exportToJson(_options) {
        throw new Error('Web platform is not supported.');
    }
    async createSyncTable(_options) {
        throw new Error('Web platform is not supported.');
    }
    async setSyncDate(_options) {
        throw new Error('Web platform is not supported.');
    }
    async getSyncDate(_options) {
        throw new Error('Web platform is not supported.');
    }
    async addUpgradeStatement(_options) {
        throw new Error('Web platform is not supported.');
    }
    async copyFromAssets(_options) {
        throw new Error('Web platform is not supported.');
    }
    async getDatabaseList() {
        throw new Error('Web platform is not supported.');
    }
    async getMigratableDbList(_options) {
        throw new Error('Web platform is not supported.');
    }
    async addSQLiteSuffix(_options) {
        throw new Error('Web platform is not supported.');
    }
    async deleteOldDatabases(_options) {
        throw new Error('Web platform is not supported.');
    }
}
//# sourceMappingURL=web.js.map
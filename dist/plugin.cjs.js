'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

/**
 * SQLiteConnection Class
 */
class SQLiteConnection {
    constructor(sqlite) {
        this.sqlite = sqlite;
        this._connectionDict = new Map();
    }
    async echo(value) {
        try {
            const res = await this.sqlite.echo({ value });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async isSecretStored() {
        try {
            const res = await this.sqlite.isSecretStored();
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async setEncryptionSecret(passphrase) {
        try {
            await this.sqlite.setEncryptionSecret({ passphrase: passphrase });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async changeEncryptionSecret(passphrase, oldpassphrase) {
        try {
            await this.sqlite.changeEncryptionSecret({
                passphrase: passphrase,
                oldpassphrase: oldpassphrase,
            });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async addUpgradeStatement(database, fromVersion, toVersion, statement, set) {
        const upgrade = {
            fromVersion,
            toVersion,
            statement,
            set: set ? set : [],
        };
        try {
            if (database.endsWith('.db'))
                database = database.slice(0, -3);
            await this.sqlite.addUpgradeStatement({
                database,
                upgrade: [upgrade],
            });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async createConnection(database, encrypted, mode, version) {
        try {
            if (database.endsWith('.db'))
                database = database.slice(0, -3);
            await this.sqlite.createConnection({
                database,
                encrypted,
                mode,
                version,
            });
            const conn = new SQLiteDBConnection(database, this.sqlite);
            this._connectionDict.set(database, conn);
            return Promise.resolve(conn);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async closeConnection(database) {
        try {
            if (database.endsWith('.db'))
                database = database.slice(0, -3);
            await this.sqlite.closeConnection({ database });
            this._connectionDict.delete(database);
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async isConnection(database) {
        const res = {};
        if (database.endsWith('.db'))
            database = database.slice(0, -3);
        res.result = this._connectionDict.has(database);
        return Promise.resolve(res);
    }
    async retrieveConnection(database) {
        if (database.endsWith('.db'))
            database = database.slice(0, -3);
        if (this._connectionDict.has(database)) {
            const conn = this._connectionDict.get(database);
            if (typeof conn != 'undefined')
                return Promise.resolve(conn);
            else {
                return Promise.reject(`Connection ${database} is undefined`);
            }
        }
        else {
            return Promise.reject(`Connection ${database} does not exist`);
        }
    }
    async retrieveAllConnections() {
        return this._connectionDict;
    }
    async closeAllConnections() {
        const delDict = new Map();
        try {
            for (const database of this._connectionDict.keys()) {
                await this.sqlite.closeConnection({ database });
                delDict.set(database, null);
            }
            for (const database of delDict.keys()) {
                this._connectionDict.delete(database);
            }
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async checkConnectionsConsistency() {
        try {
            const keys = [...this._connectionDict.keys()];
            const res = await this.sqlite.checkConnectionsConsistency({ dbNames: keys });
            if (!res.result)
                this._connectionDict = new Map();
            return Promise.resolve(res);
        }
        catch (err) {
            this._connectionDict = new Map();
            return Promise.reject(err);
        }
    }
    async importFromJson(jsonstring) {
        try {
            const ret = await this.sqlite.importFromJson({ jsonstring: jsonstring });
            return Promise.resolve(ret);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async isJsonValid(jsonstring) {
        try {
            const ret = await this.sqlite.isJsonValid({ jsonstring: jsonstring });
            return Promise.resolve(ret);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async copyFromAssets(overwrite) {
        const mOverwrite = overwrite != null ? overwrite : true;
        try {
            await this.sqlite.copyFromAssets({ overwrite: mOverwrite });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async isDatabase(database) {
        if (database.endsWith('.db'))
            database = database.slice(0, -3);
        try {
            const res = await this.sqlite.isDatabase({ database: database });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async getDatabaseList() {
        try {
            const res = await this.sqlite.getDatabaseList();
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
}
/**
 * SQLiteDBConnection Class
 */
class SQLiteDBConnection {
    constructor(dbName, sqlite) {
        this.dbName = dbName;
        this.sqlite = sqlite;
    }
    getConnectionDBName() {
        return this.dbName;
    }
    async open() {
        try {
            await this.sqlite.open({ database: this.dbName });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async close() {
        try {
            await this.sqlite.close({ database: this.dbName });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async getVersion() {
        try {
            const version = await this.sqlite.getVersion({
                database: this.dbName,
            });
            return Promise.resolve(version);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async execute(statements, transaction = true) {
        try {
            const res = await this.sqlite.execute({
                database: this.dbName,
                statements: statements,
                transaction: transaction,
            });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async query(statement, values) {
        let res;
        try {
            if (values && values.length > 0) {
                res = await this.sqlite.query({
                    database: this.dbName,
                    statement: statement,
                    values: values,
                });
            }
            else {
                res = await this.sqlite.query({
                    database: this.dbName,
                    statement: statement,
                    values: [],
                });
            }
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async run(statement, values, transaction = true) {
        let res;
        try {
            if (values && values.length > 0) {
                res = await this.sqlite.run({
                    database: this.dbName,
                    statement: statement,
                    values: values,
                    transaction: transaction,
                });
                //        }
            }
            else {
                res = await this.sqlite.run({
                    database: this.dbName,
                    statement: statement,
                    values: [],
                    transaction: transaction,
                });
            }
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async executeSet(set, transaction = true) {
        try {
            const res = await this.sqlite.executeSet({
                database: this.dbName,
                set: set,
                transaction: transaction,
            });
            //      }
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async isExists() {
        try {
            const res = await this.sqlite.isDBExists({
                database: this.dbName,
            });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async isTable(table) {
        try {
            const res = await this.sqlite.isTableExists({
                database: this.dbName,
                table: table,
            });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async isDBOpen() {
        try {
            const res = await this.sqlite.isDBOpen({
                database: this.dbName,
            });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async delete() {
        try {
            await this.sqlite.deleteDatabase({ database: this.dbName });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async createSyncTable() {
        try {
            const res = await this.sqlite.createSyncTable({
                database: this.dbName,
            });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async setSyncDate(syncdate) {
        try {
            await this.sqlite.setSyncDate({
                database: this.dbName,
                syncdate: syncdate,
            });
            return Promise.resolve();
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async getSyncDate() {
        try {
            const res = await this.sqlite.getSyncDate({
                database: this.dbName,
            });
            let retDate = '';
            if (res.syncDate > 0)
                retDate = new Date(res.syncDate * 1000).toISOString();
            return Promise.resolve(retDate);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
    async exportToJson(mode) {
        try {
            const res = await this.sqlite.exportToJson({
                database: this.dbName,
                jsonexportmode: mode,
            });
            return Promise.resolve(res);
        }
        catch (err) {
            return Promise.reject(err);
        }
    }
}

const CapacitorSQLite = core.registerPlugin('CapacitorSQLite', {
    web: () => Promise.resolve().then(function () { return web; }).then(m => new m.CapacitorSQLiteWeb()),
});

class CapacitorSQLiteWeb extends core.WebPlugin {
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

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    CapacitorSQLiteWeb: CapacitorSQLiteWeb
});

exports.CapacitorSQLite = CapacitorSQLite;
exports.SQLiteConnection = SQLiteConnection;
exports.SQLiteDBConnection = SQLiteDBConnection;
//# sourceMappingURL=plugin.cjs.js.map

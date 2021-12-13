import Foundation
enum CapacitorSQLiteError: Error {
    case failed(message: String)
}
// swiftlint:disable file_length
// swiftlint:disable type_body_length
@objc public class CapacitorSQLite: NSObject {
    private var dbDict: [String: Database] = [:]

    // MARK: - Echo

    @objc public func echo(_ value: String) -> String {
        return value
    }

    // MARK: - IsSecretStored

    @objc public func isSecretStored()  throws -> NSNumber {
        let isSecretExists: Bool = UtilsSecret.isPassphrase()
        if isSecretExists {
            return 1
        } else {
            return 0
        }
    }

    // MARK: - SetEncryptionSecret

    @objc public func setEncryptionSecret(passphrase: String) throws {
        do {
            // close all connections
            try closeAllConnections()
            // set encryption secret
            try UtilsSecret.setEncryptionSecret(passphrase: passphrase)
            return
        } catch UtilsSecretError.setEncryptionSecret(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        } catch let error {
            throw CapacitorSQLiteError.failed(message: "\(error)")
        }
    }

    // MARK: - ChangeEncryptionSecret

    @objc public func changeEncryptionSecret(passphrase: String,
                                             oldPassphrase: String) throws {
        do {
            // close all connections
            try closeAllConnections()
            // set encryption secret
            try UtilsSecret.changeEncryptionSecret(passphrase: passphrase, oldPassphrase: oldPassphrase)
            return
        } catch UtilsSecretError.changeEncryptionSecret(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        } catch let error {
            throw CapacitorSQLiteError.failed(message: "\(error)")
        }

    }

    // MARK: - CreateConnection

    @objc public func createConnection(_ dbName: String,
                                       encrypted: Bool,
                                       mode: String,
                                       version: Int,
                                       vUpgDict: [Int: [String: Any]]) throws {
        // check if the connection already exists
        let conn = dbDict[dbName]
        if conn != nil {
            let msg = "Connection \(dbName) already exists"
            throw CapacitorSQLiteError.failed(message: msg)
        }

        do {
            let mDb: Database = try Database(
                databaseName: dbName,
                encrypted: encrypted, mode: mode, version: version,
                vUpgDict: vUpgDict)
            dbDict[dbName] = mDb
            return
        } catch let error {
            throw CapacitorSQLiteError.failed(message: "\(error)")
        }
    }

    // MARK: - Open

    @objc public func open(_ dbName: String) throws {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        do {
            try db.open()
            return
        } catch DatabaseError.open(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        }
    }

    // MARK: - Close

    @objc public func close(_ dbName: String) throws {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        do {
            try db.close()
            return
        } catch DatabaseError.close(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        }
    }

    // MARK: - GetVersion

    @objc public func getVersion(_ dbName: String) throws ->  NSNumber {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        do {
            let version: Int = try db.getVersion()
            return NSNumber(value: version)

        } catch DatabaseError.open(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        }
    }
    // MARK: - Close Connection

    @objc public func closeConnection(_ dbName: String) throws {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {
            do {
                try db.close()
            } catch DatabaseError.close(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            }
        }
        dbDict.removeValue(forKey: dbName)
        return
    }

    // MARK: - CheckConnectionsConsistency

    @objc public func checkConnectionsConsistency(_ dbNames: [String]) throws ->  NSNumber {
        var keys: [String] = Array(self.dbDict.keys)
        do {
            if dbNames.count == 0 {
                try closeAllConnections()
                return 0
            }
            if keys.count < dbNames.count {
                // not solvable inconsistency
                try closeAllConnections()
                return 0
            }
            if keys.count > dbNames.count {
                for key in keys {
                    if !dbNames.contains(key) {
                        self.dbDict.removeValue(forKey: key)
                    }
                }
            }
            keys = Array(self.dbDict.keys)
            if keys.count == dbNames.count {
                let set1 = Set(keys)
                let set2 = Set(dbNames)
                let arr = Array(set1.symmetricDifference(set2))
                if arr.count == 0 {
                    return 1
                } else {
                    // not solvable inconsistency
                    try closeAllConnections()
                    return 0
                }
            } else {
                try closeAllConnections()
                return 0
            }
        } catch let error {
            throw CapacitorSQLiteError.failed(message: "\(error)")
        }
    }
    // MARK: - IsDatabase

    @objc public func isDatabase(_ dbName: String) throws -> NSNumber {
        let isFileExists: Bool = UtilsFile
            .isFileExist(fileName: dbName)
        if isFileExists {
            return 1
        } else {
            return 0
        }
    }

    // MARK: - IsTableExists

    @objc public func isTableExists(_ dbName: String, tableName: String) throws -> NSNumber {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        do {
            let isExists: Bool = try
                UtilsJson.isTableExists(mDB: db,
                                        tableName: tableName)
            if isExists {
                return 1
            } else {
                return 0
            }
        } catch UtilsJsonError.tableNotExists(let message) {
            var msg: String = "IsTableExists:"
            msg.append(" \(message)")
            throw CapacitorSQLiteError.failed(message: msg)
        } catch let error {
            var msg: String = "IsTableExists:"
            msg.append(" \(error)")
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - Execute

    @objc public func execute(_ dbName: String, statements: String,
                              transaction: Bool)
    throws -> [String: Any] {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {
            do {
                var stmts = statements
                // remove carriage returns
                let isReturn = stmts.indicesOf(string: "\n")
                if isReturn.count != 0 {
                    let cmds = stmts.split(separator: "\n")
                    var strcmds: [String] = []
                    for cmd in cmds {
                        strcmds.append(String(cmd
                                                .trimmingCharacters(in: .whitespacesAndNewlines)))
                    }
                    stmts = strcmds.joined(separator: "\n")
                }
                let res = try db.executeSQL(sql: stmts,
                                             transaction: transaction)
                return ["changes": res]
            } catch DatabaseError.executeSQL(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - ExecuteSet

    @objc func executeSet(_ dbName: String, set: [[String: Any]],
                          transaction: Bool)
    throws -> [String: Any] {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {
            do {
                let res = try db.execSet(set: set, transaction: transaction)
                return res
            } catch DatabaseError.execSet(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - Run

    // swiftlint:disable cyclomatic_complexity
    @objc func run(_ dbName: String, statement: String, values: [Any],
                   transaction: Bool)
    throws -> [String: Any] {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {
            do {
                var val: [Any] = []
                if values.count > 0 {
                    for value in values {
                        if let obj = value as? String {
                            let str: String =
                                "\(String(describing: obj))"
                            val.append(str)
                        } else if let obj = value as? Int {
                            val.append(obj)
                        } else if let obj = value as? Float {
                            val.append(obj)
                        } else if let obj = value as? Double {
                            val.append(obj)
                        } else if value is NSNull {
                            val.append(value)
                        } else {
                            let msg: String = "Not a SQL type"
                            throw CapacitorSQLiteError.failed(message: msg)
                        }
                    }
                }
                let res = try db.runSQL(sql: statement, values: val,
                                         transaction: transaction)
                return res
            } catch DatabaseError.runSQL(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }
    // swiftlint:enable cyclomatic_complexity

    // MARK: - Query

    @objc func query(_ dbName: String, statement: String,
                     values: [Any]) throws -> [[String: Any]] {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {
            do {
                let res: [[String: Any]] = try db
                    .selectSQL(sql: statement, values: values)
                return res
            } catch DatabaseError.selectSQL(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - isDBExists

    @objc func isDBExists(_ dbName: String) throws -> NSNumber {
        guard let _: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        let res: Bool = UtilsFile
            .isFileExist(fileName: dbName)
        if res {
            return 1
        } else {
            return 0
        }
    }

    // MARK: - isDBOpen

    @objc func isDBOpen(_ dbName: String) throws -> NSNumber {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        let isOpen: Bool = db.isDBOpen()
        if isOpen {
            return 1
        } else {
            return 0
        }
    }

    // MARK: - deleteDatabase

    @objc func deleteDatabase(_ dbName: String) throws {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }

        do {
            if !db.isDBOpen() {
                try db.open()
            }
            let res: Bool = try db.deleteDB(
                databaseName: dbName)
            if res {
                return
            } else {
                let msg: String = "deleteDB return false"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } catch DatabaseError.open(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        } catch DatabaseError.deleteDB(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        } catch let error {
            let msg: String = "\(error)"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - isJsonValid

    @objc func isJsonValid(_ parsingData: String) throws {

        if let data = ("["+parsingData+"]").data(using: .utf8) {
            do {
                _ = try JSONDecoder().decode([JsonSQLite].self,
                                             from: data)
                return
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg: String = "Stringify Json Object not Valid"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - importFromJson

    // swiftlint:disable function_body_length
    @objc func importFromJson(_ parsingData: String)
    throws -> [String: Int] {
        var mDb: Database
        if let data = ("["+parsingData+"]").data(using: .utf8) {
            var jsonSQLite: [JsonSQLite]
            do {
                jsonSQLite = try JSONDecoder()
                    .decode([JsonSQLite].self, from: data)
            } catch let error {
                var msg: String = "Stringify Json Object not Valid "
                msg.append("\(error)")
                throw CapacitorSQLiteError.failed(message: msg)
            }
            let encrypted: Bool = jsonSQLite[0].encrypted
            let inMode: String = encrypted ? "secret"
                : "no-encryption"
            let version: Int = jsonSQLite[0].version
            let dbName: String = jsonSQLite[0].database
            // open the database
            do {
                mDb = try Database(
                    databaseName: dbName, encrypted: encrypted,
                    mode: inMode, version: version, vUpgDict: [:])
                try mDb.open()
            } catch DatabaseError.open(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
            // import from Json Object
            do {
                let res: [String: Int] = try mDb
                    .importFromJson(jsonSQLite: jsonSQLite[0])
                try mDb.close()
                if let result = res["changes"] {
                    if result < 0 {
                        let msg: String = "changes < 0"
                        throw CapacitorSQLiteError
                        .failed(message: msg)
                    } else {
                        return res
                    }
                } else {
                    let msg: String = "changes not found"
                    throw CapacitorSQLiteError.failed(message: msg)
                }
            } catch DatabaseError.importFromJson(let message) {
                var msg = message
                do {
                    try mDb.close()
                    throw CapacitorSQLiteError.failed(message: msg)
                } catch DatabaseError.close(let message) {
                    msg.append(" \(message)")
                    throw CapacitorSQLiteError.failed(message: msg)
                }
            } catch DatabaseError.close(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            }
        } else {
            let msg: String = "Stringify Json Object not Valid"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }
    // swiftlint:enable function_body_length

    // MARK: - exportToJson

    @objc func exportToJson(_ dbName: String, expMode: String)
    throws -> [String: Any] {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {

            do {
                let res: [String: Any] = try
                    db.exportToJson(expMode: expMode)
                if res.count == 5 || res.count == 6 {
                    return res
                } else {
                    var msg: String = "return Object is not a "
                    msg.append("JsonSQLite  Object")
                    throw CapacitorSQLiteError.failed(message: msg)
                }
            } catch DatabaseError.exportToJson(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - createSyncTable

    @objc func createSyncTable(_ dbName: String) throws -> NSNumber {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {
            do {
                let res: Int = try db.createSyncTable()
                return res as NSNumber
            } catch DatabaseError.createSyncTable(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - setSyncDate

    @objc func setSyncDate(_ dbName: String, syncDate: String)
    throws {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {

            do {
                let res: Bool = try db
                    .setSyncDate(syncDate: syncDate)
                if res {
                    return
                } else {
                    let msg: String = "return false"
                    throw CapacitorSQLiteError.failed(message: msg)
                }
            } catch DatabaseError.createSyncDate(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - getSyncDate

    @objc func getSyncDate(_ dbName: String) throws -> NSNumber {
        guard let db: Database = dbDict[dbName] else {
            let msg = "Connection to \(dbName) not available"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        if db.isDBOpen() {
            do {
                let res: Int64 = try db.getSyncDate()
                if res > 0 {
                    return res as NSNumber
                } else {
                    let msg: String = "return no sync date"
                    throw CapacitorSQLiteError.failed(message: msg)
                }
            } catch DatabaseError.getSyncDate(let message) {
                throw CapacitorSQLiteError.failed(message: message)
            } catch let error {
                let msg: String = "\(error)"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } else {
            let msg = "Database \(dbName) not opened"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - addUpgradeStatement

    @objc func addUpgradeStatement(_ dbName: String,
                                   upgrade: [[String: Any]])
    throws -> [Int: [String: Any]] {
        var upgDict: [String: Any] = [:]
        for dict in upgrade {
            let keys = dict.keys
            if !(keys.contains("fromVersion")) ||
                !(keys.contains("toVersion")) ||
                !(keys.contains("statement")) {
                var msg: String = "upgrade must have keys in "
                msg.append("{fromVersion,toVersion,statement}")
                throw CapacitorSQLiteError.failed(message: msg)
            }
            for (key, value) in dict {
                upgDict[key] = value
            }
        }
        guard let fromVersion = upgDict["fromVersion"] as? Int else {
            let msg: String = "fromVersion key must be an Int"
            throw CapacitorSQLiteError.failed(message: msg)
        }
        let upgVersionDict: [Int: [String: Any]] =
            [fromVersion: upgDict]
        return upgVersionDict
    }

    // MARK: - copyFromAssets

    @objc func copyFromAssets(overwrite: Bool) throws {

        // check if the assets/database folder exists
        do {
            let assetsDbPath: URL = try
                UtilsFile.getAssetsDatabasesPath()
            let aPath: String = assetsDbPath.path
            let bRes: Bool = UtilsFile.isDirExist(dirPath: aPath)
            if bRes {
                // get the zip files
                let zipList: [String] = try UtilsFile
                    .getFileList(path: aPath, ext: ".zip")
                // loop through the database files
                for zip in zipList {
                    // for each zip uncompress the file to the Application
                    // database folder
                    _ = try UtilsFile
                        .unzipFromAssetToDatabase(zip: zip, overwrite: overwrite)
                }
                return
            } else {
                let msg: String = "assets database path does not exist"
                throw CapacitorSQLiteError.failed(message: msg)
            }
        } catch UtilsFileError.copyFromAssetToDatabaseFailed(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        } catch UtilsFileError.unzipFromAssetToDatabaseFailed(let message) {
            throw CapacitorSQLiteError.failed(message: message)
        } catch let error {
            let msg: String = "\(error)"
            throw CapacitorSQLiteError.failed(message: msg)
        }
    }

    // MARK: - getDatabaseList

    @objc func getDatabaseList() throws -> [String] {
        do {
            let aPath: String = try UtilsFile.getDatabasesPath()
            // get the database files
            let dbList: [String] = try UtilsFile.getFileList(path: aPath, ext: ".db")
            return dbList

        } catch let error {
            let msg: String = "\(error)"
            throw CapacitorSQLiteError.failed(message: msg)
        }

    }

    func closeAllConnections() throws {
        let keys: [String] = Array(self.dbDict.keys)

        for key in keys {
            guard let mDb: Database = dbDict[key] else {
                let msg = "Connection to \(key) not available"
                throw CapacitorSQLiteError.failed(message: msg)
            }
            if mDb.isDBOpen() {
                do {
                    try mDb.close()
                } catch DatabaseError.close(let message) {
                    throw CapacitorSQLiteError.failed(message: message)
                }
            }
            dbDict.removeValue(forKey: key)
        }
        return
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length

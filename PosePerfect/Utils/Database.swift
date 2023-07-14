import SQLite
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: Connection?

    private let data = Table("data")
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let metadata = Expression<String>("metadata")
    private let videoName = Expression<String?>("videoName")
    private let videoExist = Expression<Bool?>("videoExist")
    private let difficulty = Expression<Int>("difficulty")
    private let length = Expression<Int>("length")

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        db = try? Connection("\(path)/db.sqlite3")

        if let db = db {
            _ = try? db.run(data.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(metadata)
                t.column(videoName)
                t.column(videoExist)
                t.column(difficulty)
                t.column(length)
            })
        }
    }

    func getCount() -> Int {
        if let db = db {
            if let count = try? db.scalar(data.count) {
                return count
            }
        }
        return 0
    }

    func insertData(name: String, metadata: String, difficulty: Int, length: Int) -> Int64? {
        if let db = db {
            let insert = data.insert(self.name <- name, self.metadata <- metadata, self.difficulty <- difficulty, self.length <- length)
            if let rowId = try? db.run(insert) {
                return rowId
            }
        }
        return nil
    }

    func getAllData() -> [(String, Int, Int, Int64)] {
        var result: [(String, Int, Int, Int64)] = []
        if let db = db {
            for row in try! db.prepare(data) {
                result.append((row[name], row[difficulty], row[length], row[id]))
            }
        }
        return result
    }

    func getVideoExist(id: Int64) -> Bool? {
        if let db = db {
            if let row = try? db.pluck(data.filter(self.id == id)) {
                return row[videoExist]
            }
        }
        return nil
    }

    func getMetadata(id: Int64) -> String? {
        if let db = db {
            if let row = try? db.pluck(data.filter(self.id == id)) {
                return row[metadata]
            }
        }
        return nil
    }
    
    func deleteData(id: Int64) -> Bool {
        if let db = db {
            let item = data.filter(self.id == id)
            if let changes = try? db.run(item.delete()), changes > 0 {
                // If changes > 0, delete operation was performed successfully
                return true
            }
        }
        // If function reaches this point, delete operation was unsuccessful
        return false
    }
    
    func deleteAllData() -> Bool {
        if let db = db {
            if let changes = try? db.run(data.delete()), changes > 0 {
                // If changes > 0, delete operation was performed successfully
                return true
            }
        }
        // If function reaches this point, delete operation was unsuccessful
        return false
    }

}

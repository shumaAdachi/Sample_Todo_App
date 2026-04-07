import SQLite3
import Foundation

class DBHelper {
    var db: OpaquePointer?

    init() {
        openDatabase()
        createTables()
        insertInitialData()
    }

    func openDatabase() {
        let fileURL = try! FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("todo.sqlite")
        sqlite3_open(fileURL.path, &db)
    }

    func createTables() {
        let queries = [
            "CREATE TABLE IF NOT EXISTS month_master (id INTEGER PRIMARY KEY, name TEXT);",
            "CREATE TABLE IF NOT EXISTS day_master (id INTEGER PRIMARY KEY AUTOINCREMENT, day INTEGER, month_id INTEGER);",
            "CREATE TABLE IF NOT EXISTS genre_master (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);",
            "CREATE TABLE IF NOT EXISTS todos (id TEXT PRIMARY KEY, title TEXT, date TEXT, memo TEXT, startTime TEXT, endTime TEXT, isDone INTEGER, genre TEXT);"
        ]
        for query in queries {
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK { sqlite3_step(stmt) }
            sqlite3_finalize(stmt)
        }
        sqlite3_exec(db, "ALTER TABLE todos ADD COLUMN genre TEXT;", nil, nil, nil)
    }

    func fetchStats() -> (total: Int, done: Int) {
        var total = 0; var done = 0
        let query = "SELECT COUNT(*), SUM(CASE WHEN isDone = 1 THEN 1 ELSE 0 END) FROM todos;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                total = Int(sqlite3_column_int(stmt, 0))
                done = Int(sqlite3_column_int(stmt, 1))
            }
        }
        sqlite3_finalize(stmt)
        return (total, done)
    }

    func fetchGenres() -> [String] {
        var genres: [String] = []
        let query = "SELECT name FROM genre_master ORDER BY id ASC;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                genres.append(String(cString: sqlite3_column_text(stmt, 0)!))
            }
        }
        sqlite3_finalize(stmt)
        return genres.isEmpty ? ["仕事", "プライベート", "その他"] : genres
    }

    func insertGenre(name: String) {
        let query = "INSERT INTO genre_master (name) VALUES (?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func insertTodo(_ todo: Todo) {
        let query = "INSERT OR REPLACE INTO todos (id, title, date, memo, startTime, endTime, isDone, genre) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            let f = ISO8601DateFormatter()
            sqlite3_bind_text(stmt, 1, (todo.id.uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (todo.タイトル as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (f.string(from: todo.日付) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (todo.備考 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (f.string(from: todo.開始時間) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (f.string(from: todo.終了時間) as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, todo.完了 ? 1 : 0)
            sqlite3_bind_text(stmt, 8, (todo.ジャンル as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func fetchTodos() -> [Todo] {
        var todos: [Todo] = []
        let query = "SELECT id, title, date, memo, startTime, endTime, isDone, genre FROM todos ORDER BY date ASC;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            let f = ISO8601DateFormatter()
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0)!)) ?? UUID()
                let title = String(cString: sqlite3_column_text(stmt, 1)!)
                let date = f.date(from: String(cString: sqlite3_column_text(stmt, 2)!)) ?? Date()
                let memo = String(cString: sqlite3_column_text(stmt, 3)!)
                let start = f.date(from: String(cString: sqlite3_column_text(stmt, 4)!)) ?? Date()
                let end = f.date(from: String(cString: sqlite3_column_text(stmt, 5)!)) ?? Date()
                let done = sqlite3_column_int(stmt, 6) != 0
                let gPtr = sqlite3_column_text(stmt, 7)
                let genre = gPtr != nil ? String(cString: gPtr!) : "未分類"
                todos.append(Todo(id: id, タイトル: title, 日付: date, 備考: memo, 開始時間: start, 終了時間: end, 完了: done, ジャンル: genre))
            }
        }
        sqlite3_finalize(stmt)
        return todos
    }

    func insertInitialData() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        for month in 1...12 {
            let mQuery = "INSERT OR IGNORE INTO month_master (id, name) VALUES (?, ?);"
            var mStmt: OpaquePointer?
            if sqlite3_prepare_v2(db, mQuery, -1, &mStmt, nil) == SQLITE_OK {
                sqlite3_bind_int(mStmt, 1, Int32(month)); sqlite3_bind_text(mStmt, 2, ("\(month)月" as NSString).utf8String, -1, nil)
                sqlite3_step(mStmt)
            }
            sqlite3_finalize(mStmt)
            let comps = DateComponents(year: year, month: month)
            if let date = calendar.date(from: comps), let range = calendar.range(of: .day, in: .month, for: date) {
                for day in range {
                    let dQuery = "INSERT INTO day_master (day, month_id) SELECT ?, ? WHERE NOT EXISTS (SELECT 1 FROM day_master WHERE day = ? AND month_id = ?);"
                    var dStmt: OpaquePointer?
                    if sqlite3_prepare_v2(db, dQuery, -1, &dStmt, nil) == SQLITE_OK {
                        sqlite3_bind_int(dStmt, 1, Int32(day)); sqlite3_bind_int(dStmt, 2, Int32(month))
                        sqlite3_bind_int(dStmt, 3, Int32(day)); sqlite3_bind_int(dStmt, 4, Int32(month))
                        sqlite3_step(dStmt)
                    }
                    sqlite3_finalize(dStmt)
                }
            }
        }
    }
    
    func insertMonth(name: String) {
        var maxId: Int = 0
        let q = "SELECT MAX(id) FROM month_master;"
        var s: OpaquePointer?
        if sqlite3_prepare_v2(db, q, -1, &s, nil) == SQLITE_OK { if sqlite3_step(s) == SQLITE_ROW { maxId = Int(sqlite3_column_int(s, 0)) } }
        sqlite3_finalize(s)
        let finalName = name.hasSuffix("月") ? name : name + "月"
        let qIn = "INSERT OR IGNORE INTO month_master (id, name) VALUES (?, ?);"
        var sIn: OpaquePointer?
        if sqlite3_prepare_v2(db, qIn, -1, &sIn, nil) == SQLITE_OK {
            sqlite3_bind_int(sIn, 1, Int32(maxId + 1)); sqlite3_bind_text(sIn, 2, (finalName as NSString).utf8String, -1, nil)
            sqlite3_step(sIn)
        }
        sqlite3_finalize(sIn)
    }
    
    func fetchMonths() -> [(id: Int, name: String)] {
        var res: [(id: Int, name: String)] = []
        let q = "SELECT id, name FROM month_master ORDER BY id ASC;"
        var s: OpaquePointer?
        if sqlite3_prepare_v2(db, q, -1, &s, nil) == SQLITE_OK {
            while sqlite3_step(s) == SQLITE_ROW { res.append((id: Int(sqlite3_column_int(s, 0)), name: String(cString: sqlite3_column_text(s, 1)!))) }
        }
        sqlite3_finalize(s); return res
    }
    
    func fetchDays(forMonth mId: Int) -> [Int] {
        var days: [Int] = []
        let q = "SELECT day FROM day_master WHERE month_id = ? ORDER BY day ASC;"
        var s: OpaquePointer?
        if sqlite3_prepare_v2(db, q, -1, &s, nil) == SQLITE_OK {
            sqlite3_bind_int(s, 1, Int32(mId))
            while sqlite3_step(s) == SQLITE_ROW { days.append(Int(sqlite3_column_int(s, 0))) }
        }
        sqlite3_finalize(s); return Array(Set(days)).sorted()
    }
    
    func insertDay(monthId: Int, day: Int) {
        let q = "INSERT OR IGNORE INTO day_master (day, month_id) VALUES (?, ?);"
        var s: OpaquePointer?
        if sqlite3_prepare_v2(db, q, -1, &s, nil) == SQLITE_OK {
            sqlite3_bind_int(s, 1, Int32(day)); sqlite3_bind_int(s, 2, Int32(monthId)); sqlite3_step(s)
        }
        sqlite3_finalize(s)
    }
    
    func deleteMonth(id: Int) {
        let q = "DELETE FROM month_master WHERE id = ?;"
        var s: OpaquePointer?
        if sqlite3_prepare_v2(db, q, -1, &s, nil) == SQLITE_OK { sqlite3_bind_int(s, 1, Int32(id)); sqlite3_step(s) }
        sqlite3_finalize(s)
    }
    
    func deleteDay(monthId: Int, day: Int) {
        let q = "DELETE FROM day_master WHERE month_id = ? AND day = ?;"
        var s: OpaquePointer?
        if sqlite3_prepare_v2(db, q, -1, &s, nil) == SQLITE_OK {
            sqlite3_bind_int(s, 1, Int32(monthId)); sqlite3_bind_int(s, 2, Int32(day)); sqlite3_step(s)
        }
        sqlite3_finalize(s)
    }
    func deleteAllTodos() {
        let q = "DELETE FROM todos;"
        var s: OpaquePointer?
        if sqlite3_prepare_v2(db, q, -1, &s, nil) == SQLITE_OK {
            sqlite3_step(s)
        }
        sqlite3_finalize(s)
    }
}

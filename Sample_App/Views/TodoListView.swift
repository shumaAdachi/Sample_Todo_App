import SwiftUI
import SQLite3

struct TodoListView: View {
    // $をつけずに、ただの配列として管理する
    @State private var todos: [Todo] = []
    @State private var activeSheet: ActiveSheet? = nil
    @State private var db = DBHelper()

    enum ActiveSheet: Identifiable {
        case add, admin
        var id: String { switch self { case .add: return "a"; case .admin: return "m" } }
    }

    var body: some View {
        NavigationStack {
            List {
                // $を外して、シンプルな todos に変更
                ForEach(todos) { todo in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(todo.タイトル).font(.headline)
                            HStack {
                                Text(todo.ジャンル)
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1)).cornerRadius(4).foregroundColor(.blue)
                                Text(todo.日付, style: .date).font(.caption).foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        // 完了ボタンも index を直接操作するように修正
                        Button {
                            toggleCompletion(for: todo)
                        } label: {
                            Image(systemName: todo.完了 ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(todo.完了 ? .green : .gray)
                        }.buttonStyle(.plain)
                    }
                }
                .onDelete(perform: deleteTodo)
            }
            .navigationTitle("Todoリスト")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("追加") { activeSheet = .add }
                    Button("管理者") { activeSheet = .admin }
                }
            }
            .onAppear {
                refreshData()
            }
            .sheet(item: $activeSheet) { item in
                switch item {
                case .add:
                    AddTodoView(db: db) {
                        refreshData() // 保存された時だけリフレッシュ
                    }
                case .admin:
                    AdminTodoView(db: db)
                }
            }
        }
    }

    // データを読み直す共通関数
    private func refreshData() {
        self.todos = db.fetchTodos()
    }

    // 完了ボタンの処理
    private func toggleCompletion(for todo: Todo) {
        var updatedTodo = todo
        updatedTodo.完了.toggle()
        db.insertTodo(updatedTodo)
        refreshData() // DBを更新してリストを読み直す
    }

    // 削除処理
    private func deleteTodo(at offsets: IndexSet) {
        for index in offsets {
            let todo = todos[index]
            let q = "DELETE FROM todos WHERE id = ?;"
            var s: OpaquePointer?
            if sqlite3_prepare_v2(db.db, q, -1, &s, nil) == SQLITE_OK {
                sqlite3_bind_text(s, 1, (todo.id.uuidString as NSString).utf8String, -1, nil)
                sqlite3_step(s)
            }
            sqlite3_finalize(s)
        }
        refreshData()
    }
}

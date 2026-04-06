import SwiftUI

struct TodoListView: View {
    @State private var todos: [Todo] = []
    @State private var 表示追加画面 = false
    @State private var 表示カレンダー画面 = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($todos) { $todo in
                    NavigationLink {
                        EditTodoView(todo: $todo)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(todo.タイトル)
                                    .font(.headline)
                                Text(todo.日付, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button {
                                todo.完了.toggle()
                            } label: {
                                Image(systemName: todo.完了 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.完了 ? .green : .gray)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    todos.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Todoリスト")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("カレンダー") { 表示カレンダー画面 = true }
                    Button("追加しますよ") { 表示追加画面 = true }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $表示追加画面) {
                AddTodoView(todos: $todos)
            }
            .sheet(isPresented: $表示カレンダー画面) {
                CalendarView(todos: $todos)
            }
        }
    }
}

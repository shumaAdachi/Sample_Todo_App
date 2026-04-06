import SwiftUI

struct TodoDetailView: View {
    @Binding var todo: Todo // 渡された特定のTodoを直接書き換える
    @Environment(\.dismiss) var 閉じる

    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                TextField("タイトル", text: .constant(todo.タイトル))
                    .disabled(true)

                DatePicker("日付", selection: .constant(todo.日付), displayedComponents: .date)
                    .disabled(true)
            }

            Section(header: Text("時間設定")) {
                DatePicker("開始", selection: .constant(todo.開始時間), displayedComponents: .hourAndMinute)
                    .disabled(true)

                DatePicker("終了", selection: .constant(todo.終了時間), displayedComponents: .hourAndMinute)
                    .disabled(true)
            }

            Section(header: Text("メモ")) {
                TextEditor(text: .constant(todo.備考))
                    .frame(minHeight: 100)
                    .disabled(true)
            }
        }
        .navigationTitle("予定の詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

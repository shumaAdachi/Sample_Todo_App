import SwiftUI

struct TodoDetailView: View {
    @Binding var todo: Todo // 渡された特定のTodoを直接書き換える
    @Environment(\.dismiss) var 閉じる

    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                TextField("タイトル", text: $todo.タイトル)
                DatePicker("日付", selection: $todo.日付, displayedComponents: .date)
            }

            Section(header: Text("時間設定")) {
                DatePicker("開始", selection: $todo.開始時間, displayedComponents: .hourAndMinute)
                DatePicker("終了", selection: $todo.終了時間, displayedComponents: .hourAndMinute)
            }

            Section(header: Text("メモ")) {
                TextEditor(text: $todo.備考)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("予定の詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

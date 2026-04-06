import SwiftUI

struct AddTodoView: View {
    @Binding var todos: [Todo]
    @Environment(\.dismiss) var 閉じる

    @State private var タイトル = ""
    @State private var 備考 = "" // 追加
    @State private var 開始時間 = Date() // 追加
    @State private var 終了時間 = Date().addingTimeInterval(3600) // 1時間後を初期値に
    @State private var 日付 = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("情報")) {
                    TextField("タイトルを入力", text: $タイトル)
                    DatePicker("日付", selection: $日付, displayedComponents: .date)
                }

                Section(header: Text("時間設定")) {
                    // displayedComponentsに .hourAndMinute を指定
                    DatePicker("開始時間", selection: $開始時間, displayedComponents: .hourAndMinute)
                    DatePicker("終了時間", selection: $終了時間, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("メモ")) {
                    // TextEditorを使うと複数行の入力がしやすくなります
                    TextEditor(text: $備考)
                        .frame(minHeight: 100) // 備考欄っぽく高さを確保
                }
            }
            .navigationTitle("Todo追加")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        // TODO: Todo構造体に 備考, 開始時間, 終了時間 を追加してください
                        let newTodo = Todo(
                            タイトル: タイトル,
                            日付: 日付,
                            備考: 備考,
                            開始時間: 開始時間,
                            終了時間: 終了時間,
                            完了: false
                        )
                        todos.append(newTodo)
                        閉じる()
                    }
                    .disabled(タイトル.isEmpty) // タイトル未入力なら保存不可にする工夫
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { 閉じる() }
                }
            }
        }
    }
}

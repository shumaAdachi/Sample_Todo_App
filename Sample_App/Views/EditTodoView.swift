import SwiftUI

struct EditTodoView: View {
    @Binding var todo: Todo

    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                TextField("タイトルを編集", text: $todo.タイトル)
                DatePicker("日付を編集", selection: $todo.日付, displayedComponents: .date)
                Toggle("完了", isOn: $todo.完了)
            }

            Section(header: Text("時間")) {
                DatePicker("開始時間", selection: $todo.開始時間, displayedComponents: .hourAndMinute)
                DatePicker("終了時間", selection: $todo.終了時間, displayedComponents: .hourAndMinute)
            }
        }
        .onChange(of: todo.開始時間) { newValue in  // ←ここ！！
            if todo.終了時間 < newValue {
                todo.終了時間 = newValue
            }
        }
        .navigationTitle("編集")
    }
}

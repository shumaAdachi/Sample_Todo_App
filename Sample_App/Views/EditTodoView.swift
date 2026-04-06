import SwiftUI

struct EditTodoView: View {
    @Binding var todo: Todo

    var body: some View {
        Form {
            TextField("タイトルを編集", text: $todo.タイトル)
            DatePicker("日付を編集", selection: $todo.日付, displayedComponents: .date)
            Toggle("完了", isOn: $todo.完了)
        }
        .navigationTitle("Todo編集")
    }
}

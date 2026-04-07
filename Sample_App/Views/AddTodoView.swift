import SwiftUI

struct AddTodoView: View {
    let db: DBHelper
    var onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var タイトル = ""
    @State private var 備考 = ""
    @State private var 選択ジャンル = "仕事"
    @State private var 選択月 = 1
    @State private var 選択日 = 1
    @State private var 開始時間 = Date()
    @State private var 終了時間 = Date()
    
    @State private var months: [(id: Int, name: String)] = []
    @State private var days: [Int] = []
    @State private var genreList: [String] = []

    // 1. アラートを表示するかどうかを管理する変数
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("タイトル", text: $タイトル)
                Picker("ジャンル", selection: $選択ジャンル) {
                    ForEach(genreList, id: \.self) { g in Text(g) }
                }
                Section(header: Text("日付")) {
                    Picker("月", selection: $選択月) {
                        ForEach(months, id: \.id) { m in Text(m.name).tag(m.id) }
                    }.onChange(of: 選択月) { _ in updateDays() }
                    Picker("日", selection: $選択日) {
                        ForEach(days, id: \.self) { d in Text("\(d)日").tag(d) }
                    }
                }
                Section(header: Text("時間")) {
                    DatePicker("開始", selection: $開始時間, displayedComponents: .hourAndMinute)
                    DatePicker("終了", selection: $終了時間, displayedComponents: .hourAndMinute)
                }
                TextField("備考", text: $備考)
            }
            .navigationTitle("予定の追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        // 2. タイトルが空（またはスペースのみ）の場合
                        if タイトル.trimmingCharacters(in: .whitespaces).isEmpty {
                            showAlert = true // アラートを表示
                            return           // ここで処理を中断
                        }

                        let newTodo = Todo(
                            タイトル: タイトル,
                            日付: createDate(),
                            備考: 備考,
                            開始時間: 開始時間,
                            終了時間: 終了時間,
                            完了: false,
                            ジャンル: 選択ジャンル
                        )

                        db.insertTodo(newTodo)
                        onSave()
                        dismiss()
                    }
                }
            }
            // 3. アラートの中身を定義
            .alert("入力エラー", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text("タイトルは必須項目です。")
            }
            .onAppear {
                months = db.fetchMonths()
                if let first = months.first { 選択月 = first.id }
                genreList = db.fetchGenres()
                選択ジャンル = genreList.first ?? "仕事"
                updateDays()
            }
        }
    }

    private func updateDays() {
        let regDays = db.fetchDays(forMonth: 選択月)
        if !regDays.isEmpty { days = regDays }
        else {
            let cal = Calendar.current
            var comps = DateComponents()
            comps.year = cal.component(.year, from: Date())
            comps.month = 選択月
            if let date = cal.date(from: comps), let range = cal.range(of: .day, in: .month, for: date) {
                days = Array(range)
            } else { days = [1] }
        }
        if !days.contains(選択日) { 選択日 = days.first ?? 1 }
    }

    private func createDate() -> Date {
        var comps = DateComponents()
        comps.year = Calendar.current.component(.year, from: Date())
        comps.month = 選択月; comps.day = 選択日
        return Calendar.current.date(from: comps) ?? Date()
    }
}

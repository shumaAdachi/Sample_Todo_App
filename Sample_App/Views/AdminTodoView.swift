import SwiftUI

struct AdminTodoView: View {
    let db: DBHelper
    @State private var months: [(id: Int, name: String)] = []
    @State private var days: [Int] = []
    @State private var selectedMonthId: Int = 1
    @State private var selectedDay: Int = 1
    
    // 統計・ジャンル用
    @State private var totalCount: Int = 0
    @State private var doneCount: Int = 0
    @State private var showAddGenreAlert = false
    @State private var newGenreInput = ""

    @State private var showDeleteAlert = false
    @State private var showAddDayAlert = false
    @State private var showAddMonthAlert = false
    @State private var showSuccessAlert = false
    @State private var newDayInput: String = ""
    @State private var newMonthNameInput: String = ""
    @State private var successMessage: String = ""
    @State private var deleteTarget: DeleteTarget? = nil
    
    // 全削除用のフラグを追加
    @State private var showAllDeleteConfirm = false

    enum DeleteTarget { case month, day }

    var body: some View {
        NavigationStack {
            VStack {
                // --- ダッシュボード (統計) ---
                HStack(spacing: 15) {
                    VStack {
                        Text("全Todo数").font(.caption).foregroundColor(.secondary)
                        Text("\(totalCount)").font(.title2).bold()
                    }
                    .frame(maxWidth: .infinity).padding().background(Color.blue.opacity(0.1)).cornerRadius(12)
                    
                    VStack {
                        Text("完了済み").font(.caption).foregroundColor(.secondary)
                        Text("\(doneCount)").font(.title2).bold().foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity).padding().background(Color.green.opacity(0.1)).cornerRadius(12)
                }
                .padding()

                Form {
                    Section(header: Text("ジャンル設定")) {
                        Button("ジャンルを追加") { showAddGenreAlert = true }
                    }

                    Section(header: Text("月マスタ管理")) {
                        Picker("月", selection: $selectedMonthId) {
                            ForEach(months, id: \.id) { m in Text(m.name).tag(m.id) }
                        }
                        .pickerStyle(.wheel).frame(height: 100).clipped()
                        .onChange(of: selectedMonthId) { _ in updateDays() }
                        HStack {
                            Button(role: .destructive) { deleteTarget = .month; showDeleteAlert = true } label: { Label("削除", systemImage: "trash") }.buttonStyle(.bordered)
                            Spacer()
                            Button { newMonthNameInput = ""; showAddMonthAlert = true } label: { Label("月を追加", systemImage: "plus") }.buttonStyle(.bordered)
                        }
                    }

                    Section(header: Text("日マスタ管理")) {
                        Picker("日", selection: $selectedDay) {
                            ForEach(days, id: \.self) { d in Text("\(d)日").tag(d) }
                        }
                        .pickerStyle(.wheel).frame(height: 100).clipped()
                        HStack {
                            Button(role: .destructive) { deleteTarget = .day; showDeleteAlert = true } label: { Label("削除", systemImage: "trash") }.buttonStyle(.bordered)
                            Spacer()
                            Button { newDayInput = ""; showAddDayAlert = true } label: { Label("日を追加", systemImage: "plus") }.buttonStyle(.bordered)
                        }
                    }

                    // ★追加：データリセットセクション
                    Section(header: Text("データリセット"), footer: Text("消せないデータがある場合はここから全削除してください")) {
                        Button(role: .destructive) {
                            showAllDeleteConfirm = true
                        } label: {
                            Label("全てのTodoを削除する", systemImage: "exclamationmark.triangle.fill")
                        }
                    }
                }
            }
            .navigationTitle("管理者画面")
            .onAppear { refreshAll() }
            
            // 全削除の確認アラート
            .alert("全削除の確認", isPresented: $showAllDeleteConfirm) {
                Button("全てのTodoを消去", role: .destructive) {
                    db.deleteAllTodos() // DBHelperにこの関数が必要です
                    refreshAll()
                    successMessage = "全ての予定を削除しました"
                    showSuccessAlert = true
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この操作は取り消せません。本当によろしいですか？")
            }

            // その他既存のアラート類
            .alert("ジャンルの追加", isPresented: $showAddGenreAlert) {
                TextField("仕事, 趣味 など", text: $newGenreInput)
                Button("追加") {
                    if !newGenreInput.isEmpty {
                        db.insertGenre(name: newGenreInput)
                        successMessage = "ジャンル「\(newGenreInput)」を追加しました"
                        showSuccessAlert = true
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
            .alert("削除の確認", isPresented: $showDeleteAlert) { Button("削除", role: .destructive) { executeDelete() } }
            .alert("月の追加", isPresented: $showAddMonthAlert) {
                TextField("例: 13", text: $newMonthNameInput)
                Button("追加") {
                    db.insertMonth(name: newMonthNameInput); refreshAll()
                    successMessage = "月の追加が完了しました"; showSuccessAlert = true
                }
            }
            .alert("日の追加", isPresented: $showAddDayAlert) {
                TextField("例: 32", text: $newDayInput).keyboardType(.numberPad)
                Button("追加") {
                    if let d = Int(newDayInput) {
                        db.insertDay(monthId: selectedMonthId, day: d); updateDays()
                        successMessage = "\(d)日を追加しました"; showSuccessAlert = true
                    }
                }
            }
            .alert("完了", isPresented: $showSuccessAlert) { Button("OK") {} } message: { Text(successMessage) }
        }
    }
    
    private func refreshAll() {
        months = db.fetchMonths()
        updateDays()
        let stats = db.fetchStats()
        totalCount = stats.total
        doneCount = stats.done
    }
    private func updateDays() { days = db.fetchDays(forMonth: selectedMonthId) }
    private func executeDelete() {
        if deleteTarget == .month { db.deleteMonth(id: selectedMonthId); refreshAll() }
        else { db.deleteDay(monthId: selectedMonthId, day: selectedDay); updateDays() }
    }
}

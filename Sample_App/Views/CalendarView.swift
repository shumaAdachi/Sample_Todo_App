import SwiftUI

struct CalendarView: View {
    @Binding var todos: [Todo]
    @Environment(\.dismiss) var 閉じる

    @State private var 選択日 = Date()
    @State private var 表示月 = Date()

    private let calendar = Calendar.current
    private let 曜日 = ["日", "月", "火", "水", "木", "金", "土"]

    // --- ロジック部分 ---

    var 今月の日付一覧: [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: 表示月))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    var 最初の曜日の空白数: Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: 表示月))!
        return calendar.component(.weekday, from: startOfMonth) - 1
    }

    func 予定あり(_ 日付: Date) -> Bool {
        todos.contains { calendar.isDate($0.日付, inSameDayAs: 日付) }
    }

    func 月移動(_ 値: Int) {
        if let 新しい月 = calendar.date(byAdding: .month, value: 値, to: 表示月) {
            表示月 = 新しい月
        }
    }

    // --- UI部分 ---

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 月切り替えヘッダー
                HStack {
                    Button(action: { 月移動(-1) }) {
                        Image(systemName: "chevron.left").font(.title2)
                    }
                    Spacer()
                    Text("\(calendar.component(.year, from: 表示月))年 \(calendar.component(.month, from: 表示月))月")
                        .font(.headline)
                    Spacer()
                    Button(action: { 月移動(1) }) {
                        Image(systemName: "chevron.right").font(.title2)
                    }
                }
                .padding()

                // 曜日ラベル
                HStack {
                    ForEach(曜日, id: \.self) { day in
                        Text(day).frame(maxWidth: .infinity).font(.caption).foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // カレンダーグリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(0..<最初の曜日の空白数, id: \.self) { _ in
                        Text("")
                    }

                    ForEach(今月の日付一覧, id: \.self) { 日付 in
                        VStack(spacing: 4) {
                            Text("\(calendar.component(.day, from: 日付))")
                                .frame(width: 35, height: 35)
                                .background(calendar.isDate(日付, inSameDayAs: 選択日) ? Color.blue : Color.clear)
                                .foregroundColor(calendar.isDate(日付, inSameDayAs: 選択日) ? .white : .primary)
                                .clipShape(Circle())
                                .onTapGesture { 選択日 = 日付 }

                            Circle()
                                .fill(予定あり(日付) ? Color.red : Color.clear)
                                .frame(width: 6, height: 6)
                        }
                        .frame(height: 60)
                    }
                }
                .padding()

                Divider()

                // 予定リスト
                List {
                    // 選択された日付に一致するTodoのインデックスを取得
                    let 表示対象のIndex = todos.indices.filter {
                        calendar.isDate(todos[$0].日付, inSameDayAs: 選択日)
                    }
                    
                    if 表示対象のIndex.isEmpty {
                        Text("予定はありません")
                            .foregroundColor(.gray)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(表示対象のIndex, id: \.self) { index in
                            // 詳細画面へのリンク
                            NavigationLink(destination: TodoDetailView(todo: $todos[index])) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(todos[index].タイトル)
                                            .font(.headline)
                                        // 時間を表示 (14:00 〜 15:00 のような形式)
                                        Text("\(todos[index].開始時間, style: .time) 〜 \(todos[index].終了時間, style: .time)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if todos[index].完了 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in
                            // スワイプ削除機能
                            offsets.forEach { index in
                                let targetId = todos[表示対象のIndex[index]].id
                                todos.removeAll { $0.id == targetId }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("カレンダー")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { 閉じる() }
                }
            }
        }
    }
}

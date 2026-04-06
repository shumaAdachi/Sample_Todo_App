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
                    
                    // 年月の表示（エラー回避のための確実な書き方）
                    Text(String(calendar.component(.year, from: 表示月)) + "年 " + String(calendar.component(.month, from: 表示月)) + "月")
                        .font(.headline)
                    
                    Spacer()
                    Button(action: { 月移動(1) }) {
                        Image(systemName: "chevron.right").font(.title2)
                    }
                }
                .padding()

                // 曜日ヘッダー
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
                    let 表示対象のIndex = todos.indices.filter {
                        calendar.isDate(todos[$0].日付, inSameDayAs: 選択日)
                    }
                    
                    if 表示対象のIndex.isEmpty {
                        Text("予定が存在していません")
                            .foregroundColor(.gray)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(表示対象のIndex, id: \.self) { index in
                            NavigationLink(destination: TodoDetailView(todo: $todos[index])) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        // --- 期限切れ判定ロジック ---
                                        let todoDate = calendar.startOfDay(for: todos[index].日付)
                                        let today = calendar.startOfDay(for: Date())
                                        
                                        let todoTime = calendar.dateComponents([.hour, .minute], from: todos[index].終了時間)
                                        let nowTime = calendar.dateComponents([.hour, .minute], from: Date())
                                        
                                        // 「今日より前の日」か「今日かつ時間が過ぎている」か
                                        let isPastTime = (nowTime.hour! > todoTime.hour!) || (nowTime.hour! == todoTime.hour! && nowTime.minute! > todoTime.minute!)
                                        let isOverdue = (todoDate < today || (todoDate == today && isPastTime)) && !todos[index].完了
                                        
                                        // タイトル（期限切れなら赤、完了済みなら黒）
                                        Text(todos[index].タイトル)
                                            .font(.headline)
                                            .foregroundColor(isOverdue ? .red : .primary)
                                        
                                        // 時間表示（期限切れなら赤、完了済みならグレー）
                                        Text("\(todos[index].開始時間, style: .time) 〜 \(todos[index].終了時間, style: .time)")
                                            .font(.caption)
                                            .foregroundColor(isOverdue ? .red : .secondary)
                                            .fontWeight(isOverdue ? .bold : .regular)
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

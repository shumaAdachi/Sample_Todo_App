import Foundation

struct Todo: Identifiable {
    let id = UUID()
        var タイトル: String
        var 日付: Date
        var 備考: String    // 追加
        var 開始時間: Date // 追加
        var 終了時間: Date // 追加
        var 完了: Bool
}

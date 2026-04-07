import Foundation

struct Todo: Identifiable ,Codable{  // ← Codable を追加
    var id: UUID = UUID()
    var タイトル: String
    var 日付: Date
    var 備考: String
    var 開始時間: Date
    var 終了時間: Date
    var 完了: Bool
    var ジャンル: String
}

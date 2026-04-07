import SwiftUI

struct DayPickerView: View {
    @Binding var selectedDate: Date
    var days: [Int]
    var onSelect: (Int) -> Void
    @Environment(\.dismiss) var 閉じる

    var body: some View {
        List {
            ForEach(days, id: \.self) { day in
                Button("\(day)日") {
                    onSelect(day)
                    閉じる()
                }
            }
        }
    }
}

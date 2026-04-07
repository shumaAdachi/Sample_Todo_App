import SwiftUI

struct MonthPickerView: View {
    var months: [(id: Int, name: String)]
    var onSelect: (Int) -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List(months, id: \.id) { month in
            Button(month.name) {
                onSelect(month.id)
                dismiss()
            }
        }
    }
}

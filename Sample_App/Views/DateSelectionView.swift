import SwiftUI

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    let db: DBHelper

    @State private var selectedMonthId: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())

    var body: some View {
        VStack {
            Picker("月", selection: $selectedMonthId) {
                ForEach(db.fetchMonths(), id: \.id) { month in
                    Text(month.name).tag(month.id)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxHeight: 150)

            let days = db.fetchDays(forMonth: selectedMonthId)
            Picker("日", selection: $selectedDay) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    Text("\(day)日").tag(day)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxHeight: 150)

            Button("決定") {
                var comps = Calendar.current.dateComponents([.year], from: Date())
                comps.month = selectedMonthId
                comps.day = selectedDay
                selectedDate = Calendar.current.date(from: comps) ?? Date()
            }
            .padding()
        }
        .onChange(of: selectedMonthId) { newMonth in
            let availableDays = db.fetchDays(forMonth: newMonth)
            if !availableDays.contains(selectedDay) {
                selectedDay = availableDays.first ?? 1
            }
        }
    }
}

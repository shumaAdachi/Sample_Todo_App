import Foundation

enum Month: Int, CaseIterable {
    case m1 = 1
    case m2 = 2
    case m3 = 3
    case m4 = 4
    case m5 = 5
    case m6 = 6
    case m7 = 7
    case m8 = 8
    case m9 = 9
    case m10 = 10
    case m11 = 11
    case m12 = 12

    var name: String { "\(self.rawValue)月" }
}

func days(in month: Int, year: Int) -> [Int] {
    let calendar = Calendar.current
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    let date = calendar.date(from: comps)!
    let range = calendar.range(of: .day, in: .month, for: date)!
    return Array(range)
}

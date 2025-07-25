import Foundation

extension Date {
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func monthYearString(language: Language) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: language == .english ? "en_US" : "pl_PL")
        return formatter.string(from: self)
    }
    
    func dayOfMonth() -> Int {
        return Calendar.current.component(.day, from: self)
    }
    
    static func generateDaysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        let firstWeekday = calendar.component(.weekday, from: startDate)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        days += range.map { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
        
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
}

import SwiftUI

// MARK: – Date Extension for Generating Month Grid
extension Date {
    static func generateDaysInMonth(
        for baseDate: Date,
        using calendar: Calendar
    ) -> [Date?] {
        // 1. Oblicz pierwszy dzień miesiąca
        let comps = calendar.dateComponents([.year, .month], from: baseDate)
        guard let firstOfMonth = calendar.date(from: comps) else { return [] }
        
        // 2. Dzień tygodnia dla 1. dnia miesiąca
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        
        // 3. Oblicz offset pustych komórek (z uwzględnieniem firstWeekday)
        let offset = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        
        // 4. Ile dni ma ten miesiąc
        let daysInMonth = calendar.range(of: .day, in: .month, for: baseDate)!.count
        
        // 5. Zbuduj tablicę z opcjonalnymi Date (nil = pusta kratka)
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    var tasks: [Task]
    let onSingleTap: (Date) -> Void
    let onDoubleTap: (Date) -> Void

    // MARK: – Nasz własny Calendar (poniedziałek jako pierwszy dzień tygodnia)
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "pl_PL")
        cal.firstWeekday = 2
        return cal
    }
    
    var body: some View {
        let days = Date.generateDaysInMonth(for: currentMonth, using: calendar)
        let today = Date()

        VStack(spacing: 8) {
            // 2. Siatka dni
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 7),
                spacing: 10
            ) {
                ForEach(0..<days.count, id: \.self) { index in
                    if let date = days[index] {
                        let taskCount = numberOfTasks(for: date)
                        let isToday = calendar.isDate(date, inSameDayAs: today)
                        let isCurrentMonth = calendar.isDate(
                            date,
                            equalTo: currentMonth,
                            toGranularity: .month
                        )

                        CalendarDayView(
                            date: date,
                            isToday: isToday,
                            isCurrentMonth: isCurrentMonth,
                            taskCount: taskCount,
                            onSingleTap: { onSingleTap(date) },
                            onDoubleTap: { onDoubleTap(date) }
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: – Pomocnicza metoda
    private func numberOfTasks(for date: Date) -> Int {
        tasks.filter { $0.date.isSameDay(as: date) }.count
    }
}

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    var tasks: [Task]
    let onSingleTap: (Date) -> Void
    let onDoubleTap: (Date) -> Void
    
    var body: some View {
        let days = Date.generateDaysInMonth(for: currentMonth)
        let today = Date() // Dzisiejsza data
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(0..<days.count, id: \.self) { index in
                if let date = days[index] {
                    let taskCount = numberOfTasks(for: date)
                    let isToday = date.isSameDay(as: today) // Sprawdź czy to dzisiaj
                    
                    CalendarDayView(
                        date: date,
                        isToday: isToday, // Przekazujemy informację czy to dzisiaj
                        isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        taskCount: taskCount,
                        onSingleTap: {
                            onSingleTap(date)
                        },
                        onDoubleTap: {
                            onDoubleTap(date)
                        }
                    )
                } else {
                    Text("")
                        .frame(height: 40)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func numberOfTasks(for date: Date) -> Int {
        tasks.filter { $0.date.isSameDay(as: date) }.count
    }
}

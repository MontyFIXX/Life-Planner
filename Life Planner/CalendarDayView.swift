import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let isToday: Bool // Zmienione z isSelected
    let isCurrentMonth: Bool
    let taskCount: Int
    let onSingleTap: () -> Void
    let onDoubleTap: () -> Void
    
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    @State private var tapTask: DispatchWorkItem?
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(date.dayOfMonth())")
                .foregroundColor(
                    isToday ? .white : // Podświetlenie dla dzisiaj
                    (isCurrentMonth ? selectedTheme.textColor : selectedTheme.textColor.opacity(0.5))
                )
                .frame(width: 30, height: 30)
                .background(isToday ? selectedTheme.textColor : Color.clear) // Kolor tła dla dzisiaj
                .clipShape(Circle())
            
            // Wizualizacja liczby zadań
            if taskCount > 0 {
                if taskCount <= 3 {
                    HStack(spacing: 2) {
                        ForEach(0..<taskCount, id: \.self) { _ in
                            Circle()
                                .fill(selectedTheme.textColor)
                                .frame(width: 5, height: 5)
                        }
                    }
                } else {
                    Text("\(taskCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(selectedTheme.textColor)
                        .frame(width: 16, height: 16)
                        .background(Circle().fill(selectedTheme.textColor.opacity(0.2)))
                }
            }
        }
        .frame(height: 50)
        .background(isToday ? selectedTheme.textColor.opacity(0.2) : Color.clear) // Subtelne tło dla dzisiaj
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(selectedTheme.textColor.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(8)
        .opacity(isCurrentMonth ? 1.0 : 0.6)
        .onTapGesture(count: 2) {
            tapTask?.cancel()
            onDoubleTap()
        }
        .onTapGesture {
            tapTask?.cancel()
            
            let task = DispatchWorkItem {
                onSingleTap()
            }
            
            tapTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: task)
        }
    }
}

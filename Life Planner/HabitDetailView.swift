import SwiftUI

struct HabitDetailView: View {
    @Binding var habit: Habit
    let language: Language
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1

    var body: some View {
        VStack {
            // Progress section
            Text("\(LocalizedString.str("Progress", language: language)): \(progressPercentage)%")
                .font(.title)
                .padding()
                .foregroundColor(selectedTheme.textColor)
                .background(selectedTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(10)
                .padding(.horizontal)
            
            HeartProgressView(progress: progressRate)
                .frame(height: 200)
                .padding()
            
            // Days list
            List {
                ForEach(0..<habit.goalDays, id: \.self) { dayIndex in
                    if let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: habit.creationDate) {
                        let isCompleted = isDateCompleted(date)
                        
                        HStack {
                            Text(date, style: .date)
                                .foregroundColor(selectedTheme.textColor)
                            
                            Spacer()
                            
                            Button {
                                habit.toggleCompletion(for: date)
                            } label: {
                                Image(systemName: isCompleted ? "heart.fill" : "heart")
                                    .foregroundColor(isCompleted ? .pink : Color(hex: habit.colorHex))
                                    .font(.title2)
                            }
                        }
                        .padding(10)
                        .listRowBackground(selectedTheme.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .listStyle(PlainListStyle())
            .applyTheme()
        }
        .applyTheme()
        .background(selectedTheme.backgroundColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(selectedTheme.textColor)
            }
        }
    }
    
    // Helper properties
    private var progressRate: Double {
        Double(habit.completionDates.count) / Double(habit.goalDays)
    }
    
    private var progressPercentage: Int {
        Int(progressRate * 100)
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return habit.completionDates.contains { Calendar.current.isDate($0, inSameDayAs: normalizedDate) }
    }
}

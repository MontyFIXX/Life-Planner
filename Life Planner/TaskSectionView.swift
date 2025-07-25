import SwiftUI

struct TaskSectionView: View {
    let title: String
    let tasks: [Task]
    let onToggleTask: (Task) -> Void
    let language: Language // Dodajemy język
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal)
                .foregroundColor(selectedTheme.textColor)
            
            if tasks.isEmpty {
                Text(LocalizedString.str("No tasks", language: language)) // Poprawione tłumaczenie
                    .opacity(0.6)
                    .padding(.horizontal)
                    .foregroundColor(selectedTheme.textColor)
            } else {
                ForEach(tasks) { task in
                    HStack {
                        Button {
                            onToggleTask(task)
                        } label: {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                        }
                        
                        Circle()
                            .fill(Color(hex: task.colorHex))
                            .frame(width: 12, height: 12)
                        
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(selectedTheme.textColor)
                        
                        Spacer()
                        
                        if let start = task.startTime, let end = task.endTime {
                            Text("\(start, style: .time)-\(end, style: .time)")
                                .font(.caption)
                                .opacity(0.7)
                                .foregroundColor(selectedTheme.textColor)
                        }
                    }
                    .padding()
                    .background(selectedTheme.backgroundColor.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .applyTheme()
    }
}

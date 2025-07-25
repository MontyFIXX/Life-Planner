import SwiftUI

struct TaskListPopupView: View {
    let date: Date
    @Binding var tasks: [Task]
    @Binding var isPresented: Bool
    let language: Language
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskStartTime = Date()
    @State private var newTaskEndTime = Date().addingTimeInterval(3600)
    @State private var selectedColor = Color.blue
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = language == .english ? "MMMM d, yyyy" : "d MMMM yyyy"
        formatter.locale = Locale(identifier: language == .english ? "en_US" : "pl_PL")
        return formatter
    }
    
    private var filteredTasks: [Task] {
        tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: date)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(dateFormatter.string(from: date))
                    .font(.title2)
                    .padding()
                    .foregroundColor(selectedTheme.textColor)
                    .background(selectedTheme.backgroundColor)
                
                if filteredTasks.isEmpty {
                    VStack {
                        Text(LocalizedString.str("No tasks for this day", language: language))
                            .opacity(0.6)
                            .padding()
                            .foregroundColor(selectedTheme.textColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(selectedTheme.backgroundColor)
                    }
                    .background(selectedTheme.backgroundColor)
                } else {
                    List {
                        ForEach(filteredTasks.indices, id: \.self) { index in
                            let task = filteredTasks[index]
                            
                            HStack {
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
                                
                                Button {
                                    if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                                        tasks[taskIndex].isCompleted.toggle()
                                    }
                                } label: {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                }
                            }
                            .padding(10)
                            .listRowBackground(selectedTheme.backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let taskToRemove = filteredTasks[index]
                                if let taskIndex = tasks.firstIndex(where: { $0.id == taskToRemove.id }) {
                                    tasks.remove(at: taskIndex)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(selectedTheme.backgroundColor)
                    .scrollContentBackground(.hidden) // Dodane, aby ukryć domyślne tło listy
                }
                
                Spacer()
            }
            .applyTheme()
            .background(selectedTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(LocalizedString.str("Close", language: language)) {
                    isPresented = false
                }
                .foregroundColor(selectedTheme.textColor),
                
                trailing: Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(selectedTheme.textColor)
                }
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedString.str("Tasks", language: language))
                        .font(.headline)
                        .foregroundColor(selectedTheme.textColor)
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskPopupView(
                    isPresented: $showingAddTask,
                    title: $newTaskTitle,
                    startTime: $newTaskStartTime,
                    endTime: $newTaskEndTime,
                    selectedColor: $selectedColor,
                    date: date,
                    onSave: {
                        addNewTask(for: date)
                    },
                    language: language
                )
                .applyTheme()
            }
        }
        .applyTheme()
        .background(selectedTheme.backgroundColor.ignoresSafeArea())
    }
    
    private func addNewTask(for date: Date) {
        guard !newTaskTitle.isEmpty else { return }
        
        let newTask = Task(
            title: newTaskTitle,
            date: date,
            startTime: newTaskStartTime,
            endTime: newTaskEndTime,
            colorHex: selectedColor.toHex(),
            isCompleted: false
        )
        
        tasks.append(newTask)
        newTaskTitle = ""
    }
}

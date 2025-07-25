import SwiftUI

struct MainView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var appData = AppData.shared
    @State private var showingTaskPopup = false
    @State private var showingTaskListPopup = false
    @State private var newTaskTitle = ""
    @State private var newTaskStartTime = Date()
    @State private var newTaskEndTime = Date().addingTimeInterval(3600)
    @State private var selectedColor = Color.blue
    @State private var currentMonth = Date()
    @State private var selectedTab = 0
    
    @AppStorage("selectedLanguage") private var selectedLanguage = Language.english.rawValue
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    
    private var language: Language {
        Language(rawValue: selectedLanguage) ?? .english
    }
    
    private var daysOfWeek: [String] {
        language == .english ?
        ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"] :
        ["PN", "WT", "ŚR", "CZW", "PT", "SOB", "ND"]
    }
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Screen
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Month navigation header
                        HStack {
                            Button {
                                changeMonth(by: -1)
                            } label: {
                                Image(systemName: "chevron.left")
                                    .padding()
                                    .foregroundColor(selectedTheme.textColor)
                            }
                            
                            Spacer()
                            
                            Text(currentMonth.monthYearString(language: language).capitalized)
                                .font(.title.bold())
                                .foregroundColor(selectedTheme.textColor)
                            
                            Spacer()
                            
                            Button {
                                changeMonth(by: 1)
                            } label: {
                                Image(systemName: "chevron.right")
                                    .padding()
                                    .foregroundColor(selectedTheme.textColor)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Days of week
                        HStack {
                            ForEach(daysOfWeek, id: \.self) { day in
                                Text(day)
                                    .frame(maxWidth: .infinity)
                                    .font(.subheadline)
                                    .opacity(0.7)
                                    .foregroundColor(selectedTheme.textColor)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Calendar
                        CalendarView(
                            selectedDate: $appData.selectedDate,
                            currentMonth: $currentMonth,
                            tasks: appData.tasks,
                            onSingleTap: { date in
                                appData.selectedDate = date
                                showingTaskListPopup = true
                            },
                            onDoubleTap: { date in
                                appData.selectedDate = date
                                showingTaskPopup = true
                            }
                        )
                        
                        // Today's tasks
                        TaskSectionView(
                            title: LocalizedString.str("Today's Tasks", language: language),
                            tasks: todayTasks,
                            onToggleTask: { task in
                                if let index = appData.tasks.firstIndex(where: { $0.id == task.id }) {
                                    var updatedTask = appData.tasks[index]
                                    updatedTask.isCompleted.toggle()
                                    appData.saveTask(updatedTask)
                                }
                            },
                            language: language
                        )
                        
                        // Today's habits
                        // MARK: – Today’s Habits Section
                        VStack(alignment: .leading) {
                            Text(LocalizedString.str("Today's Habits", language: language))
                                .font(.title2.bold())
                                .padding(.horizontal)
                                .foregroundColor(selectedTheme.textColor)
                            
                            if todayHabits.isEmpty {
                                Text(LocalizedString.str("No habits today", language: language))
                                    .opacity(0.6)
                                    .padding(.horizontal)
                                    .foregroundColor(selectedTheme.textColor)
                            } else {
                                ForEach(todayHabits, id: \.id) { habit in
                                    HStack {
                                        Button {
                                            // 1. Znajdujemy indeks w appData.habits
                                            if let index = appData.habits.firstIndex(where: { $0.id == habit.id }) {
                                                // 2. Modyfikujemy kopię i przypisujemy ją z powrotem
                                                var updatedHabit = appData.habits[index]
                                                updatedHabit.toggleCompletion()
                                                appData.habits[index] = updatedHabit
                                                
                                                // 3. Zapis do Firestore / lokalnie
                                                appData.saveHabit(updatedHabit)
                                            }
                                        } label: {
                                            Image(systemName: habit.isCompletedToday ? "heart.fill" : "heart")
                                                .foregroundColor(
                                                    habit.isCompletedToday
                                                        ? .pink
                                                        : Color(hex: habit.colorHex)
                                                )
                                                .font(.title)
                                        }
                                        
                                        Text(habit.title)
                                            .foregroundColor(selectedTheme.textColor)
                                        
                                        Spacer()
                                        
                                        Text("\(habit.completionDates.count)/\(habit.goalDays)")
                                            .opacity(0.6)
                                            .foregroundColor(selectedTheme.textColor)
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
                    }
                    .padding(.bottom)
                }
                .applyTheme()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(LocalizedString.str("Life Planner", language: language))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(selectedTheme.textColor)
                    }
                }
                .sheet(isPresented: $showingTaskPopup) {
                    TaskPopupView(
                        isPresented: $showingTaskPopup,
                        title: $newTaskTitle,
                        startTime: $newTaskStartTime,
                        endTime: $newTaskEndTime,
                        selectedColor: $selectedColor,
                        date: appData.selectedDate,
                        onSave: addNewTask,
                        language: language
                    )
                    .applyTheme()
                }
                .sheet(isPresented: $showingTaskListPopup) {
                    TaskListPopupView(
                        date: appData.selectedDate,
                        tasks: $appData.tasks,
                        isPresented: $showingTaskListPopup,
                        language: language
                    )
                    .applyTheme()
                }
            }
            .tabItem {
                Image(systemName: "house")
                Text(LocalizedString.str("Home", language: language))
            }
            .tag(0)
            
            // Habit Tracker Screen
            HabitTrackerView(language: language)
                .environmentObject(appData)
                .background(selectedTheme.backgroundColor.ignoresSafeArea())
                .tabItem {
                    Image(systemName: "heart")
                        .renderingMode(.template)
                    Text(LocalizedString.str("Habits", language: language))
                }
                .tag(1)
            
            // Groups Screen
            NavigationView {
                Text(LocalizedString.str("Groups", language: language))
                    .applyTheme()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(selectedTheme.backgroundColor.ignoresSafeArea())
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(LocalizedString.str("Groups", language: language))
                                .font(.headline)
                                .foregroundColor(selectedTheme.textColor)
                        }
                    }
            }
            .applyTheme()
            .background(selectedTheme.backgroundColor.ignoresSafeArea())
            .tabItem {
                Image(systemName: "person.2")
                    .renderingMode(.template)
                Text(LocalizedString.str("Groups", language: language))
            }
            .tag(2)
            
            // Settings Screen
            SettingsView()
                .applyTheme()
                .background(selectedTheme.backgroundColor.ignoresSafeArea())
                .tabItem {
                    Image(systemName: "gear")
                        .renderingMode(.template)
                    Text(LocalizedString.str("Settings", language: language))
                }
                .tag(3)
            
            // Profile Screen
            NavigationView {
                ProfileView()
                    .applyTheme()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(selectedTheme.backgroundColor.ignoresSafeArea())
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(LocalizedString.str("Profile", language: language))
                                .font(.headline)
                                .foregroundColor(selectedTheme.textColor)
                        }
                    }
            }
            .applyTheme()
            .background(selectedTheme.backgroundColor.ignoresSafeArea())
            .tabItem {
                Image(systemName: "person.crop.circle")
                    .renderingMode(.template)
                Text(LocalizedString.str("Profile", language: language))
            }
            .tag(4)
        }
                .accentColor(selectedTheme.textColor)
                .applyTheme()
                .environmentObject(appData)
                .onChange(of: authService.isSignedIn) { isSignedIn in
                    if isSignedIn {
                        appData.loadData()
                    } else {
                        appData.clearData()
                    }
                }
            }
            
            private var todayTasks: [Task] {
                appData.tasks.filter { $0.date.isSameDay(as: Date()) }
            }
            
    private var todayHabits: [Habit] {
        let today = Calendar.current.startOfDay(for: Date())

        return appData.habits.filter { habit in
            // 1) czy dziś jest w przedziale [creationDate, creationDate+goalDays)?
            let startDay = Calendar.current.startOfDay(for: habit.creationDate)
            guard let daysSinceStart = Calendar.current.dateComponents(
                    [.day], from: startDay, to: today
            ).day else { return false }
            let isWithinGoal = daysSinceStart >= 0 && daysSinceStart < habit.goalDays

            // 2) już nie filtrujemy po isDoneToday
            return isWithinGoal
        }
    }
            private func changeMonth(by value: Int) {
                if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
                    currentMonth = newMonth
                    if let firstDay = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: newMonth)) {
                        appData.selectedDate = firstDay
                    }
                }
            }
            
            private func addNewTask() {
                guard !newTaskTitle.isEmpty else { return }
                
                let newTask = Task(
                    title: newTaskTitle,
                    date: appData.selectedDate,
                    startTime: newTaskStartTime,
                    endTime: newTaskEndTime,
                    colorHex: selectedColor.toHex(),
                    isCompleted: false,
                    userID: authService.currentUser?.id
                )
                
                appData.saveTask(newTask)
                newTaskTitle = ""
            }
        }

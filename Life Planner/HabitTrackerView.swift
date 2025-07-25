import SwiftUI

struct HabitTrackerView: View {
    @EnvironmentObject var appData: AppData
    @State private var showingAddHabit = false
    @State private var newHabitTitle = ""
    @State private var selectedColor = Color.blue
    @State private var goalDays = 30
    let language: Language
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            List {
                // Bindowanie do tablicy na podstawie Identifiable
                ForEach($appData.habits) { $habit in
                    NavigationLink(destination: HabitDetailView(habit: $habit,
                                                               language: language)) {
                        HStack {
                            Circle()
                                .fill(Color(hex: habit.colorHex))
                                .frame(width: 20, height: 20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.title)
                                    .foregroundColor(selectedTheme.textColor)
                                
                                // Zamiast completionHistory: liczymy po prostu completionDates
                                Text("\(habit.completionDates.count)/\(habit.goalDays) "
                                     + LocalizedString.str("days", language: language))
                                    .font(.caption)
                                    .opacity(0.7)
                                    .foregroundColor(selectedTheme.textColor)
                            }
                            
                            Spacer()
                            
                            // W locie obliczamy % ukończenia
                            let rate = Double(habit.completionDates.count) / Double(habit.goalDays)
                            Text("\(Int(rate * 100))%")
                                .font(.headline)
                                .foregroundColor(selectedTheme.textColor)
                        }
                        .padding(10)
                        .background(selectedTheme.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .listRowBackground(selectedTheme.backgroundColor)
                    .listRowSeparatorTint(selectedTheme.textColor.opacity(0.3))
                }
                .onDelete(perform: deleteHabits)
            }
            .id(refreshID)
            .applyTheme()
            .listStyle(PlainListStyle())
            .background(selectedTheme.backgroundColor)
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedString.str("Habits", language: language))
                        .font(.headline)
                        .foregroundColor(selectedTheme.textColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(selectedTheme.textColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(
                    title:          $newHabitTitle,
                    selectedColor:  $selectedColor,
                    goalDays:       $goalDays,
                    onSave: {
                        addNewHabit()
                        refreshID = UUID()
                    },
                    language: language
                )
                .applyTheme()
            }
        }
        .applyTheme()
        .background(selectedTheme.backgroundColor.ignoresSafeArea())
    }
    
    // MARK: - Actions
    
    private func addNewHabit() {
        guard !newHabitTitle.isEmpty else { return }
        let newHabit = Habit(
            title:        newHabitTitle,
            colorHex:     selectedColor.toHex(),
            goalDays:     goalDays
        )
        appData.habits.append(newHabit)
        newHabitTitle = ""
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        appData.habits.remove(atOffsets: offsets)
    }
}

import SwiftUI

struct AddHabitView: View {
    @Binding var title: String
    @Binding var selectedColor: Color
    @Binding var goalDays: Int
    let onSave: () -> Void
    let language: Language

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var authService: AuthService
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1

    var body: some View {
        NavigationView {
            ZStack {
                // 1. Tło całego ekranu
                selectedTheme.backgroundColor
                    .ignoresSafeArea()

                Form {
                    Section(
                        header: Text(LocalizedString.str("New Habit", language: language))
                            .foregroundColor(selectedTheme.textColor)
                    ) {
                        TextField(
                            LocalizedString.str("Habit Name", language: language),
                            text: $title
                        )
                        .foregroundColor(selectedTheme.textColor)
                        .listRowBackground(selectedTheme.backgroundColor)

                        Stepper(
                            "\(LocalizedString.str("Goal", language: language)): \(goalDays) \(LocalizedString.str("days", language: language))",
                            value: $goalDays,
                            in: 1...365
                        )
                        .tint(selectedTheme.textColor)
                        .listRowBackground(selectedTheme.backgroundColor)

                        ColorPicker(
                            LocalizedString.str("Color", language: language),
                            selection: $selectedColor
                        )
                        .tint(selectedTheme.textColor)
                        .listRowBackground(selectedTheme.backgroundColor)
                    }
                }
                .background(selectedTheme.backgroundColor)
                .tint(selectedTheme.textColor)                     // iOS 15+
                .scrollContentBackground(.hidden)                  // iOS 16+ ukrywa domyślny biały zbiór
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedString.str("Cancel", language: language)) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(selectedTheme.textColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.str("Save", language: language)) {
                        saveNewHabit()
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .foregroundColor(selectedTheme.textColor)
                }
            }
            .onAppear {
                // 2. Form (UITableView) tło
                UITableView.appearance().backgroundColor = UIColor(selectedTheme.backgroundColor)
                // 3. NavBar tło i tekst
                let nav = UINavigationBarAppearance()
                nav.configureWithOpaqueBackground()
                nav.backgroundColor = UIColor(selectedTheme.backgroundColor)
                nav.titleTextAttributes = [.foregroundColor: UIColor(selectedTheme.textColor)]
                nav.largeTitleTextAttributes = [.foregroundColor: UIColor(selectedTheme.textColor)]
                UINavigationBar.appearance().standardAppearance = nav
                UINavigationBar.appearance().scrollEdgeAppearance = nav
            }
        }
    }

    private func saveNewHabit() {
        let newHabit = Habit(
            title: title,
            colorHex: colorToHex(selectedColor),
            goalDays: goalDays,
            userID: authService.currentUser?.id
        )
        appData.saveHabit(newHabit)
    }

    private func colorToHex(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = Int(r * 255)<<16 | Int(g * 255)<<8 | Int(b * 255)
        return String(format: "#%06x", rgb)
    }
}

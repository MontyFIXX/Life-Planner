import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("defaultTaskDuration") private var defaultTaskDuration = 60
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    @AppStorage("selectedLanguage") private var selectedLanguage = Language.english.rawValue
    
    private var language: Language {
        Language(rawValue: selectedLanguage) ?? .english
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedString.str("Appearance", language: language))
                    .foregroundColor(selectedTheme.textColor)) {
                    Picker(LocalizedString.str("Theme", language: language), selection: $selectedTheme) {
                        ForEach(Theme.allCases) { theme in
                            HStack {
                                Circle()
                                    .fill(theme.backgroundColor)
                                    .frame(width: 24, height: 24)
                                    .overlay(Circle().stroke(theme.textColor, lineWidth: 1))
                                Text(theme.name)
                                    .foregroundColor(theme.textColor)
                            }
                            .tag(theme)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .foregroundColor(selectedTheme.textColor)
                    .pickerStyle(MenuPickerStyle())
                }
                .listRowBackground(selectedTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                )
                
                Section(header: Text(LocalizedString.str("Language", language: language))
                    .foregroundColor(selectedTheme.textColor)) {
                    Picker(LocalizedString.str("Language", language: language), selection: $selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.displayName)
                                .foregroundColor(selectedTheme.textColor)
                                .tag(language.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .listRowBackground(selectedTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                )
                
                Section(header: Text(LocalizedString.str("Notifications", language: language))
                    .foregroundColor(selectedTheme.textColor)) {
                    Toggle(LocalizedString.str("Notifications", language: language), isOn: $notificationsEnabled)
                        .foregroundColor(selectedTheme.textColor)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                        )
                }
                .listRowBackground(selectedTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                )
                
                Section(header: Text(LocalizedString.str("Tasks", language: language))
                    .foregroundColor(selectedTheme.textColor)) {
                    Stepper(
                        "\(LocalizedString.str("Default duration", language: language)): \(defaultTaskDuration) \(LocalizedString.str("min", language: language))",
                        value: $defaultTaskDuration,
                        in: 15...240,
                        step: 15
                    )
                    .foregroundColor(selectedTheme.textColor)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .listRowBackground(selectedTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                )
                
                Section {
                    Button(LocalizedString.str("Reset Settings", language: language)) {
                        resetSettings()
                    }
                    .foregroundColor(selectedTheme == .theme2 ? Color(hex: "#762E3F") : .red)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .listRowBackground(selectedTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                )
                
                Section(footer: Text(LocalizedString.str("Version 1.0.0", language: language))
                    .foregroundColor(selectedTheme.textColor)) {
                    HStack {
                        Spacer()
                        Text(LocalizedString.str("Life Planner", language: language))
                            .font(.footnote)
                            .foregroundColor(selectedTheme.textColor)
                        Spacer()
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .listRowBackground(selectedTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                )
            }
            .applyTheme()
            .scrollContentBackground(.hidden)
            .background(selectedTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedString.str("Settings", language: language))
                        .font(.headline)
                        .foregroundColor(selectedTheme.textColor)
                }
            }
        }
        .applyTheme()
        .background(selectedTheme.backgroundColor.ignoresSafeArea())
    }
    
    private func resetSettings() {
        notificationsEnabled = true
        defaultTaskDuration = 60
        selectedTheme = .theme1
        selectedLanguage = Language.english.rawValue
    }
}

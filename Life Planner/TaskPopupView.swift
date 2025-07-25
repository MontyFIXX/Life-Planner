import SwiftUI

struct TaskPopupView: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var selectedColor: Color
    let date: Date
    let onSave: () -> Void
    let language: Language
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var authService: AuthService
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedString.str("Add Task", language: language))
                    .foregroundColor(selectedTheme.textColor)) {
                        
                        TextField(LocalizedString.str("Task Title", language: language), text: $title)
                            .foregroundColor(selectedTheme.textColor)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        DatePicker(LocalizedString.str("Date", language: language), selection: $selectedDate, displayedComponents: .date)
                            .foregroundColor(selectedTheme.textColor)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        DatePicker(LocalizedString.str("Start Time", language: language), selection: $startTime, displayedComponents: .hourAndMinute)
                            .foregroundColor(selectedTheme.textColor)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        DatePicker(LocalizedString.str("End Time", language: language), selection: $endTime, displayedComponents: .hourAndMinute)
                            .foregroundColor(selectedTheme.textColor)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .listRowBackground(selectedTheme.backgroundColor)
                
                Section(header: Text(LocalizedString.str("Color", language: language))
                    .foregroundColor(selectedTheme.textColor)) {
                        ColorPicker(LocalizedString.str("Color", language: language), selection: $selectedColor)
                            .foregroundColor(selectedTheme.textColor)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .listRowBackground(selectedTheme.backgroundColor)
            }
            .applyTheme()
            .scrollContentBackground(.hidden)
            .background(selectedTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(LocalizedString.str("Cancel", language: language)) {
                    isPresented = false
                },
                trailing: Button(LocalizedString.str("Save", language: language)) {
                    onSave()
                    isPresented = false
                }
                    .disabled(title.isEmpty)
                    .foregroundColor(selectedTheme.textColor)
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedString.str("Add Task", language: language))
                        .font(.headline)
                        .foregroundColor(selectedTheme.textColor)
                }
            }
            .onAppear {
                selectedDate = date
            }
        }
        .applyTheme()
        .background(selectedTheme.backgroundColor.ignoresSafeArea())
    }
}

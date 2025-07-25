import SwiftUI

struct ThemeModifier: ViewModifier {
    @AppStorage("selectedTheme") var selectedTheme: Theme = .theme1
    
    func body(content: Content) -> some View {
        content
            .background(selectedTheme.backgroundColor.ignoresSafeArea())
            .foregroundColor(selectedTheme.textColor)
            .tint(selectedTheme.textColor)
            .onAppear {
                // Aktualizacja dla UITableView
                UITableView.appearance().backgroundColor = UIColor(selectedTheme.backgroundColor)
                UITableView.appearance().sectionHeaderTopPadding = 0
                UITableViewCell.appearance().backgroundColor = UIColor(selectedTheme.backgroundColor)
                
                // Aktualizacja dla UIScrollView
                UIScrollView.appearance().backgroundColor = UIColor(selectedTheme.backgroundColor)
            }
    }
}

extension View {
    func applyTheme() -> some View {
        self.modifier(ThemeModifier())
    }
}

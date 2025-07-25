import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case theme1
    case theme2
    case theme3
    
    var id: String { self.rawValue }
    
    var backgroundColor: Color {
        switch self {
        case .theme1: return Color(hex: "#E5D7C4")
        case .theme2: return Color(hex: "#D8CCC5")
        case .theme3: return Color(hex: "#DFDAC2")
        }
    }
    
    var textColor: Color {
        switch self {
        case .theme1: return Color(hex: "#343434")
        case .theme2: return Color(hex: "#762E3F")
        case .theme3: return Color(hex: "#354024")
        }
    }
    
    // Dodajemy nowy kolor dla tekstu wejściowego
    var inputTextColor: Color {
        Color(hex: "#000000") // Czarny kolor
    }
    
    var name: String {
        switch self {
        case .theme1: return "Classic Beige"
        case .theme2: return "Soft Rose"
        case .theme3: return "Earthy Green"
        }
    }
}

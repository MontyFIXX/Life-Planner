import SwiftUI

struct BaseViewModifier: ViewModifier {
    @AppStorage("backgroundColor") private var backgroundColorHex: String = "#FFFFFF"
    
    func body(content: Content) -> some View {
        content
            .background(
                Color(hex: backgroundColorHex)
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func withBaseBackground() -> some View {
        self.modifier(BaseViewModifier())
    }
}

import SwiftUI

struct SideMenuView: View {
    @Binding var showingMenu: Bool
    let accentColor: Color
    let textColor: Color
    @EnvironmentObject var appData: AppData
    
    @AppStorage("backgroundColor") private var backgroundColorHex: String = "#FFFFFF"
    
    private var backgroundColor: Color {
        Color(hex: backgroundColorHex)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            showingMenu = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .padding()
                            .foregroundColor(textColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Life Planner")
                        .font(.title.bold())
                        .padding(.bottom, 20)
                        .foregroundColor(accentColor)
                    
                    Button {
                        withAnimation {
                            showingMenu = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "house")
                                .frame(width: 24)
                                .foregroundColor(accentColor)
                            Text("Strona główna")
                                .foregroundColor(textColor)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    
                    NavigationLink {
                        Text("Śledzenie nawyków")
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar")
                                .frame(width: 24)
                                .foregroundColor(accentColor)
                            Text("Śledzenie nawyków")
                                .foregroundColor(textColor)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    
                    NavigationLink {
                        Text("Grupy")
                    } label: {
                        HStack {
                            Image(systemName: "person.2")
                                .frame(width: 24)
                                .foregroundColor(accentColor)
                            Text("Grupy")
                                .foregroundColor(textColor)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    
                    NavigationLink {
                        SettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "gear")
                                .frame(width: 24)
                                .foregroundColor(accentColor)
                            Text("Ustawienia")
                                .foregroundColor(textColor)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    
                    NavigationLink {
                        Text("Logowanie")
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .frame(width: 24)
                                .foregroundColor(accentColor)
                            Text("Logowanie")
                                .foregroundColor(textColor)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.7)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 5, y: 0)
    }
}

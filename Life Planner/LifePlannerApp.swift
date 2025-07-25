import SwiftUI
import Firebase
import GoogleSignIn

@main
struct LifePlannerApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject var authService = AuthService.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authService)
        }
    }
}

// Poprawiona klasa AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

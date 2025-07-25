import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showingLogin = false
    @State private var showingVerificationAlert = false
    
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    @AppStorage("selectedLanguage") private var selectedLanguage = Language.english.rawValue
    
    private var language: Language {
        Language(rawValue: selectedLanguage) ?? .english
    }
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                loggedInView
            } else {
                loggedOutView
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
                .applyTheme()
        }
        .alert(isPresented: $showingVerificationAlert) {
            Alert(
                title: Text(LocalizedString.str("Email Verification", language: language)),
                message: Text(LocalizedString.str("We've sent a verification email to your address. Please check your inbox and verify your email.", language: language)),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var loggedInView: some View {
        VStack(spacing: 20) {
            if let avatarURL = authService.currentUser?.avatarURL, !avatarURL.isEmpty {
                AsyncImage(url: URL(string: avatarURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(selectedTheme.textColor, lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(selectedTheme.textColor)
            }
            
            Text(authService.currentUser?.nickname ?? "")
                .font(.title)
                .foregroundColor(selectedTheme.textColor)
            
            Text(authService.currentUser?.email ?? "")
                .font(.subheadline)
                .foregroundColor(selectedTheme.textColor)
            
            if !authService.isEmailVerified {
                VStack {
                    Text(LocalizedString.str("Email not verified", language: language))
                        .foregroundColor(.red)
                    
                    Button(LocalizedString.str("Resend Verification", language: language)) {
                        authService.sendEmailVerification { result in
                            showingVerificationAlert = true
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            Spacer()
            
            Button(action: {
                try? authService.logout()
            }) {
                Text(LocalizedString.str("Logout", language: language))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private var loggedOutView: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(selectedTheme.textColor)
            
            Text(LocalizedString.str("You are not logged in", language: language))
                .font(.title2)
                .foregroundColor(selectedTheme.textColor)
            
            Text(LocalizedString.str("Log in to access all features", language: language))
                .font(.subheadline)
                .foregroundColor(selectedTheme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingLogin = true
            }) {
                Text(LocalizedString.str("Login", language: language))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedTheme.textColor)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            NavigationLink(destination: RegisterView()) {
                Text(LocalizedString.str("Create Account", language: language))
                    .foregroundColor(selectedTheme.textColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedTheme.textColor, lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

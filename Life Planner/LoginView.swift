import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .theme1
    @AppStorage("selectedLanguage") private var selectedLanguage = Language.english.rawValue
    
    private var language: Language {
        Language(rawValue: selectedLanguage) ?? .english
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(selectedTheme.textColor)
                        
                        Text(LocalizedString.str("Welcome back", language: language))
                            .font(.title)
                            .padding(.top, 10)
                            .foregroundColor(selectedTheme.textColor)
                    }
                    
                    VStack(spacing: 20) {
                                            // Pole Email z bardziej widocznym placeholderem
                                            ZStack(alignment: .leading) {
                                                if email.isEmpty {
                                                    Text(LocalizedString.str("Email", language: language))
                                                        .foregroundColor(.black.opacity(0.6)) // Ciemniejszy placeholder
                                                        .padding(.horizontal)
                                                }
                                                TextField("", text: $email)
                                                    .autocapitalization(.none)
                                                    .keyboardType(.emailAddress)
                                                    .foregroundColor(selectedTheme.textColor)
                                            }
                                            .padding()
                                            .background(selectedTheme.backgroundColor.opacity(0.7))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                                            )
                                            
                                            // Pole Password z bardziej widocznym placeholderem
                                            ZStack(alignment: .leading) {
                                                if password.isEmpty {
                                                    Text(LocalizedString.str("Password", language: language))
                                                        .foregroundColor(.black.opacity(0.6)) // Ciemniejszy placeholder
                                                        .padding(.horizontal)
                                                }
                                                SecureField("", text: $password)
                                                    .foregroundColor(selectedTheme.textColor)
                                            }
                                            .padding()
                                            .background(selectedTheme.backgroundColor.opacity(0.7))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                                            )
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: login) {
                            Text(LocalizedString.str("Login", language: language))
                                .foregroundColor(selectedTheme.backgroundColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedTheme.textColor)
                                .cornerRadius(10)
                        }
                    }
                    
                    VStack(spacing: 15) {
                        Text(LocalizedString.str("Or continue with", language: language))
                            .foregroundColor(selectedTheme.textColor.opacity(0.7))
                        
                        Button(action: signInWithGoogle) {
                            HStack {
                                Image("google-logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                Text("Google")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.91, green: 0.33, blue: 0.25))
                            .cornerRadius(10)
                        }
                    }
                    
                    HStack {
                        Text(LocalizedString.str("Don't have an account?", language: language))
                            .foregroundColor(selectedTheme.textColor)
                        
                        NavigationLink(destination: RegisterView()) {
                            Text(LocalizedString.str("Sign Up", language: language))
                                .foregroundColor(selectedTheme.textColor)
                                .bold()
                        }
                    }
                }
                .padding()
                .background(selectedTheme.backgroundColor)
            }
            .background(selectedTheme.backgroundColor)
            .applyTheme()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedString.str("Close", language: language)) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(selectedTheme.textColor)
                }
            }
        }
        .applyTheme()
    }
    
    private func login() {
        authService.login(email: email, password: password) { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func signInWithGoogle() {
        authService.signInWithGoogle { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

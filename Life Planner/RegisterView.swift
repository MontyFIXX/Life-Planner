import SwiftUI
import GoogleSignIn

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var nickname = ""
    @State private var avatar: UIImage?
    @State private var showingImagePicker = false
    @State private var errorMessage = ""
    @State private var showingVerificationAlert = false
    
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
                        // Avatar selection
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let avatar = avatar {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(selectedTheme.textColor)
                            }
                        }
                        
                        Text(LocalizedString.str("Create Account", language: language))
                            .font(.title)
                            .padding(.top, 10)
                            .foregroundColor(selectedTheme.textColor)
                    }
                    
                    VStack(spacing: 20) {
                                            // Pole Nickname z bardziej widocznym placeholderem
                                            ZStack(alignment: .leading) {
                                                if nickname.isEmpty {
                                                    Text(LocalizedString.str("Nickname", language: language))
                                                        .foregroundColor(.black.opacity(0.6)) // Ciemniejszy placeholder
                                                        .padding(.horizontal)
                                                }
                                                TextField("", text: $nickname)
                                                    .foregroundColor(selectedTheme.textColor)
                                            }
                                            .padding()
                                            .background(selectedTheme.backgroundColor.opacity(0.7))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                                            )
                                            
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
                                            
                                            // Pole Confirm Password z bardziej widocznym placeholderem
                                            ZStack(alignment: .leading) {
                                                if confirmPassword.isEmpty {
                                                    Text(LocalizedString.str("Confirm Password", language: language))
                                                        .foregroundColor(.black.opacity(0.6)) // Ciemniejszy placeholder
                                                        .padding(.horizontal)
                                                }
                                                SecureField("", text: $confirmPassword)
                                                    .foregroundColor(selectedTheme.textColor)
                                            }
                                            .padding()
                                            .background(selectedTheme.backgroundColor.opacity(0.7))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedTheme.textColor.opacity(0.3), lineWidth: 1)
                                            )
                        // Error message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        // Register button
                        Button(action: register) {
                            Text(LocalizedString.str("Register", language: language))
                                .foregroundColor(selectedTheme.backgroundColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedTheme.textColor)
                                .cornerRadius(10)
                        }
                        
                        // Dodany separator i przycisk Google
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
                    }
                }
                .padding()
                .background(selectedTheme.backgroundColor)
            }
            .background(selectedTheme.backgroundColor)
            .applyTheme()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $avatar)
            }
            .alert(isPresented: $showingVerificationAlert) {
                Alert(
                    title: Text(LocalizedString.str("Email Verification", language: language)),
                    message: Text(LocalizedString.str("We've sent a verification email to your address. Please check your inbox and verify your email.", language: language)),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .applyTheme()
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func register() {
        guard password == confirmPassword else {
            errorMessage = LocalizedString.str("Passwords do not match", language: language)
            return
        }
        
        authService.register(
            email: email,
            password: password,
            nickname: nickname
        ) { result in
            switch result {
            case .success:
                showingVerificationAlert = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // Dodana funkcja logowania przez Google
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

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignIn
import FirebaseCore

struct AppUser: Equatable {
    let id: String
    var nickname: String
    var email: String
    var avatarURL: String?
    
    static func == (lhs: AppUser, rhs: AppUser) -> Bool {
        lhs.id == rhs.id
    }
}

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: AppUser?
    @Published var isSignedIn = false
    @Published var isEmailVerified = false
    
    private init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            
            if let user = user {
                self.isSignedIn = true
                self.fetchUserData(uid: user.uid)
                self.checkEmailVerification()
            } else {
                self.isSignedIn = false
                self.currentUser = nil
                self.isEmailVerified = false
                
                // Wyczyść dane aplikacji przy wylogowaniu
                AppData.shared.clearData()
            }
        }
    }
    
    private func fetchUserData(uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  let nickname = data["nickname"] as? String,
                  let email = data["email"] as? String else {
                return
            }
            
            self.currentUser = AppUser(
                id: uid,
                nickname: nickname,
                email: email,
                avatarURL: data["avatarURL"] as? String
            )
        }
    }
    
    private func checkEmailVerification() {
        if let user = Auth.auth().currentUser {
            user.reload { [weak self] error in
                if error == nil {
                    self?.isEmailVerified = user.isEmailVerified
                }
            }
        }
    }
    
    func sendEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            self.fetchUserData(uid: user.uid)
            self.checkEmailVerification()
            completion(.success(AppUser(id: user.uid, nickname: "", email: user.email ?? "")))
        }
    }
    
    func register(email: String, password: String, nickname: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User creation failed"])))
                return
            }
            
            // Send verification email
            user.sendEmailVerification { error in
                if let error = error {
                    print("Error sending verification email: \(error)")
                }
            }
            
            let userData = [
                "nickname": nickname,
                "email": email
            ]
            
            Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    self?.currentUser = AppUser(id: user.uid, nickname: nickname, email: email)
                    self?.checkEmailVerification()
                    completion(.success(AppUser(id: user.uid, nickname: nickname, email: email)))
                }
            }
        }
    }
    
    func logout() throws {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isSignedIn = false
            isEmailVerified = false
            
            // Wyczyść dane aplikacji
            AppData.shared.clearData()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Google Sign In
    func signInWithGoogle(completion: @escaping (Result<AppUser, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID missing"])))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No root view controller"])))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { [weak self] user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = user,
                  let idToken = user.authentication.idToken else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Google sign in failed"])))
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.authentication.accessToken
            )
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Google sign in failed"])))
                    return
                }
                
                let userData = [
                    "nickname": firebaseUser.displayName ?? "User",
                    "email": firebaseUser.email ?? "",
                    "avatarURL": firebaseUser.photoURL?.absoluteString ?? ""
                ]
                
                Firestore.firestore().collection("users").document(firebaseUser.uid).setData(userData, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self?.currentUser = AppUser(
                            id: firebaseUser.uid,
                            nickname: firebaseUser.displayName ?? "User",
                            email: firebaseUser.email ?? "",
                            avatarURL: firebaseUser.photoURL?.absoluteString
                        )
                        self?.isSignedIn = true
                        self?.isEmailVerified = true
                        completion(.success(AppUser(
                            id: firebaseUser.uid,
                            nickname: firebaseUser.displayName ?? "User",
                            email: firebaseUser.email ?? "",
                            avatarURL: firebaseUser.photoURL?.absoluteString
                        )))
                    }
                }
            }
        }
    }
}

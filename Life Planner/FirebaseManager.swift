import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager: NSObject {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    
    override init() {
        // Sprawdź czy FirebaseApp jest już skonfigurowany
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
        super.init()
    }
}

// MARK: - Task and Habit Management
extension FirebaseManager {
    // MARK: - Task Methods
    func saveTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(NSError(domain: "User not logged in", code: 401, userInfo: nil))
            return
        }
        
        var taskData = task.dictionary
        taskData["userID"] = userId
        
        firestore.collection("tasks").document(task.id).setData(taskData, completion: completion)
    }
    
    func fetchTasks(completion: @escaping ([Task]?, Error?) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(nil, NSError(domain: "User not logged in", code: 401, userInfo: nil))
            return
        }
        
        firestore.collection("tasks")
            .whereField("userID", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var tasks: [Task] = []
                for document in snapshot?.documents ?? [] {
                    var data = document.data()
                    data["id"] = document.documentID
                    if let task = Task(dictionary: data) {
                        tasks.append(task)
                    }
                }
                completion(tasks, nil)
            }
    }
    
    func deleteTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        firestore.collection("tasks").document(task.id).delete(completion: completion)
    }
    
    // MARK: - Habit Methods
    func saveHabit(_ habit: Habit, completion: @escaping (Error?) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(NSError(domain: "User not logged in", code: 401, userInfo: nil))
            return
        }
        
        var habitData = habit.dictionary
        habitData["userID"] = userId
        
        firestore.collection("habits").document(habit.id).setData(habitData, completion: completion)
    }
    
    func fetchHabits(completion: @escaping ([Habit]?, Error?) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(nil, NSError(domain: "User not logged in", code: 401, userInfo: nil))
            return
        }
        
        firestore.collection("habits")
            .whereField("userID", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var habits: [Habit] = []
                for document in snapshot?.documents ?? [] {
                    var data = document.data()
                    data["id"] = document.documentID
                    if let habit = Habit(dictionary: data) {
                        habits.append(habit)
                    }
                }
                completion(habits, nil)
            }
    }
    
    func deleteHabit(_ habit: Habit, completion: @escaping (Error?) -> Void) {
        firestore.collection("habits").document(habit.id).delete(completion: completion)
    }
    
    // MARK: - User Authentication
    func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func createUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func currentUserId() -> String? {
        return auth.currentUser?.uid
    }
}

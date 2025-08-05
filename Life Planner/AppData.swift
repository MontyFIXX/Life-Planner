import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class AppData: ObservableObject {
    static let shared = AppData()
    
    // MARK: - Published Properties
    @Published var tasks: [Task] = []
    @Published var habits: [Habit] = []
    @Published var groups: [Group] = []
    @Published var selectedDate = Date()
    
    // MARK: - Firestore & Listeners
    private let db = Firestore.firestore()
    private var tasksListener: ListenerRegistration?
    private var habitsListener: ListenerRegistration?
    private var groupsListener: ListenerRegistration?
    
    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAuthListener()
        setupLocalPersistence()
    }
    
    // MARK: - Authentication Handling
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            
            // Usuń wszystkie snapshot listnery i wyczyść dane
            self.removeListeners()
            self.clearData()
            
            // Jeśli zalogowany — podłącz nowe listenery
            if let userId = user?.uid {
                self.setupListeners(userId: userId)
            }
        }
    }
    
    private func setupListeners(userId: String) {
        // Tasks listener
        tasksListener = db.collection("tasks")
            .whereField("userID", isEqualTo: userId)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching tasks: \(error.localizedDescription)")
                    return
                }
                
                self.tasks = snapshot?.documents.compactMap { doc in
                    var data = doc.data()
                    data["id"] = doc.documentID
                    return Task(dictionary: data)
                } ?? []
                
                self.saveTasksToLocalCache()
            }
        
        // Habits listener
        habitsListener = db.collection("habits")
            .whereField("userID", isEqualTo: userId)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching habits: \(error.localizedDescription)")
                    return
                }
                
                self.habits = snapshot?.documents.compactMap { doc in
                    var data = doc.data()
                    data["id"] = doc.documentID
                    return Habit(dictionary: data)
                } ?? []
                
                self.saveHabitsToLocalCache()
            }
        
        groupsListener = db.collection("groups")
            .whereField("members", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching groups: \(error.localizedDescription)")
                    return
                }

                self.groups = snapshot?.documents.compactMap { document in
                    do {
                        return try document.data(as: Group.self)
                    } catch {
                        print("Decoding Group failed:", error)
                        return nil
                    }
                } ?? []

                self.saveGroupsToLocalCache()
            }

    }
    
    // MARK: - Public Methods
    
    func saveTask(_ task: Task) {
        FirebaseManager.shared.saveTask(task) { [weak self] error in
            if let error = error {
                print("Error saving task: \(error.localizedDescription)")
                self?.saveTasksToLocalCache()
            }
        }
    }
    
    func saveHabit(_ habit: Habit) {
        FirebaseManager.shared.saveHabit(habit) { [weak self] error in
            if let error = error {
                print("Error saving habit: \(error.localizedDescription)")
                self?.saveHabitsToLocalCache()
            }
        }
    }
    
    /// Ładuje dane z lokalnej pamięci, a potem fetchuje z Firestore
    func loadData() {
        loadLocalCache()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        FirebaseManager.shared.fetchTasks { [weak self] tasks, error in
            if let tasks = tasks {
                self?.tasks = tasks
                self?.saveTasksToLocalCache()
            } else if let error = error {
                print("Error loading tasks: \(error.localizedDescription)")
            }
        }
        
        FirebaseManager.shared.fetchHabits { [weak self] habits, error in
            if let habits = habits {
                self?.habits = habits
                self?.saveHabitsToLocalCache()
            } else if let error = error {
                print("Error loading habits: \(error.localizedDescription)")
            }
        }
    }
    
    func clearData() {
        tasks = []
        habits = []
        groups = []
        removeListeners()
        clearLocalCache()
    }
    
    // MARK: - Listener Cleanup
    
    private func removeListeners() {
        tasksListener?.remove()
        habitsListener?.remove()
        groupsListener?.remove()
        
        tasksListener = nil
        habitsListener = nil
        groupsListener = nil
    }
    
    // MARK: - Local Cache Management
    
    private func setupLocalPersistence() {
        loadLocalCache()
    }
    
    private func saveTasksToLocalCache() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: "localTasksCache")
        } catch {
            print("Error saving tasks to local cache: \(error)")
        }
    }
    
    private func saveHabitsToLocalCache() {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: "localHabitsCache")
        } catch {
            print("Error saving habits to local cache: \(error)")
        }
    }
    
    private func saveGroupsToLocalCache() {
        do {
            let data = try JSONEncoder().encode(groups)
            UserDefaults.standard.set(data, forKey: "localGroupsCache")
        } catch {
            print("Error saving groups to local cache: \(error)")
        }
    }
    
    private func loadLocalCache() {
        // Tasks
        if let data = UserDefaults.standard.data(forKey: "localTasksCache"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
        
        // Habits
        if let data = UserDefaults.standard.data(forKey: "localHabitsCache"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
        
        // Groups
        if let data = UserDefaults.standard.data(forKey: "localGroupsCache"),
           let decoded = try? JSONDecoder().decode([Group].self, from: data) {
            groups = decoded
        }
    }
    
    private func clearLocalCache() {
        UserDefaults.standard.removeObject(forKey: "localTasksCache")
        UserDefaults.standard.removeObject(forKey: "localHabitsCache")
        UserDefaults.standard.removeObject(forKey: "localGroupsCache")
    }
}

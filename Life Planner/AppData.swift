import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class AppData: ObservableObject {
    static let shared = AppData()
    
    @Published var tasks: [Task] = []
    @Published var habits: [Habit] = []
    @Published var selectedDate = Date()
    
    private var db = Firestore.firestore()
    private var tasksListener: ListenerRegistration?
    private var habitsListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAuthListener()
        setupLocalPersistence()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            
            self.removeListeners()
            self.clearData()
            
            if let userId = user?.uid {
                self.setupListeners(userId: userId)
            }
        }
    }
    
    private func setupListeners(userId: String) {
        // Tasks listener
        tasksListener = db.collection("tasks")
            .whereField("userID", isEqualTo: userId)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching tasks: \(error.localizedDescription)")
                    return
                }
                
                self.tasks = querySnapshot?.documents.compactMap { document in
                    var data = document.data()
                    data["id"] = document.documentID
                    return Task(dictionary: data)
                } ?? []
                
                // Save to local cache
                self.saveTasksToLocalCache()
            }
        
        // Habits listener
        habitsListener = db.collection("habits")
            .whereField("userID", isEqualTo: userId)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching habits: \(error.localizedDescription)")
                    return
                }
                
                self.habits = querySnapshot?.documents.compactMap { document in
                    var data = document.data()
                    data["id"] = document.documentID
                    return Habit(dictionary: data)
                } ?? []
                
                // Save to local cache
                self.saveHabitsToLocalCache()
            }
    }
    
    // MARK: - Public Methods
    
    func saveTask(_ task: Task) {
        FirebaseManager.shared.saveTask(task) { [weak self] error in
            if let error = error {
                print("Error saving task: \(error.localizedDescription)")
                // Fallback to local storage if Firebase fails
                self?.saveTasksToLocalCache()
            }
        }
    }
    
    func saveHabit(_ habit: Habit) {
        FirebaseManager.shared.saveHabit(habit) { [weak self] error in
            if let error = error {
                print("Error saving habit: \(error.localizedDescription)")
                // Fallback to local storage if Firebase fails
                self?.saveHabitsToLocalCache()
            }
        }
    }
    
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
        removeListeners()
        clearLocalCache()
    }
    
    // MARK: - Private Methods
    
    private func removeListeners() {
        tasksListener?.remove()
        habitsListener?.remove()
        tasksListener = nil
        habitsListener = nil
    }
    
    // MARK: - Local Cache Management
    
    private func setupLocalPersistence() {
        // Load local cache on init
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
    
    private func loadLocalCache() {
        // Load tasks
        if let data = UserDefaults.standard.data(forKey: "localTasksCache"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
        }
        
        // Load habits
        if let data = UserDefaults.standard.data(forKey: "localHabitsCache"),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decodedHabits
        }
    }
    
    private func clearLocalCache() {
        UserDefaults.standard.removeObject(forKey: "localTasksCache")
        UserDefaults.standard.removeObject(forKey: "localHabitsCache")
    }
}

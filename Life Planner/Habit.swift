import Foundation

struct Habit: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var colorHex: String
    var goalDays: Int
    var creationDate: Date
    var completionDates: [Date]
    var userID: String?
    
    // Dodaj jawny inicjalizator
    init(
        id: String = UUID().uuidString,
        title: String,
        colorHex: String,
        goalDays: Int,
        creationDate: Date = Date(),
        completionDates: [Date] = [],
        userID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.goalDays = goalDays
        self.creationDate = creationDate
        self.completionDates = completionDates
        self.userID = userID
    }
    
    
    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return completionDates.contains { date in
            Calendar.current.isDate(date, inSameDayAs: today)
        }
    }
    
    mutating func toggleCompletion(for date: Date = Date()) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        if let index = completionDates.firstIndex(where: {
            Calendar.current.isDate($0, inSameDayAs: normalizedDate)
        }) {
            completionDates.remove(at: index)
        } else {
            completionDates.append(normalizedDate)
        }
    }
    
    var dictionary: [String: Any] {
        [
            "id": id,
            "title": title,
            "colorHex": colorHex,
            "goalDays": goalDays,
            "creationDate": creationDate,
            "completionDates": completionDates,
            "userID": userID as Any
        ]
    }

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String,
              let colorHex = dictionary["colorHex"] as? String,
              let goalDays = dictionary["goalDays"] as? Int,
              let creationDate = dictionary["creationDate"] as? Date,
              let completionDates = dictionary["completionDates"] as? [Date] else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.goalDays = goalDays
        self.creationDate = creationDate
        self.completionDates = completionDates
        self.userID = dictionary["userID"] as? String
    }
}

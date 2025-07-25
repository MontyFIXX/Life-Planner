import Foundation

struct Task: Identifiable, Codable, Equatable {
    var id: String  // Zmiana na String dla kompatybilności z Firestore
    var title: String
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var colorHex: String
    var isCompleted: Bool
    var userID: String?  // Dodane powiązanie z użytkownikiem

    init(id: String = UUID().uuidString, title: String, date: Date,
         startTime: Date? = nil, endTime: Date? = nil,
         colorHex: String, isCompleted: Bool = false, userID: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.colorHex = colorHex
        self.isCompleted = isCompleted
        self.userID = userID
    }

    // Słownik dla Firestore
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "date": date,
            "colorHex": colorHex,
            "isCompleted": isCompleted
        ]
        
        if let startTime = startTime {
            dict["startTime"] = startTime
        }
        if let endTime = endTime {
            dict["endTime"] = endTime
        }
        if let userID = userID {
            dict["userID"] = userID
        }
        
        return dict
    }

    // Inicjalizacja z Firestore
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String,
              let date = dictionary["date"] as? Date,
              let colorHex = dictionary["colorHex"] as? String,
              let isCompleted = dictionary["isCompleted"] as? Bool else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.date = date
        self.startTime = dictionary["startTime"] as? Date
        self.endTime = dictionary["endTime"] as? Date
        self.colorHex = colorHex
        self.isCompleted = isCompleted
        self.userID = dictionary["userID"] as? String
    }
}

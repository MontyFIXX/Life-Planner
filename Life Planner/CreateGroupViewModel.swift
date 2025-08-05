import Combine
import Foundation

class CreateGroupViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var selectedFriends: [String] = []
    
    // korzystamy z singletona, nie z prywatnego inicjalizatora
    private let service: GroupService = .shared
    private let ownerID: String

    init(ownerID: String) {
        self.ownerID = ownerID
    }

    func create(completion: @escaping (Error?) -> Void) {
        let newGroup = Group(
            id: UUID().uuidString,
            name: name,
            ownerID: ownerID,
            memberIDs: [ownerID] + selectedFriends,
            joinCode: ""    // zostanie wygenerowany w createGroup
        )
        
        service.createGroup(newGroup) { error in
            completion(error)
        }
    }
}

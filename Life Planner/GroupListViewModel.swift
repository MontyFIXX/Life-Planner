import Foundation
import Combine

class GroupListViewModel: ObservableObject {
    @Published var groups: [Group] = []
    
    // korzystamy z singletona zamiast prywatnego inicjalizatora
    private let service: GroupService = .shared
    private var cancellables = Set<AnyCancellable>()
    
    let userID: String

    init(userID: String) {
        self.userID = userID
        loadGroups()
    }

    func loadGroups() {
        service.fetchGroups(for: userID)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] fetched in
                self?.groups = fetched
            }
            .store(in: &cancellables)
    }
}

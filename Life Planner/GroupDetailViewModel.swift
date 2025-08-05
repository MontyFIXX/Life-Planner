import Combine
import Foundation

class GroupDetailViewModel: ObservableObject {
    @Published var group: Group
    @Published var members: [User] = []
    @Published var freeSlots: [DateInterval] = []

    private var cancellables = Set<AnyCancellable>()
    // korzystamy z singletona zamiast prywatnego init()
    private let service: GroupService = .shared

    init(group: Group) {
        self.group = group
        loadMembers()
        computeFreeSlots()
    }

    func loadMembers() {
        // tutaj użyj:
        // service.fetchGroups(...) lub innej metody service, np. fetchGroup(byJoinCode:)
        // przykładowo:
        // service.fetchGroup(byJoinCode: ...) { group, error in … }
    }

    func computeFreeSlots() {
        // logika obliczania wolnych slotów
    }
}

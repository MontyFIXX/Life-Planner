import FirebaseFirestoreSwift

struct Group: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var memberIDs: [String]      // maks. 3 użytkowników
}

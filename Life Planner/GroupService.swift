import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class GroupService {
    static let shared = GroupService()
    private let db = Firestore.firestore()
    private let groupsCol = "groups"

    private init() {}

    // MARK: - Create or Update Group

    /// Creates a new group or updates an existing one.
    /// If `group.joinCode` is empty, a new 6-character alphanumeric code is generated.
    func createGroup(_ group: Group, completion: @escaping (Error?) -> Void) {
        // Ensure we have a document ID
        guard let id = group.id else {
            let error = NSError(
                domain: "GroupService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Group ID is nil"]
            )
            completion(error)
            return
        }

        // Prepare a copy to mutate joinCode if needed
        var toSave = group
        if toSave.joinCode.isEmpty {
            let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            toSave.joinCode = String((0..<6).compactMap { _ in alphabet.randomElement() })
        }

        do {
            try db
                .collection(groupsCol)
                .document(id)
                .setData(from: toSave, merge: true, completion: completion)
        } catch {
            completion(error)
        }
    }

    // MARK: - Fetch Groups for Current User

    /// Publishes all groups where `memberIDs` array contains `userID`.
    func fetchGroups(for userID: String) -> AnyPublisher<[Group], Error> {
        Future { promise in
            self.db
                .collection(self.groupsCol)
                .whereField("memberIDs", arrayContains: userID)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    let groups = snapshot?.documents.compactMap {
                        try? $0.data(as: Group.self)
                    } ?? []
                    promise(.success(groups))
                }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Fetch Single Group by Join Code

    /// Fetches the first group matching the given join code.
    func fetchGroup(byJoinCode code: String, completion: @escaping (Group?, Error?) -> Void) {
        db.collection(groupsCol)
            .whereField("joinCode", isEqualTo: code)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                let group = snapshot?
                    .documents
                    .compactMap { try? $0.data(as: Group.self) }
                    .first
                completion(group, nil)
            }
    }

    // MARK: - Add Member to Group

    func addMember(_ userID: String, to group: Group, completion: @escaping (Error?) -> Void) {
            var updated = group

            guard let existingID = updated.id else {
                let error = NSError(
                    domain: "GroupService",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid group data"]
                )
                completion(error)
                return
            }

            guard updated.memberIDs.count < 5 else {
                let error = NSError(
                    domain: "GroupService",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Group is full"]
                )
                completion(error)
                return
            }

            updated.memberIDs.append(userID)
            createGroup(updated, completion: completion)
        }
    } // ← Upewnij się,

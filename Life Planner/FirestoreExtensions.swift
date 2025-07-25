import FirebaseFirestore
import FirebaseFirestoreSwift

extension DocumentReference {
    func setData<T: Encodable>(from value: T) throws {
        try setData(from: value, encoder: Firestore.Encoder())
    }
}

extension QueryDocumentSnapshot {
    func data<T: Decodable>(as type: T.Type) throws -> T {
        try data(as: type, decoder: Firestore.Decoder())
    }
}

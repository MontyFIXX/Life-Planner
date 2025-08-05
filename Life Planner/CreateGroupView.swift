import SwiftUI
import FirebaseAuth       // dla Auth

struct CreateGroupView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.presentationMode) var presentation
    @State private var name = ""
    
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nazwa grupy")) {
                    TextField("np. Planer Biegowy", text: $name)
                }
            }
            .navigationTitle("Nowa grupa")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        guard let userId = Auth.auth().currentUser?.uid else { return }
                        let newGroup = Group(
                            id: UUID().uuidString,
                            name: name,
                            ownerID: userId,
                            memberIDs: [userId],
                            joinCode: ""    // zostanie wygenerowany w createGroup
                        )
                        
                        // Wywołanie przez singleton
                        GroupService.shared.createGroup(newGroup) { error in
                            if let error = error {
                                print("Błąd tworzenia:", error)
                            }
                            isPresented = false
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

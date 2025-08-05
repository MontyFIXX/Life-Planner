import SwiftUI
import FirebaseAuth

struct JoinGroupView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.presentationMode) var presentation
    @State private var code = ""
    @State private var message: String?

    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kod zaproszenia")) {
                    TextField("Wpisz kod", text: $code)
                        .autocapitalization(.allCharacters)
                }
                if let msg = message {
                    Section {
                        Text(msg)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Dołącz do grupy")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dołącz") {
                        // używamy singletona zamiast prywatnego init()
                        GroupService.shared.fetchGroup(byJoinCode: code) { group, error in
                            if let error = error {
                                message = error.localizedDescription
                            } else if let grp = group,
                                      let uid = Auth.auth().currentUser?.uid {
                                GroupService.shared.addMember(uid, to: grp) { err2 in
                                    if let err2 = err2 {
                                        message = err2.localizedDescription
                                    } else {
                                        isPresented = false
                                    }
                                }
                            } else {
                                message = "Nie znaleziono grupy o tym kodzie"
                            }
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

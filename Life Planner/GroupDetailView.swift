import SwiftUI
import FirebaseAuth       // dla Auth

struct GroupDetailView: View {
    let group: Group

    var body: some View {
        VStack(spacing: 20) {
            Text(group.name).font(.largeTitle).bold()
            if let code = group.joinCode {
                HStack {
                    Text("Kod zaproszenia:")
                    Spacer()
                    Text(code).font(.system(.body, design: .monospaced))
                }
                .padding(.horizontal)
            }
            Divider()
            Text("Członkowie:")
                .font(.headline)
            ForEach(group.memberIDs, id: \.self) { id in
                Text(id)   // możesz tu pobrać nicki z UserService
            }
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

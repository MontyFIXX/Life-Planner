import SwiftUI

struct GroupsListView: View {
    @EnvironmentObject var appData: AppData
    @State private var showingCreate = false
    @State private var showingJoin = false

    var body: some View {
        List {
            if appData.groups.isEmpty {
                Text("Brak grup")
                    .foregroundColor(.gray)
            } else {
                ForEach(appData.groups) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        Text(group.name)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Grupy")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Dołącz") { showingJoin = true }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreate = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreate) {
            CreateGroupView(isPresented: $showingCreate)
                .environmentObject(appData)
        }
        .sheet(isPresented: $showingJoin) {
            JoinGroupView(isPresented: $showingJoin)
                .environmentObject(appData)
        }
    }
}

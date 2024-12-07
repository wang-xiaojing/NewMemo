//
//  ContentView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/06.
//

import SwiftUI
import SwiftData

struct TopPage: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selection: String? = "Home"
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        NavigationSplitView {
            Form {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        } label: {
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        }
                    }
                    .onDelete(perform: deleteItems)
                }

                switch selection {
                case "Home":
                    HomeView()
                case "New":
                    NewView()
                case "List":
                    ListView()
                case "Calendar":
                    CalendarView()
                case "Settings":
                    SettingsView()
                default:
                    Text("Select an item")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSearchActive.toggle()
                    }) {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: addItem) {
                        Label("Menu", systemImage: "filemenu.and.cursorarrow")
                    }
                }
                // 画面下部
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        selection = "Home"
                    }) {
                        VStack {
                            Image(systemName: "house")
                            Text("Home").font(.caption)
                        }
                    }
                    Spacer()
                    Button(action: {
                        selection = "New"
                    }) {
                        VStack {
                            Image(systemName: "text.badge.plus")
                            Text("New").font(.caption)
                        }
                    }
                    Spacer()
                    Button(action: {
                        selection = "List"
                    }) {
                        VStack {
                            Image(systemName: "list.bullet")
                            Text("List").font(.caption)
                        }
                    }
                    Spacer()
                    Button(action: {
                        selection = "Calendar"
                    }) {
                        VStack {
                            Image(systemName: "calendar")
                            Text("Calendar").font(.caption)
                        }
                    }
                    Spacer()
                    Button(action: {
                        selection = "Settings"
                    }) {
                        VStack {
                            Image(systemName: "gearshape")
                            Text("Settings").font(.caption)
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search items")
            .onChange(of: searchText) { newValue in
                // サーチテキストが変更されたときの処理
                // 例えば、itemsをフィルタリングするなど
            }
        } detail: {
            switch selection {
            case "Home":
                HomeView()
            case "New":
                NewView()
            case "List":
                ListView()
            case "Calendar":
                CalendarView()
            case "Settings":
                SettingsView()
            default:
                Text("Select an item")
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// 各画面の定義
struct HomeView: View {
    var body: some View {
        Text("Home View")
    }
}

struct NewView: View {
    var body: some View {
        Text("New View")
    }
}

struct ListView: View {
    var body: some View {
        Text("List View")
    }
}

struct CalendarView: View {
    var body: some View {
        Text("Calendar View")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
    }
}


#Preview {
    TopPage()
        .modelContainer(for: Item.self, inMemory: true)
}

#Preview {
    HomeView()
        // .modelContainer(for: Item.self, inMemory: true)
}


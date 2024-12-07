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
    @State private var selection: String? = "Home"
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var menuPushed: Bool = false

    var body: some View {
        NavigationSplitView {
            Form {
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
            .navigationTitle(selection ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            menuPushed.toggle()
                        }
                    }) {
                        Label("Menu", systemImage: "line.horizontal.3")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSearchActive.toggle()
                    }) {
                        Label("Search", systemImage: "magnifyingglass")
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
            .onChange(of: searchText) {
                // サーチテキストが変更されたときの処理
                // 例えば、itemsをフィルタリングするなど
            }
            .overlay(
                MenuSheet()
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .offset(x: menuPushed ? 0 : -UIScreen.main.bounds.width)
                    .animation(.easeInOut, value: menuPushed)
            )
        } detail: {
        }
    }
}

extension AnyTransition {
    static var moveFromLeft: AnyTransition {
        AnyTransition.move(edge: .leading)
    }
}

#Preview {
    TopPage()
        .modelContainer(for: Item.self, inMemory: true)
}

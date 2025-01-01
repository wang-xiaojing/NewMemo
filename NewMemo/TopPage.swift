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
    @State private var selection: String = "Home"
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var menuPushed: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var selectedRow: Int = 0

    var body: some View {
        NavigationSplitView {
            ZStack {
                if menuPushed && selection != "Home" && selection != "Settings" {
                    Color.yellow.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                menuPushed = false
                            }
                        }
                }
                contentForSelection(selection)
            }
            .navigationTitle("\(selection)\((selection != "Home" && selection != "Settings") ? "\(AppSetting.menuSheetItems[selectedRow][2])" : "")")
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
                    .padding()
                }
                // 画面下部
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        Button(action: {
                            selection = "Home"
                            menuPushed = false
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
                            menuPushed = false
                        }) {
                            VStack {
                                Image(systemName: "gearshape")
                                Text("Settings").font(.caption)
                            }
                        }
                    }
                    .padding()
                }
            }
            // .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search items")
            .onChange(of: searchText) {
                // サーチテキストが変更されたときの処理
                // 例えば、itemsをフィルタリングするなど
            }
            .overlay(
                ZStack {
                    if selection != "Home" && selection != "Settings" {
                        MenuSheet(menuPushed: $menuPushed, selectedRow: $selectedRow)
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                        // .background(Color.white)
                            .cornerRadius(AppSetting.cornerRadius)
                            .shadow(radius: AppSetting.shadowRadius)
                            .opacity(0.8)
                            .offset(x: menuPushed ? 0 : -UIScreen.main.bounds.width + dragOffset.width)
                            .animation(.easeInOut, value: menuPushed)
                        if !menuPushed {
                            HStack {
                                Rectangle()
                                    .fill(Color.gray)
                                    .cornerRadius(AppSetting.cornerRadius)
                                    .shadow(radius: AppSetting.shadowRadius)
                                    .frame(width: AppSetting.sideHandrailWidth, height: AppSetting.sideHandrailHeight)
                                    .offset(x: UIScreen.main.bounds.width * 0.03)
                                Spacer()
                            }
                        }
                    }
                }
                , alignment: .leading     // 重なるレビューの位置を指定する（左）
            )
            .gesture(   // スワイプ機能
                DragGesture()
                    .onChanged { value in
                        if value.translation.width > 0 {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        if value.translation.width > 100 {  // 右スワイプ
                            withAnimation {
                                menuPushed = true   // MenuSheetを表示する
                            }
                        } else if value.translation.width < -100 {  // 左スワイプ
                             withAnimation {
                                 menuPushed = false // MenuSheetを閉じる
                             }
                        }
                        dragOffset = .zero
                    }
            )
        } detail: {
        }
    }

    @ViewBuilder
    private func contentForSelection(_ selection: String?) -> some View {
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

extension AnyTransition {
    static var moveFromLeft: AnyTransition {
        AnyTransition.move(edge: .leading)
    }
}

#Preview {
    TopPage()
        .modelContainer(for: Item.self, inMemory: true)
}

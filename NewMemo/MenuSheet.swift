//
//  MenuSheet.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/07.
//

import SwiftUI

struct MenuSheet: View {
    @Binding var menuPushed: Bool
    @State private var isSearchActive: Bool = false
    @State private var items: [[String]] = AppSetting.menuSheetItems
    @State private var newItem: [String] = ["", ""]
    // @State private var selectedRow: Int? = nil
    @Binding var selectedRow: Int?

    var body: some View {
        NavigationView {
            List {
                ForEach(items.indices, id: \.self) { index in
                    HStack {
                        Text(items[index][1])
                            .foregroundColor(selectedRow == index ? .red : .black)
                        Image(systemName: items[index][0])
                            .foregroundColor(selectedRow == index ? .red : .black)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(selectedRow == index ? .red : .clear)
                    }
                    .contentShape(Rectangle()) // 行全体をタップ可能にする
                    .onTapGesture {
                        selectedRow = index
                    }
                }
               .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        menuPushed = false
                    }) {
                        Label("Close", systemImage: "wrongwaysign.fill")
                    }
                    .padding()
                }
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    @Previewable @State var menuPushed: Bool = true
    @Previewable @State var selectedRow: Int? = nil
    MenuSheet(menuPushed: $menuPushed, selectedRow: $selectedRow)
}

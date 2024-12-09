//
//  test.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/09.
//

import SwiftUI

struct ContentView: View {
    @State private var items: [String] = ["Item 1", "Item 2", "Item 3"]
    @State private var newItem: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // HStack {
                //     TextField("New Item", text: $newItem)
                //         .textFieldStyle(RoundedBorderTextFieldStyle())
                //     Button(action: {
                //         if !newItem.isEmpty {
                //             items.append(newItem)
                //             newItem = ""
                //         }
                //     }) {
                //         Text("Add")
                //     }
                // }
                // .padding()

                List {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
                .toolbar {
                    EditButton()
                }
            }
            .navigationTitle("Items")
        }
    }

    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  SearchBar.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//
import SwiftUI

// 検索バーを表示するビュー
struct SearchBar: View {
    @Binding var searchText: String
    var onSearchBarSearchButtonClicked: () -> Void

    var body: some View {
        VStack {
            HStack {
                TextField("Search on map", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .submitLabel(.search)
                    .onSubmit {
                        onSearchBarSearchButtonClicked()
                    }
                Button(action: onSearchBarSearchButtonClicked) {
                    Text("Search")
                }
            }
        }
        .padding()
    }
}

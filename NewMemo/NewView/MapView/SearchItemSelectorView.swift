import SwiftUI
import MapKit

struct SearchItemSelectorView: View {
    @Binding var searchResults: [MKMapItem]
    @Binding var selectedSearchResult: MKMapItem?
    var onCancelOfSearchItemSelectorView: () -> Void
    var onConfirmOfSearchItemSelectorView: () -> Void

    var body: some View {
        VStack {
            List(searchResults, id: \.self) { item in
                HStack {
                    Text(item.name ?? "No name")
                    Spacer()
                    if selectedSearchResult == item {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSearchResult = item
                }
            }
            HStack {
                Button(action: onCancelOfSearchItemSelectorView) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                
                Button(action: {
                    if selectedSearchResult == nil {
                        onCancelOfSearchItemSelectorView() // MARK: 選択されていない場合はキャンセルと同じ動作
                    } else {
                        onConfirmOfSearchItemSelectorView()
                    }
                }) {
                    Text("OK")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
            }
        }
    }
}

import SwiftUI
import MapKit

struct SearchItemSelectorView: View {
    @Binding var searchResults: [MKMapItem]
    @Binding var selectedSearchResult: MKMapItem?
    var onCancel: () -> Void
    var onConfirm: () -> Void

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
                Button(action: onCancel) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                
                Button(action: {
                    if selectedSearchResult == nil {
                        onCancel() // 選択されていない場合はキャンセルと同じ動作
                    } else {
                        onConfirm()
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

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
    @State private var items: [[String]] = [
        ["text.document",    "Text"],
        ["calendar",    "Date"],
        ["clock.badge.checkmark",    "Time"],
        ["globe.asia.australia",    "Location"],
        ["alarm.waves.left.and.right",    "Alarm"],
        ["music.microphone",    "Voice Rec."],
        ["medical.thermometer",    "Thermometer"],
        ["heart",    "Heart Rate"],
        ["waveform.path.ecg.rectangle",    "Blood Pressure"],
        ["figure.mixed.cardio",    "Weight Scale"],
        ["coat",    "Wear"],
        ["basket",    "Shopping"],
        ["dollarsign",    "Money"],
        ["calendar.badge.checkmark",    "Schedule"],
        ["book",    "Diary"],
        ["photo.artframe",    "Picture"],
        ["frying.pan",    "Cooking"],
        ["books.vertical.fill",    "Reading"],
        ["cloud.sun",    "Weather"],
        ["figure.run",    "Running"]
    ]
    @State private var newItem: [String] = ["", ""]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Image(systemName: item[0])
                        Spacer()
                        Text(item[1])
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
    MenuSheet(menuPushed: $menuPushed)
}

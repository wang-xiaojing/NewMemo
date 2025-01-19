//
//  NewMemoApp.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/06.
//

import SwiftUI
import SwiftData

@main
struct NewMemoApp: App {
    // MARK: - AudioRecorderのインスタンスを作成
    @StateObject private var audioRecorder = AudioRecorder()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TopPage()
                .environmentObject(audioRecorder)
        }
        .modelContainer(sharedModelContainer)
    }
}

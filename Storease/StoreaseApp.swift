//
//  StoreaseApp.swift
//  Storease
//
//  Created by Fabio Antonucci on 10/12/25.
//

import SwiftUI
import SwiftData

@main
struct StoreaseApp: App {
    var sharedModelContainer: ModelContainer = {
        let config = ModelConfiguration(for: SavedStory.self)
        return try! ModelContainer(for: SavedStory.self, configurations: config)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

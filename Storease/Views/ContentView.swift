//
//  ContentView.swift
//  Storease
//
//  Created by Fabio Antonucci on 11/12/25.
//

import SwiftUI

/// Root content view – now just presents the Keynote-style start screen.
struct ContentView: View {
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"

    var body: some View {
        TabView {
            StartScreenView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            StoriesView()
                .tabItem { Label("Library", systemImage: "books.vertical.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(AppColors.accent(from: appAccentColor))
    }
}

#Preview {
    ContentView()
}

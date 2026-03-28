//
//  SettingsView.swift
//  Storease
//
//  Created by Fabio Antonucci on 26/12/25.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"
    @AppStorage("storyResponseType") private var storyResponseType: String = "concise"
    
    var body: some View {
        
        ZStack {
            
            
            NavigationStack {
                Form {
                    Section(header: Text("Theme")) {
                        Picker("App Theme", selection: $appAppearance) {
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                            Text("Automatic").tag("system")
                        }
                        .pickerStyle(.segmented)
                       
                    }
                    
                    Section(header: Text("Accent Color")) {
                        Picker("Accent Color", selection: $appAccentColor) {
                            Text("Yellow").tag("yellow")
                            Text("Blue").tag("blue")
                            Text("Liliac").tag("liliac")
                            Text("Orange").tag("orange")
                            Text("Red").tag("red")
                            Text("Green").tag("green")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Story Mood")) {
                        Picker("Response Type", selection: $storyResponseType) {
                            Text("Concise").tag("concise")
                            Text("Detailed").tag("detailed")
                            Text("Humorous").tag("humorous")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .navigationTitle("Settings")
            }
            
            .preferredColorScheme(appAppearance == "light" ? .light : (appAppearance == "dark" ? .dark : nil))
        }
    }
}

#Preview {
    SettingsView()
}

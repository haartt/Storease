//
//  ImageDescriptionSection.swift
//  Storease
//
//  Created by Fabio Antonucci on 15/12/25.
//


import SwiftUI

struct ImageDescriptionSection: View {
    @Binding var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Describe what inspires you in this image")
                .font(.headline)

            TextEditor(text: $description)
                .scrollContentBackground(.hidden)
                .padding(16)
                .lightLiquidGlass()
                .frame(height: 120)
        }
    }
}
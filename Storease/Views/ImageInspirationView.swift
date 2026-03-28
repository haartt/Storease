//
//  ImageInspirationView 2.swift
//  Storease
//
//  Created by Fabio Antonucci on 15/12/25.
//


import SwiftUI

struct ImageInspirationView: View {
    @Binding var tags: [String]
    @Binding var description: String

    var onClassify: () async -> Void
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ImageTagsSection(
                tags: $tags,
                onClassify: onClassify
            )

            ImageDescriptionSection(
                description: $description
            )

            ContinueButton(
                isEnabled: !description.isEmpty && !tags.isEmpty,
                action: onSave
            )
        }
    }
}
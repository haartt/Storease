//
//  ImageTagsSection.swift
//  Storease
//
//  Created by Fabio Antonucci on 15/12/25.
//


import SwiftUI

struct ImageTagsSection: View {
    @Binding var tags: [String]
    var onClassify: () async -> Void

    @State private var isClassifying = false

    var body: some View {
        if tags.isEmpty {
            ClassifyImageButton(
                isLoading: isClassifying,
                action: classify
            )
        } else {
            TagsList(tags: $tags)
        }
    }

    private func classify() {
        Task {
            isClassifying = true
            await onClassify()
            isClassifying = false
        }
    }
}

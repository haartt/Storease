//
//  TagsList.swift
//  Storease
//
//  Created by Fabio Antonucci on 15/12/25.
//


import SwiftUI

struct TagsList: View {
    @Binding var tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Image Tags")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    TagChip(
                        tag: tag,
                        onRemove: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                remove(tag)
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: tags)
        }
        .padding()
        .lightLiquidGlass()
    }

    private func remove(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

#Preview {
    StatefulPreviewWrapper(["Nature", "Travel", "Urban", "Night"]) { tags in
        TagsList(tags: tags)
            .padding()
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

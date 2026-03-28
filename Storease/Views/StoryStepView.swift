//
//  View.swift
//  Storease
//
//  Created by Fabio Antonucci on 10/12/25.
//

import SwiftUI

struct StoryStepView: View {
    let step: StoryStep

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(step.text)
                .font(.body)
            Text(step.createdAt, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .lightLiquidGlass()
    }
}

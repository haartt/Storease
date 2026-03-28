//
//  ClassifyImageButton.swift
//  Storease
//
//  Created by Fabio Antonucci on 15/12/25.
//


import SwiftUI

struct ClassifyImageButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "sparkles")
                        .font(.title3)
                }
                Text(isLoading ? "Classifying..." : "Classify Image")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .lightLiquidGlass()
        }
        .disabled(isLoading)
    }
}

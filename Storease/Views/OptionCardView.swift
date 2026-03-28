//
//  OptionCardView.swift
//  Storease
//
//  Created by Fabio Antonucci on 11/12/25.
//

import SwiftUI

struct OptionCardView: View {
    let title: String
    let action: () -> Void
    var isSelected: Bool = false
    var systemImage: String = "sparkles"
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"

    var body: some View {
        Button(role: nil, action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(isSelected ? AppColors.accent(from: appAccentColor) : .secondary)
                Text(title)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding()
            .lightLiquidGlass()
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? AppColors.accent(from: appAccentColor).opacity(0.45) : .clear,
                    radius: isSelected ? 14 : 0,
                    x: 0,
                    y: 0)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                       value: isSelected)
        }
    }
}

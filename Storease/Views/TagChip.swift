//
//  TagChip.swift
//  Storease
//
//  Created by Fabio Antonucci on 15/12/25.
//


import SwiftUI

struct TagChip: View {
    let tag: String
    let onRemove: () -> Void
    
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"

    var body: some View {
        HStack(spacing: 6) {
            Text(tag)
                .font(.caption)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.accent(from: appAccentColor).opacity(0.2))
        .foregroundStyle(AppColors.accent(from: appAccentColor))
        .cornerRadius(16)
    }
}

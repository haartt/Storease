//
//  FeatureHintView.swift
//  Storease
//
//  Created by Fabio Antonucci on 26/12/25.
//


// FeatureHintView.swift
import SwiftUI

struct FeatureHintView: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(.white.opacity(0.6))
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

//
//  ContinueButton.swift
//  Storease
//
//  Created by Fabio Antonucci on 15/12/25.
//


import SwiftUI

struct ContinueButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .lightLiquidGlass()
        }
        .disabled(!isEnabled)
    }
}

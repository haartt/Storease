//
//  StoryImageView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 04/12/25.
//

import SwiftUI

struct StoryImageView: View {
    let image: UIImage?
    @State private var rotation: Double = Double.random(in: -2.5...2.5)

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(Rectangle())
                .padding(16)
                .background(
                    Rectangle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                )
                .padding(.horizontal)
                .padding(.vertical, 4)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 4.0...6.0))
                        .repeatForever(autoreverses: true)
                    ) {
                        rotation = Double.random(in: -2.5...2.5)
                    }
                }
        }
    }
}

#Preview {
    StoryImageView(image: UIImage(named: "Image"))
}

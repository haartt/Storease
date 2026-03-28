//
//  JustifiedDropCapText.swift
//  Storease
//
//  Created by Fabio Antonucci on 27/12/25.
//

import SwiftUI
import UIKit

struct JustifiedDropCapText: View {
    let text: String
    let dropCapFont: Font
    let bodyFont: Font
    let linesToSpan: CGFloat
    let lineSpacing: CGFloat
    let textAlignment: TextAlignment

    init(
        text: String,
        dropCapFont: Font = .system(size: 52, weight: .bold),
        bodyFont: Font = .system(size: 18),
        linesToSpan: CGFloat = 3,
        lineSpacing: CGFloat = 2,
        textAlignment: TextAlignment = .leading
    ) {
        self.text = text
        self.dropCapFont = dropCapFont
        self.bodyFont = bodyFont
        self.linesToSpan = linesToSpan
        self.lineSpacing = lineSpacing
        self.textAlignment = textAlignment
    }

    var body: some View {
        DropCapTextView(
            text: text,
            dropCapFont: dropCapFont,
            bodyFont: bodyFont,
            linesToSpan: linesToSpan,
            lineSpacing: lineSpacing,
            textAlignment: textAlignment
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DropCapTextView: UIViewRepresentable {
    let text: String
    let dropCapFont: Font
    let bodyFont: Font
    let linesToSpan: CGFloat
    let lineSpacing: CGFloat
    let textAlignment: TextAlignment
    
    private func nsTextAlignment(from alignment: TextAlignment) -> NSTextAlignment {
        switch alignment {
        case .leading: return .left
        case .trailing: return .right
        case .center: return .center
        @unknown default: return .natural
        }
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width: CGFloat = {
            if let proposed = proposal.width { return proposed }
            if uiView.bounds.width > 0 { return uiView.bounds.width }
            if let sceneScreenWidth = uiView.window?.windowScene?.screen.bounds.width { return sceneScreenWidth }
            return 0
        }()
        uiView.frame.size.width = width
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: size.height)
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        guard let firstChar = text.first else {
            textView.text = text
            return
        }
        
        let remainingText = String(text.dropFirst())
        
        // Convert SwiftUI fonts to UIFont
        let baseDropCapUIFont = UIFont.systemFont(ofSize: 52, weight: .bold)
        let baseBodyUIFont = UIFont.systemFont(ofSize: 18, weight: .regular)

        // Dynamic Type scaling for consistency with user settings
        let metrics = UIFontMetrics(forTextStyle: .body)
        let scaledBodyUIFont = metrics.scaledFont(for: baseBodyUIFont)
        let scaledDropBaseUIFont = metrics.scaledFont(for: baseDropCapUIFont)

        // Scale drop cap to span a target number of body lines
        let bodyLineHeight = scaledBodyUIFont.lineHeight
        let targetHeight = max(1, linesToSpan) * bodyLineHeight
        let scale = targetHeight / max(1, scaledDropBaseUIFont.lineHeight)
        let adjustedDropCapFont = UIFont(descriptor: scaledDropBaseUIFont.fontDescriptor, size: scaledDropBaseUIFont.pointSize * scale)

        // Calculate drop cap size
        let dropCapString = String(firstChar)
        let dropCapSize = (dropCapString as NSString).size(withAttributes: [.font: adjustedDropCapFont])

        // Paragraph style with improved spacing and hyphenation
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = nsTextAlignment(from: textAlignment)
        // If you want full justification regardless of SwiftUI's TextAlignment, set it here:
        if textAlignment == .leading {
            // Keep default mapping
        }
        paragraphStyle.hyphenationFactor = 0.8

        // Build attributed string
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: scaledBodyUIFont,
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ]

        let dropCapAttributes: [NSAttributedString.Key: Any] = [
            .font: adjustedDropCapFont,
            .foregroundColor: UIColor.label
        ]

        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: dropCapString, attributes: dropCapAttributes))
        attributedString.append(NSAttributedString(string: remainingText, attributes: bodyAttributes))

        textView.attributedText = attributedString
        textView.layoutIfNeeded()

        // Create rounded exclusion path for nicer wrapping
        let paddingRight: CGFloat = 6
        let paddingTop: CGFloat = 2
        let exclusionRect = CGRect(
            x: 0,
            y: 0,
            width: dropCapSize.width + 8 + paddingRight,
            height: dropCapSize.height + paddingTop
        )
        let exclusionPath = UIBezierPath(roundedRect: exclusionRect, cornerRadius: 4)
        textView.textContainer.exclusionPaths = [exclusionPath]

        // Remove any existing drop cap labels
        textView.subviews.forEach { subview in
            if subview.tag == 999 { subview.removeFromSuperview() }
        }

        // Add drop cap as overlay
        let dropCapLabel = UILabel()
        dropCapLabel.tag = 999
        dropCapLabel.text = dropCapString
        dropCapLabel.font = adjustedDropCapFont
        dropCapLabel.textColor = UIColor.label

        // Slight vertical tweak to align visually with first line
        let verticalOffset: CGFloat = -2
        dropCapLabel.frame = CGRect(x: 0, y: verticalOffset, width: dropCapSize.width, height: dropCapSize.height)
        textView.addSubview(dropCapLabel)

        // Hide the inline first character so only the overlay is visible
        attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(location: 0, length: 1))
        textView.attributedText = attributedString
    }
}

struct JustifiedDropCapText_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 30) {
                JustifiedDropCapText(
                    text: "We the People of the United States, in Order to form a more perfect Union, establish Justice, ensure domestic Tranquility, provide for the common defence, promote the general Welfare, and secure the Blessings of Liberty to ourselves and our Posterity, do ordain and establish this Constitution for the United States of America."
                )
                .multilineTextAlignment(.leading)
                .padding()
                .background(Color.orange.opacity(0.3))
                
                JustifiedDropCapText(
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
                )
                .padding()
            }
        }
    }
}

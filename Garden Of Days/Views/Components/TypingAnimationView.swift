//
//  TypingAnimationView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI

/// A view that displays text with a typing animation effect
struct TypingAnimationView: View {
    let text: String
    let typingSpeed: Double

    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var showCursor: Bool = true

    init(_ text: String, typingSpeed: Double = 0.05) {
        self.text = text
        self.typingSpeed = typingSpeed
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(displayedText)
                .font(.system(.body, design: .monospaced))

            // Blinking cursor
            if showCursor && currentIndex < text.count {
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 2, height: 16)
                    .opacity(showCursor ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: showCursor)
            }
        }
        .onAppear {
            startTyping()
        }
    }

    private func startTyping() {
        guard currentIndex < text.count else { return }

        let index = text.index(text.startIndex, offsetBy: currentIndex)

        DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
            displayedText.append(text[index])
            currentIndex += 1
            startTyping()
        }
    }
}

/// A simple cursor blink view
struct BlinkingCursor: View {
    @State private var isVisible: Bool = true
    let color: Color

    init(color: Color = .primary) {
        self.color = color
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 2, height: 18)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                    isVisible.toggle()
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        TypingAnimationView("Hello, Garden Of Days...")

        HStack {
            Text("Typing")
            BlinkingCursor()
        }
    }
    .padding()
}

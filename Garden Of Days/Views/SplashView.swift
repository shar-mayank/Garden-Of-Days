//
//  SplashView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI

struct SplashView: View {
    @Binding var widgetDeepLink: URL?
    @State private var isActive: Bool = false
    @State private var flowerScale: CGFloat = 0.5
    @State private var flowerOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var flowerRotation: Double = -90

    var body: some View {
        ZStack {
            // ContentView is always present but hidden initially
            ContentView(widgetDeepLink: $widgetDeepLink)
                .opacity(isActive ? 1 : 0)

            // Splash overlay
            if !isActive {
                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    VStack(spacing: 30) {
                        // Animated flower
                        ZStack {
                            ForEach(0..<8, id: \.self) { index in
                                FloralSplashPetal()
                                    .stroke(Color.white, lineWidth: 1.5)
                                    .frame(width: 20, height: 40)
                                    .offset(y: -30)
                                    .rotationEffect(.degrees(Double(index) * 45))
                            }

                            Circle()
                                .fill(Color.white)
                                .frame(width: 12, height: 12)
                        }
                        .scaleEffect(flowerScale)
                        .rotationEffect(.degrees(flowerRotation))
                        .opacity(flowerOpacity)

                        // App name
                        Text("Garden Of Days")
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .opacity(textOpacity)
                    }
                }
                .onAppear {
                    withAnimation(.spring(duration: 0.8)) {
                        flowerScale = 1.0
                        flowerOpacity = 1.0
                        flowerRotation = 0
                    }

                    withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                        textOpacity = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

/// Custom petal shape for splash screen
struct FloralSplashPetal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.maxX + 5, y: rect.midY)
        )

        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.minX - 5, y: rect.midY)
        )

        return path
    }
}

// MARK: - Preview

#Preview {
    SplashView(widgetDeepLink: .constant(nil))
}

//
//  SVGImageView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI
import WebKit

/// A view that displays SVG images using WKWebView
struct SVGImageView: UIViewRepresentable {
    let svgName: String
    let tintColor: Color

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let svgURL = Bundle.main.url(forResource: svgName, withExtension: "svg", subdirectory: "Resources/Florals") ?? Bundle.main.url(forResource: svgName, withExtension: "svg") else {
            print("SVG not found: \(svgName)")
            return
        }

        do {
            let svgString = try String(contentsOf: svgURL, encoding: .utf8)

            // Convert SwiftUI Color to hex
            let uiColor = UIColor(tintColor)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let hexColor = String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))

            // Inject CSS to change the color
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    * { margin: 0; padding: 0; }
                    html, body {
                        width: 100%;
                        height: 100%;
                        background: transparent;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }
                    svg {
                        width: 100%;
                        height: 100%;
                        fill: \(hexColor);
                        stroke: \(hexColor);
                    }
                    svg * {
                        fill: inherit;
                        stroke: inherit;
                    }
                </style>
            </head>
            <body>
                \(svgString)
            </body>
            </html>
            """

            webView.loadHTMLString(html, baseURL: nil)
        } catch {
            print("Error loading SVG: \(error)")
        }
    }
}

#Preview {
    SVGImageView(svgName: "floral_1", tintColor: Color(hex: "000080"))
        .frame(width: 50, height: 50)
}

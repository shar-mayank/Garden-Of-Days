//
//  EntryView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI

struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: GardenViewModel
    let day: GardenDay

    @State private var memoryText: String = ""
    @State private var isTyping: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    private let maxCharacters = 365

    var body: some View {
        ZStack {
            // Background
            Color(hex: "FAFAFA")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Divider
                Rectangle()
                    .fill(Color(hex: "E5E5EA"))
                    .frame(height: 1)

                // Text Editor
                editorView

                Spacer()
            }
        }
        .onAppear {
            // Load existing memory if any
            if let existingMemory = day.memory {
                memoryText = existingMemory.content
            }

            // Focus text field after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .onDisappear {
            // Auto-save on dismiss
            saveMemoryIfNeeded()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            // Date with flower icon
            HStack(spacing: 8) {
                Image(systemName: day.hasMemory ? "leaf.fill" : "leaf")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "000080"))

                Text(day.displayDate)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color(hex: "000080"))
            }

            Spacer()

            // Character counter
            Text("\(memoryText.count)/\(maxCharacters)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(characterCountColor)

            // Done button
            Button {
                saveMemoryIfNeeded()
                dismiss()
            } label: {
                Text("done")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color(hex: "000080"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color(hex: "000080"), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }

    // MARK: - Editor

    private var editorView: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder
            if memoryText.isEmpty {
                Text("i...")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
            }

            // Text Editor
            TextEditor(text: $memoryText)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(Color(hex: "000080"))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .focused($isTextFieldFocused)
                .onChange(of: memoryText) { oldValue, newValue in
                    // Limit character count
                    if newValue.count > maxCharacters {
                        memoryText = String(newValue.prefix(maxCharacters))
                    }

                    // Typing animation
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isTyping = true
                    }

                    // Reset typing state after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isTyping = false
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    // MARK: - Helper Properties

    private var characterCountColor: Color {
        let percentage = Double(memoryText.count) / Double(maxCharacters)
        if percentage >= 0.95 {
            return Color.red
        } else if percentage >= 0.8 {
            return Color.orange
        }
        return Color.gray
    }

    // MARK: - Actions

    private func saveMemoryIfNeeded() {
        let trimmedText = memoryText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            // If text is empty and there was a memory, delete it
            if day.memory != nil {
                viewModel.deleteMemory(for: day)
            }
        } else {
            // Save or update memory
            viewModel.saveMemory(content: trimmedText, for: day)
        }
    }
}

// MARK: - Preview

#Preview {
    let day = GardenDay(
        id: 1,
        date: Date(),
        memory: nil
    )

    return EntryView(
        viewModel: GardenViewModel(),
        day: day
    )
}

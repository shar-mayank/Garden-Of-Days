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
    @State private var showShareSheet: Bool = false

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
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareContent])
        }
    }

    // MARK: - Share Content

    private var shareContent: String {
        let dateString = day.displayDate
        return "\(dateString)\n\n\(memoryText)"
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            // Date with flower icon
            HStack(spacing: 8) {
                Image(systemName: day.hasMemory ? "leaf.fill" : "leaf")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "f670b2"))

                Text(day.displayDate)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color(hex: "f670b2"))
            }

            Spacer()

            // Share button
            Button {
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                    .foregroundColor(memoryText.isEmpty ? Color.gray : Color(hex: "f670b2"))
            }
            .disabled(memoryText.isEmpty)
            .padding(.trailing, 12)

            // Done button
            Button {
                saveMemoryIfNeeded()
                dismiss()
            } label: {
                Text("done")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color(hex: "f670b2"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color(hex: "f670b2"), lineWidth: 1)
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
                .foregroundColor(Color(hex: "f670b2"))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .focused($isTextFieldFocused)
                .onChange(of: memoryText) { oldValue, newValue in
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

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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

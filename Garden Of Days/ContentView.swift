//
//  ContentView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Binding var widgetDeepLink: URL?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = GardenViewModel()
    @State private var showStats: Bool = false
    @State private var hasConfigured: Bool = false
    @State private var showMagicHint: Bool = false
    @AppStorage("hasSeenMagicHint") private var hasSeenMagicHint: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                viewModel.backgroundColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: viewModel.viewMode)

                // Main content with header and grid
                VStack(spacing: 0) {
                    // Header - fixed height for inline year picker
                    headerView
                        .frame(height: 140)

                    // Grid - takes remaining space
                    GardenGridView(viewModel: viewModel)
                        .frame(height: geometry.size.height - 140 - 80) // Fixed height: total - header - footer
                        .clipped()
                }

                // Fixed footer at bottom - uses overlay positioning
                VStack {
                    Spacer()

                    ZStack(alignment: .bottom) {
                        // Gradient fade background
                        LinearGradient(
                            colors: [
                                viewModel.backgroundColor.opacity(0),
                                viewModel.backgroundColor.opacity(0.9),
                                viewModel.backgroundColor
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        .allowsHitTesting(false)

                        footerView
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            // Toast as overlay - doesn't affect layout
            .overlay(alignment: .bottom) {
                ToastView(
                    message: viewModel.toastMessage,
                    isVisible: viewModel.showToast
                )
                .padding(.bottom, 120)
                .allowsHitTesting(false)
            }
        }
        .onAppear {
            configureViewModelIfNeeded()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Reload data when app becomes active (handles rotation, background/foreground)
            if newPhase == .active {
                // Small delay to ensure context is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.reloadMemories()
                }
            }
        }
        .sheet(isPresented: $viewModel.showEntrySheet) {
            if let selectedDay = viewModel.selectedDay {
                EntryView(viewModel: viewModel, day: selectedDay)
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showStats) {
            StatsView(viewModel: viewModel)
                .presentationDragIndicator(.visible)
        }
        .onChange(of: widgetDeepLink) { _, newURL in
            handleWidgetDeepLink(newURL)
        }
    }

    private func handleWidgetDeepLink(_ url: URL?) {
        guard let url = url else { return }

        // Handle widget deep links: gardenofdays://void or gardenofdays://growth
        if url.host == "void" {
            viewModel.setViewMode(.void)
        } else if url.host == "growth" {
            viewModel.setViewMode(.growth)
        }

        // Clear the deep link after handling
        widgetDeepLink = nil
    }

    private func configureViewModelIfNeeded() {
        guard !hasConfigured else { return }
        viewModel.configure(with: modelContext)
        hasConfigured = true
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            // Magic hint message (shows once on first open)
            if showMagicHint {
                Text("Double-tap 🌿 to reveal magic!")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(viewModel.primaryColor.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(viewModel.primaryColor.opacity(0.1))
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Days left with inline year picker
            HStack(spacing: 0) {
                Text("\(viewModel.daysLeftInYear) days left in ")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(viewModel.primaryColor)

                // Compact inline year wheel picker
                Picker("Year", selection: Binding(
                    get: { viewModel.selectedYear },
                    set: { viewModel.changeYear(to: $0) }
                )) {
                    ForEach(GardenViewModel.yearRange, id: \.self) { year in
                        Text(String(year))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 50)
                .clipped()
                .overlay(alignment: .bottom) {
                    // Subtle underline instead of rectangle
                    Rectangle()
                        .fill(viewModel.primaryColor.opacity(0.3))
                        .frame(height: 1)
                        .offset(y: -8)
                }
            }
            .onTapGesture {
                showStats = true
            }

            // Today's memory button (only show for current year)
            if viewModel.isCurrentYear {
                Button {
                    viewModel.selectToday()
                } label: {
                    HStack(spacing: 6) {
                        Text("📝")
                            .font(.system(size: 12))

                        Text("today's memory")
                            .font(.system(.footnote, design: .monospaced))
                    }
                    .foregroundColor(viewModel.primaryColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(viewModel.primaryColor.opacity(0.5), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 35)
        .padding(.bottom, 8)
        .onAppear {
            // Show hint on first app open
            if !hasSeenMagicHint {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showMagicHint = true
                    }
                }
                // Hide after 7 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showMagicHint = false
                    }
                    hasSeenMagicHint = true
                }
            }
        }
    }

    // MARK: - Footer View

    private var footerView: some View {
        VStack(spacing: 12) {
            // Mode toggle bar
            modeToggleBar
        }
        .padding(.bottom, 40)
    }

    // MARK: - Mode Toggle Bar

    private var modeToggleBar: some View {
        HStack(spacing: 0) {
            // Growth mode button (flowers)
            // Single tap: switch to growth mode
            // Double tap (when in growth mode): toggle drag reveal mode
            Image(systemName: viewModel.isDragRevealMode ? "hand.draw.fill" : "leaf.fill")
                .font(.system(size: 16))
                .foregroundColor(
                    viewModel.viewMode == .growth
                        ? viewModel.backgroundColor
                        : viewModel.primaryColor.opacity(0.5)
                )
                .frame(width: 50, height: 36)
                .background(
                    viewModel.viewMode == .growth
                        ? (viewModel.isDragRevealMode ? viewModel.primaryColor.opacity(0.7) : viewModel.primaryColor)
                        : Color.white.opacity(0.001) // Invisible but tappable
                )
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    // Double tap toggles drag reveal mode (only when already in growth mode)
                    if viewModel.viewMode == .growth {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.isDragRevealMode.toggle()
                        }
                    }
                }
                .onTapGesture(count: 1) {
                    // Single tap switches to growth mode (and exits drag reveal if active)
                    viewModel.isDragRevealMode = false
                    viewModel.setViewMode(.growth)
                }

            // Divider
            Rectangle()
                .fill(viewModel.primaryColor.opacity(0.3))
                .frame(width: 1, height: 20)

            // Void mode button (grid)
            Image(systemName: "circle.grid.3x3.fill")
                .font(.system(size: 16))
                .foregroundColor(
                    viewModel.viewMode == .void
                        ? viewModel.backgroundColor
                        : viewModel.primaryColor.opacity(0.5)
                )
                .frame(width: 50, height: 36)
                .background(
                    viewModel.viewMode == .void
                        ? viewModel.primaryColor
                        : Color.white.opacity(0.001) // Invisible but tappable
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.setViewMode(.void)
                }
        }
        .background(
            Capsule()
                .stroke(viewModel.primaryColor.opacity(0.3), lineWidth: 1)
        )
        .clipShape(Capsule())
        .contentShape(Capsule()) // Entire capsule is tappable
    }
}

// MARK: - Preview

#Preview {
    ContentView(widgetDeepLink: .constant(nil))
        .modelContainer(for: MemoryEntry.self, inMemory: true)
}

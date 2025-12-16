//
//  ContentView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = GardenViewModel()
    @State private var showStats: Bool = false
    @State private var hasConfigured: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                viewModel.backgroundColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: viewModel.viewMode)

                // Main content with header and grid
                VStack(spacing: 0) {
                    // Header - fixed height (increased for logo)
                    headerView
                        .frame(height: 190)

                    // Grid - takes remaining space
                    GardenGridView(viewModel: viewModel)
                        .frame(height: geometry.size.height - 190 - 80) // Fixed height: total - header - footer
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
    }

    private func configureViewModelIfNeeded() {
        guard !hasConfigured else { return }
        viewModel.configure(with: modelContext)
        hasConfigured = true
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 12) {
            // App Logo
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Countdown text - tap for stats
            Button {
                showStats = true
            } label: {
                Text("\(viewModel.daysLeftInYear) days left in \(String(viewModel.currentYear))")
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.primaryColor)
            }
            .buttonStyle(.plain)

            // Today's memory button
            Button {
                viewModel.selectToday()
            } label: {
                HStack(spacing: 8) {
                    Text("📝")
                        .font(.system(size: 14))

                    Text("today's memory")
                        .font(.system(.body, design: .monospaced))
                }
                .foregroundColor(viewModel.primaryColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .stroke(viewModel.primaryColor.opacity(0.5), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 50)
        .padding(.bottom, 16)
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
            Image(systemName: "leaf.fill")
                .font(.system(size: 16))
                .foregroundColor(
                    viewModel.viewMode == .growth
                        ? viewModel.backgroundColor
                        : viewModel.primaryColor.opacity(0.5)
                )
                .frame(width: 50, height: 36)
                .background(
                    viewModel.viewMode == .growth
                        ? viewModel.primaryColor
                        : Color.white.opacity(0.001) // Invisible but tappable
                )
                .contentShape(Rectangle())
                .onTapGesture {
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
    ContentView()
        .modelContainer(for: MemoryEntry.self, inMemory: true)
}

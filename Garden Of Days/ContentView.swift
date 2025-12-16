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
        ZStack {
            // Background
            viewModel.backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: viewModel.viewMode)

            VStack(spacing: 0) {
                // Header
                headerView

                // Grid
                GardenGridView(viewModel: viewModel)

                // Footer
                footerView
            }

            // Toast overlay
            VStack {
                Spacer()
                ToastView(
                    message: viewModel.toastMessage,
                    isVisible: viewModel.showToast
                )
                .padding(.bottom, 120)
            }
        }
        .onAppear {
            configureViewModelIfNeeded()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Reload data when app becomes active (handles rotation, background/foreground)
            if newPhase == .active {
                viewModel.reloadMemories()
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
        VStack(spacing: 16) {
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
        .padding(.top, 60)
        .padding(.bottom, 24)
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
            Button {
                viewModel.setViewMode(.growth)
            } label: {
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
                            : Color.clear
                    )
            }
            .buttonStyle(.plain)

            // Divider
            Rectangle()
                .fill(viewModel.primaryColor.opacity(0.3))
                .frame(width: 1, height: 20)

            // Void mode button (grid)
            Button {
                viewModel.setViewMode(.void)
            } label: {
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
                            : Color.clear
                    )
            }
            .buttonStyle(.plain)
        }
        .background(
            Capsule()
                .stroke(viewModel.primaryColor.opacity(0.3), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: MemoryEntry.self, inMemory: true)
}

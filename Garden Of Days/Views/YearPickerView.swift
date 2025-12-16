//
//  YearPickerView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 16/12/25.
//

import SwiftUI

struct YearPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: GardenViewModel

    @State private var selectedYear: Int

    init(viewModel: GardenViewModel) {
        self.viewModel = viewModel
        self._selectedYear = State(initialValue: viewModel.selectedYear)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Year wheel picker
                Picker("Year", selection: $selectedYear) {
                    ForEach(GardenViewModel.yearRange, id: \.self) { year in
                        Text(String(year))
                            .font(.system(.title, design: .monospaced))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)

                // Quick jump buttons
                HStack(spacing: 16) {
                    // Jump to current year
                    Button {
                        selectedYear = viewModel.currentYear
                    } label: {
                        Text("Today")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(Color(hex: "f670b2"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .stroke(Color(hex: "f670b2"), lineWidth: 1)
                            )
                    }

                    // Confirm button
                    Button {
                        viewModel.changeYear(to: selectedYear)
                        dismiss()
                    } label: {
                        Text("Go to \(String(selectedYear))")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "f670b2"))
                            )
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Select Year")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.changeYear(to: selectedYear)
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "f670b2"))
                }
            }
        }
    }
}

#Preview {
    YearPickerView(viewModel: GardenViewModel())
}

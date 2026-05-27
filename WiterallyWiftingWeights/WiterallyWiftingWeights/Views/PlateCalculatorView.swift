//
//  PlateCalculatorView.swift
//  WiterallyWiftingWeights
//
//  Standalone plate calculator: type any weight, see what to load per side.
//

import SwiftUI

struct PlateCalculatorView: View {
    @State private var weight = PlateMath.barWeight

    private var solution: PlateMath.Solution {
        PlateMath.solve(total: weight)
    }

    var body: some View {
        Form {
            Section("Target Weight") {
                HStack(spacing: 16) {
                    Button {
                        weight = max(0, weight - 5)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                    }

                    TextField("Weight", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.title.bold())

                    Text("lb")
                        .foregroundStyle(.secondary)

                    Button {
                        weight += 5
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .font(.title2)
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
            }

            Section("Load Per Side") {
                PlateBarbellView(solution: solution)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle("Plate Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }
}

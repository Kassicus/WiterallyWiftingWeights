//
//  PlateBarbellView.swift
//  WiterallyWiftingWeights
//
//  Visual barbell showing the plates loaded on both sides for a target weight.
//

import SwiftUI

struct PlateBarbellView: View {
    let solution: PlateMath.Solution

    var body: some View {
        VStack(spacing: 12) {
            barbell
            VStack(spacing: 2) {
                Text(solution.summary)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                Text("Bar \(solution.bar.lbString)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var barbell: some View {
        HStack(spacing: 3) {
            // Left side: lightest (outer) → heaviest (next to the grip).
            ForEach(Array(solution.perSide.reversed().enumerated()), id: \.offset) { _, plate in
                plateView(plate)
            }

            // Knurled grip in the centre of the bar.
            Color.clear.frame(width: 34)

            // Right side: heaviest (next to the grip) → lightest (outer).
            ForEach(Array(solution.perSide.enumerated()), id: \.offset) { _, plate in
                plateView(plate)
            }
        }
        .frame(height: 110)
        .frame(maxWidth: .infinity)
        .background(alignment: .center) {
            // The bar shaft spans the full width behind the centred plates.
            Capsule()
                .fill(.secondary)
                .frame(height: 8)
                .padding(.horizontal, 8)
        }
    }

    private func plateView(_ plate: Double) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(PlateMath.color(for: plate))
            .frame(width: 26, height: PlateMath.height(for: plate))
            .overlay {
                Text(plate.lbValue)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(-90))
                    .fixedSize()
            }
            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
    }
}

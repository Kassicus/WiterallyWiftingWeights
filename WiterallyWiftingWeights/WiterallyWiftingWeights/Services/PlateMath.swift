//
//  PlateMath.swift
//  WiterallyWiftingWeights
//
//  Works out which plates to load on each side of a 45 lb barbell to reach a
//  target weight, greedily from the heaviest plate down.
//

import SwiftUI

enum PlateMath {
    /// Standard Olympic barbell weight, in pounds.
    static let barWeight: Double = 45

    /// Plate sizes available per side, heaviest first.
    static let availablePlates: [Double] = [45, 35, 25, 10, 5, 2.5]

    struct Solution {
        let bar: Double
        let total: Double
        /// Plates for one side, heaviest first.
        let perSide: [Double]
        /// Per-side weight that couldn't be made from the available plates.
        let leftover: Double

        var summary: String {
            guard !perSide.isEmpty else { return "Empty bar" }
            let parts = perSide.map(\.lbValue)
            var text = parts.joined(separator: " · ") + " lb / side"
            if leftover > 0.05 {
                text += " (+\(leftover.lbValue) short)"
            }
            return text
        }
    }

    static func solve(total: Double) -> Solution {
        var remaining = max(0, (total - barWeight) / 2)
        var plates: [Double] = []
        let epsilon = 0.001

        for plate in availablePlates {
            while remaining + epsilon >= plate {
                plates.append(plate)
                remaining -= plate
            }
        }
        return Solution(bar: barWeight, total: total, perSide: plates, leftover: max(0, remaining))
    }

    /// Visual height for a plate, scaled so the heaviest plate is tallest.
    static func height(for plate: Double) -> CGFloat {
        let maxPlate = availablePlates.first ?? plate
        let ratio = maxPlate > 0 ? plate / maxPlate : 1
        return 52 + CGFloat(ratio) * 46
    }

    static func color(for plate: Double) -> Color {
        switch plate {
        case 45: return .blue
        case 35: return .orange
        case 25: return .green
        case 10: return Color(.systemGray)
        case 5: return .red
        case 2.5: return .pink
        default: return .secondary
        }
    }
}

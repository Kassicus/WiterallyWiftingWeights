//
//  AppStorageKeys.swift
//  WiterallyWiftingWeights
//

import Foundation

enum AppStorageKey {
    static let defaultRest = "defaultRestDuration"
    static let appearance = "appearance"
}

extension Double {
    /// Numeric weight string, trimming trailing zeros (e.g. "47.5", "45").
    var lbValue: String {
        formatted(.number.precision(.fractionLength(0...1)))
    }

    /// Weight with unit suffix (e.g. "45 lb").
    var lbString: String {
        "\(lbValue) lb"
    }
}

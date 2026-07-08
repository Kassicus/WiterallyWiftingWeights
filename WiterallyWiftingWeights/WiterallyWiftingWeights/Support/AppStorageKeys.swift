//
//  AppStorageKeys.swift
//  WiterallyWiftingWeights
//

import Foundation

enum AppStorageKey {
    static let defaultRest = "defaultRestDuration"
    static let appearance = "appearance"
    static let timerSound = "timerSoundEnabled"

    /// Default for ``timerSound``. Kept here so the Settings toggle and the
    /// timer manager agree on the value used before the user changes it.
    static let timerSoundDefault = true
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

//
//  Sound.swift
//  WiterallyWiftingWeights
//

import AudioToolbox

enum Sound {
    /// System sound ID for the chime played when a rest timer completes.
    /// 1005 is a built-in alert tone, so no audio asset needs to be bundled.
    /// Like all system sounds it respects the device's silent switch — the
    /// haptic buzz and the scheduled local notification cover the muted case.
    private static let timerCompleteID: SystemSoundID = 1005

    /// Plays the alert chime used when a rest timer finishes.
    static func timerComplete() {
        AudioServicesPlaySystemSound(timerCompleteID)
    }
}

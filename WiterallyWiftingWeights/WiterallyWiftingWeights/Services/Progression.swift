//
//  Progression.swift
//  WiterallyWiftingWeights
//
//  StrongLifts-style weight progression: succeed → add the increment, fail →
//  repeat the weight, fail three sessions in a row → deload 10%.
//  All weights are in pounds.
//

import Foundation
import SwiftData

enum Progression {
    /// Suggested next working weight (lb) for an exercise based on its history.
    /// Pass the in-progress session to exclude it from the lookback.
    static func suggestedWeightLb(for exercise: Exercise,
                                  excluding session: WorkoutSession? = nil) -> Double {
        var history: [LoggedExercise] = exercise.loggedExercises.filter { logged in
            guard let loggedSession = logged.session else { return false }
            if let session, loggedSession.persistentModelID == session.persistentModelID {
                return false
            }
            return true
        }
        history.sort { lhs, rhs in
            let lhsDate = lhs.session?.date ?? .distantPast
            let rhsDate = rhs.session?.date ?? .distantPast
            return lhsDate > rhsDate
        }

        guard let last = history.first else { return exercise.defaultWeightLb }

        if last.isSuccessful {
            return last.weightLb + exercise.incrementLb
        }

        // Count consecutive recent failures (most recent first).
        var failures = 0
        for logged in history {
            if logged.isSuccessful { break }
            failures += 1
        }

        if failures >= 3 {
            let deloaded = last.weightLb * 0.9
            let step = max(exercise.incrementLb, 0.5)
            let rounded = (deloaded / step).rounded() * step
            return max(rounded, exercise.incrementLb)
        }

        return last.weightLb
    }
}

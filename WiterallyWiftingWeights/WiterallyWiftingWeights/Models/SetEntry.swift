//
//  SetEntry.swift
//  WiterallyWiftingWeights
//
//  A single set within a logged exercise.
//

import Foundation
import SwiftData

@Model
final class SetEntry {
    var setNumber: Int
    var targetReps: Int
    var completedReps: Int
    var isComplete: Bool

    var loggedExercise: LoggedExercise?

    init(setNumber: Int,
         targetReps: Int,
         completedReps: Int = 0,
         isComplete: Bool = false) {
        self.setNumber = setNumber
        self.targetReps = targetReps
        self.completedReps = completedReps
        self.isComplete = isComplete
    }
}

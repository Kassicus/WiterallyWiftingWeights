//
//  Exercise.swift
//  WiterallyWiftingWeights
//
//  A catalog definition of a lift. Performing it in a workout creates a
//  LoggedExercise that snapshots these defaults. All weights are in pounds.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var notes: String
    /// Default starting working weight, in pounds.
    var defaultWeightLb: Double
    /// Weight added on a successful session, in pounds.
    var incrementLb: Double
    var targetSets: Int
    var targetReps: Int
    var isArchived: Bool
    var sortOrder: Int
    var createdAt: Date

    /// History of every time this exercise was performed. Nullified (not
    /// cascaded) on delete so past workouts keep their logged numbers.
    @Relationship(deleteRule: .nullify, inverse: \LoggedExercise.exercise)
    var loggedExercises: [LoggedExercise] = []

    init(name: String,
         notes: String = "",
         defaultWeightLb: Double = 45,
         incrementLb: Double = 5,
         targetSets: Int = 5,
         targetReps: Int = 5,
         isArchived: Bool = false,
         sortOrder: Int = 0,
         createdAt: Date = .now) {
        self.name = name
        self.notes = notes
        self.defaultWeightLb = defaultWeightLb
        self.incrementLb = incrementLb
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.isArchived = isArchived
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}

//
//  LoggedExercise.swift
//  WiterallyWiftingWeights
//
//  An exercise as performed within a workout session. Holds the working
//  weight (in pounds) and the individual sets. The exercise name is
//  snapshotted so history survives deletion of the catalog Exercise.
//

import Foundation
import SwiftData

@Model
final class LoggedExercise {
    var exerciseName: String
    var weightLb: Double
    var targetReps: Int
    var targetSets: Int
    var sortOrder: Int

    var exercise: Exercise?
    var session: WorkoutSession?

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.loggedExercise)
    var sets: [SetEntry] = []

    init(exerciseName: String,
         weightLb: Double,
         targetReps: Int,
         targetSets: Int,
         sortOrder: Int = 0) {
        self.exerciseName = exerciseName
        self.weightLb = weightLb
        self.targetReps = targetReps
        self.targetSets = targetSets
        self.sortOrder = sortOrder
    }

    var orderedSets: [SetEntry] {
        sets.sorted { $0.setNumber < $1.setNumber }
    }

    /// True when every set is marked complete at or above its target reps.
    var isSuccessful: Bool {
        !sets.isEmpty && sets.allSatisfy { $0.isComplete && $0.completedReps >= $0.targetReps }
    }

    var completedSetCount: Int {
        sets.filter(\.isComplete).count
    }

    var volume: Double {
        sets.reduce(0) { $0 + Double($1.completedReps) * weightLb }
    }
}

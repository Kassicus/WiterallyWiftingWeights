//
//  WorkoutSession.swift
//  WiterallyWiftingWeights
//
//  A single training day containing the exercises performed.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var date: Date
    var notes: String
    /// Set when the user taps "Finish Workout". A session with no finish date
    /// is still in progress.
    var finishedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \LoggedExercise.session)
    var exercises: [LoggedExercise] = []

    init(date: Date = .now, notes: String = "") {
        self.date = date
        self.notes = notes
        self.finishedAt = nil
    }

    var isFinished: Bool { finishedAt != nil }

    var completedSetCount: Int {
        exercises.reduce(0) { $0 + $1.completedSetCount }
    }

    var totalSetCount: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    var orderedExercises: [LoggedExercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// True when every exercise hit all of its target reps.
    var isComplete: Bool {
        !exercises.isEmpty && exercises.allSatisfy { $0.isSuccessful }
    }

    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.volume }
    }
}

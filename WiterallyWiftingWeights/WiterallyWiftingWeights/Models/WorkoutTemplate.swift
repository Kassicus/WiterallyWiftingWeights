//
//  WorkoutTemplate.swift
//  WiterallyWiftingWeights
//
//  A reusable, one-tap workout: an ordered list of exercise names. Names are
//  used (rather than a relationship) so order is preserved trivially; they are
//  resolved against the catalog when a workout is started.
//

import Foundation
import SwiftData

@Model
final class WorkoutTemplate {
    var name: String
    var exerciseNames: [String]
    var sortOrder: Int
    var createdAt: Date

    init(name: String,
         exerciseNames: [String] = [],
         sortOrder: Int = 0,
         createdAt: Date = .now) {
        self.name = name
        self.exerciseNames = exerciseNames
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}

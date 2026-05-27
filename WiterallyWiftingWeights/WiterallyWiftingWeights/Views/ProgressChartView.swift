//
//  ProgressChartView.swift
//  WiterallyWiftingWeights
//
//  Working weight (lb) over time for a chosen exercise.
//

import SwiftUI
import SwiftData
import Charts

struct ProgressChartView: View {
    @Query(sort: \Exercise.sortOrder) private var exercises: [Exercise]
    @State private var selectedName: String = ""

    private var active: [Exercise] { exercises.filter { !$0.isArchived } }

    private var selected: Exercise? {
        active.first { $0.name == selectedName } ?? active.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress").font(.headline)
                Spacer()
                if !active.isEmpty {
                    Picker("Exercise", selection: $selectedName) {
                        ForEach(active) { exercise in
                            Text(exercise.name).tag(exercise.name)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
            }

            chart
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            if selectedName.isEmpty { selectedName = active.first?.name ?? "" }
        }
    }

    @ViewBuilder
    private var chart: some View {
        let points = selected.map(dataPoints) ?? []
        if points.isEmpty {
            Text("Log some workouts to see your progress.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 140)
        } else {
            Chart(points) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Weight", point.weightLb)
                )
                .interpolationMethod(.monotone)
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Weight", point.weightLb)
                )
            }
            .chartYAxisLabel("lb")
            .frame(height: 200)
        }
    }

    private struct Point: Identifiable {
        let id = UUID()
        let date: Date
        let weightLb: Double
    }

    private func dataPoints(for exercise: Exercise) -> [Point] {
        var logged: [LoggedExercise] = exercise.loggedExercises.filter { $0.session != nil }
        logged.sort { lhs, rhs in
            let lhsDate = lhs.session?.date ?? .distantPast
            let rhsDate = rhs.session?.date ?? .distantPast
            return lhsDate < rhsDate
        }
        return logged.compactMap { entry in
            guard let date = entry.session?.date else { return nil }
            return Point(date: date, weightLb: entry.weightLb)
        }
    }
}

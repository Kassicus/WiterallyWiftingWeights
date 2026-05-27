//
//  SessionDetailView.swift
//  WiterallyWiftingWeights
//
//  Read-only summary of a past (or current) workout, opened from the calendar.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Bindable var session: WorkoutSession

    var body: some View {
        NavigationStack {
            List {
                if !session.exercises.isEmpty {
                    Section {
                        LabeledContent("Total weight lifted", value: session.totalVolume.lbString)
                        LabeledContent("Sets completed",
                                       value: "\(session.completedSetCount)/\(session.totalSetCount)")
                    }
                }
                ForEach(session.orderedExercises) { logged in
                    Section(logged.exerciseName) {
                        HStack {
                            Text(logged.weightLb.lbString)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text(logged.isSuccessful
                                 ? "Complete"
                                 : "\(logged.completedSetCount)/\(logged.targetSets) sets")
                                .font(.subheadline)
                                .foregroundStyle(logged.isSuccessful ? .green : .secondary)
                        }
                        HStack(spacing: 8) {
                            ForEach(logged.orderedSets) { set in
                                SetBadge(set: set)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .navigationTitle(session.date.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        context.delete(session)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if session.exercises.isEmpty {
                    ContentUnavailableView("Empty Workout", systemImage: "moon.zzz")
                }
            }
        }
    }
}

private struct SetBadge: View {
    let set: SetEntry

    var body: some View {
        Text("\(set.completedReps)")
            .font(.caption).bold().monospacedDigit()
            .frame(width: 30, height: 30)
            .background(fill, in: Circle())
            .foregroundStyle(.white)
    }

    private var fill: Color {
        guard set.isComplete else { return .gray.opacity(0.4) }
        if set.completedReps >= set.targetReps { return .green }
        if set.completedReps == 0 { return .red }
        return .orange
    }
}

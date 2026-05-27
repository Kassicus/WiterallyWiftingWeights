//
//  WorkoutSummaryView.swift
//  WiterallyWiftingWeights
//
//  Recap shown after finishing a workout: the headline is the total cumulative
//  weight lifted (sum of completed reps × weight across every set).
//

import SwiftUI

struct WorkoutSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    volumeCard
                    statsRow
                    exerciseBreakdown
                }
                .padding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 44))
                .foregroundStyle(.yellow)
            Text("Workout Complete!")
                .font(.title2).bold()
            Text(session.date.formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
    }

    private var volumeCard: some View {
        VStack(spacing: 4) {
            Text(session.totalVolume.lbString)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.tint)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("Total Weight Lifted")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            stat("\(session.completedSetCount)/\(session.totalSetCount)", "Sets")
            stat("\(session.exercises.count)", "Exercises")
            if let duration = durationString {
                stat(duration, "Duration")
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title3.bold()).monospacedDigit()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private var exerciseBreakdown: some View {
        VStack(spacing: 10) {
            ForEach(session.orderedExercises) { logged in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(logged.exerciseName).font(.subheadline.weight(.medium))
                        Text("\(logged.completedSetCount)/\(logged.targetSets) sets · \(logged.weightLb.lbString)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(logged.volume.lbString)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                    if logged.isSuccessful {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var durationString: String? {
        guard let finishedAt = session.finishedAt else { return nil }
        let seconds = finishedAt.timeIntervalSince(session.date)
        guard seconds >= 1 else { return nil }
        let minutes = Int(seconds / 60)
        if minutes < 1 { return "<1m" }
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

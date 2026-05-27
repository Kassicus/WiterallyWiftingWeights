//
//  LoggedExerciseCard.swift
//  WiterallyWiftingWeights
//
//  One exercise on the Today screen: weight control, plate hint, and tappable
//  set chips. Tapping an untouched set logs it at the target reps and starts
//  the rest timer; tapping again counts the reps down (5 → 4 → … → 0 → cleared).
//

import SwiftUI
import SwiftData

struct LoggedExerciseCard: View {
    @Environment(\.modelContext) private var context
    @Environment(RestTimerManager.self) private var timer
    @AppStorage(AppStorageKey.defaultRest) private var defaultRest = 120.0

    @Bindable var loggedExercise: LoggedExercise
    @State private var showingWeight = false

    private var plateSolution: PlateMath.Solution {
        PlateMath.solve(total: loggedExercise.weightLb)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            weightButton
            plateHint
            setRow
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showingWeight) {
            WeightInputSheet(weightLb: $loggedExercise.weightLb)
                .presentationDetents([.medium])
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(loggedExercise.exerciseName).font(.headline)
                Text("\(loggedExercise.targetSets) × \(loggedExercise.targetReps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if loggedExercise.isSuccessful {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
            Menu {
                Button(role: .destructive) {
                    context.delete(loggedExercise)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .padding(.leading, 6)
            }
        }
    }

    private var weightButton: some View {
        Button {
            showingWeight = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "scalemass")
                Text(loggedExercise.weightLb.lbString)
                Image(systemName: "pencil").font(.caption2)
            }
            .font(.subheadline.weight(.medium))
        }
        .buttonStyle(.bordered)
    }

    private var plateHint: some View {
        Label(plateSolution.summary, systemImage: "circle.hexagongrid")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var setRow: some View {
        HStack(spacing: 10) {
            ForEach(loggedExercise.orderedSets) { set in
                SetChip(entry: set) { tapped(set) }
            }
            Spacer(minLength: 0)
        }
    }

    private func tapped(_ set: SetEntry) {
        if !set.isComplete {
            set.isComplete = true
            set.completedReps = set.targetReps
            Haptics.rigid()
            timer.start(defaultRest)
        } else if set.completedReps > 0 {
            set.completedReps -= 1
            Haptics.light()
        } else {
            set.isComplete = false
            set.completedReps = 0
            Haptics.light()
        }
    }
}

private struct SetChip: View {
    let entry: SetEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title3).bold().monospacedDigit()
                .frame(width: 46, height: 46)
                .background(fill, in: Circle())
                .foregroundStyle(entry.isComplete ? .white : .secondary)
                .overlay {
                    if !entry.isComplete {
                        Circle().strokeBorder(.tertiary, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var label: String {
        entry.isComplete ? "\(entry.completedReps)" : "\(entry.targetReps)"
    }

    private var fill: Color {
        guard entry.isComplete else { return .clear }
        if entry.completedReps >= entry.targetReps { return .green }
        if entry.completedReps == 0 { return .red }
        return .orange
    }
}

private struct WeightInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var weightLb: Double

    @State private var value = 0.0

    private var solution: PlateMath.Solution { PlateMath.solve(total: value) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 24) {
                    Button {
                        value = max(0, value - 5)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                    }

                    TextField("Weight", value: $value, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .frame(maxWidth: 150)

                    Button {
                        value += 5
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .font(.largeTitle)
                .foregroundStyle(.tint)

                Text("lb").foregroundStyle(.secondary)

                PlateBarbellView(solution: solution)
                    .padding(.top, 8)

                Spacer()
            }
            .padding(.top, 28)
            .navigationTitle("Set Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        weightLb = max(0, value)
                        dismiss()
                    }
                }
            }
            .onAppear { value = weightLb }
        }
    }
}

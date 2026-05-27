//
//  ExerciseEditView.swift
//  WiterallyWiftingWeights
//
//  Create or edit a catalog exercise. All weights are in pounds.
//

import SwiftUI
import SwiftData

struct ExerciseEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    /// nil when creating a new exercise.
    let exercise: Exercise?

    @State private var name = ""
    @State private var notes = ""
    @State private var weight = PlateMath.barWeight
    @State private var increment = 5.0
    @State private var sets = 5
    @State private var reps = 5

    private var isNew: Bool { exercise == nil }
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name", text: $name)
                    TextField("Notes", text: $notes, axis: .vertical)
                }
                Section("Targets") {
                    Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                    Stepper("Reps: \(reps)", value: $reps, in: 1...20)
                }
                Section("Weight (lb)") {
                    LabeledContent("Starting weight") {
                        numberField($weight)
                    }
                    LabeledContent("Increment") {
                        numberField($increment)
                    }
                }
            }
            .navigationTitle(isNew ? "New Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func numberField(_ binding: Binding<Double>) -> some View {
        TextField("0", value: binding, format: .number)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 90)
    }

    private func load() {
        guard let exercise else { return }
        name = exercise.name
        notes = exercise.notes
        sets = exercise.targetSets
        reps = exercise.targetReps
        weight = exercise.defaultWeightLb
        increment = exercise.incrementLb
    }

    private func save() {
        if let exercise {
            exercise.name = trimmedName
            exercise.notes = notes
            exercise.targetSets = sets
            exercise.targetReps = reps
            exercise.defaultWeightLb = weight
            exercise.incrementLb = increment
        } else {
            let order = (try? context.fetchCount(FetchDescriptor<Exercise>())) ?? 0
            context.insert(
                Exercise(name: trimmedName,
                         notes: notes,
                         defaultWeightLb: weight,
                         incrementLb: increment,
                         targetSets: sets,
                         targetReps: reps,
                         sortOrder: order)
            )
        }
        dismiss()
    }
}

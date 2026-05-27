//
//  WorkoutTemplateEditView.swift
//  WiterallyWiftingWeights
//
//  Create or edit a custom workout template by choosing exercises in order.
//

import SwiftUI
import SwiftData

struct WorkoutTemplateEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.sortOrder) private var allExercises: [Exercise]

    /// nil when creating a new template.
    let template: WorkoutTemplate?

    @State private var name = ""
    @State private var exerciseNames: [String] = []

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var availableExercises: [Exercise] {
        allExercises.filter { !$0.isArchived && !exerciseNames.contains($0.name) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Workout name", text: $name)
                }

                Section {
                    if exerciseNames.isEmpty {
                        Text("No exercises yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(exerciseNames, id: \.self) { exerciseName in
                            Text(exerciseName)
                        }
                        .onDelete { exerciseNames.remove(atOffsets: $0) }
                        .onMove { exerciseNames.move(fromOffsets: $0, toOffset: $1) }
                    }
                } header: {
                    Text("Exercises")
                } footer: {
                    Text("Tap to reorder in edit mode. They'll be added in this order.")
                }

                Section {
                    Menu {
                        if availableExercises.isEmpty {
                            Text("All exercises added")
                        } else {
                            ForEach(availableExercises) { exercise in
                                Button(exercise.name) { exerciseNames.append(exercise.name) }
                            }
                        }
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle")
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle(template == nil ? "New Workout" : "Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(trimmedName.isEmpty || exerciseNames.isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let template else { return }
        name = template.name
        exerciseNames = template.exerciseNames
    }

    private func save() {
        if let template {
            template.name = trimmedName
            template.exerciseNames = exerciseNames
        } else {
            let order = (try? context.fetchCount(FetchDescriptor<WorkoutTemplate>())) ?? 0
            context.insert(
                WorkoutTemplate(name: trimmedName,
                                exerciseNames: exerciseNames,
                                sortOrder: order)
            )
        }
        dismiss()
    }
}

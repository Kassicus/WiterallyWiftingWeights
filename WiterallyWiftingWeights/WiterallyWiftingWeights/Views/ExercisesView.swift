//
//  ExercisesView.swift
//  WiterallyWiftingWeights
//

import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Exercise.sortOrder) private var exercises: [Exercise]

    @State private var editing: Exercise?
    @State private var showingNew = false

    private var active: [Exercise] { exercises.filter { !$0.isArchived } }

    var body: some View {
        NavigationStack {
            List {
                ForEach(active) { exercise in
                    Button {
                        editing = exercise
                    } label: {
                        row(for: exercise)
                    }
                    .tint(.primary)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if active.isEmpty {
                    ContentUnavailableView("No Exercises",
                                           systemImage: "dumbbell",
                                           description: Text("Tap + to add your first exercise."))
                }
            }
            .sheet(item: $editing) { ExerciseEditView(exercise: $0) }
            .sheet(isPresented: $showingNew) { ExerciseEditView(exercise: nil) }
        }
    }

    private func row(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name).font(.headline)
            Text("\(exercise.targetSets) × \(exercise.targetReps)  ·  \(exercise.defaultWeightLb.lbString)  ·  +\(exercise.incrementLb.lbString)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            context.delete(active[index])
        }
    }

    private func move(_ offsets: IndexSet, _ destination: Int) {
        var items = active
        items.move(fromOffsets: offsets, toOffset: destination)
        for (index, exercise) in items.enumerated() {
            exercise.sortOrder = index
        }
    }
}

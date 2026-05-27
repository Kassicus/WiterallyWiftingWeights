//
//  WorkoutTemplatesView.swift
//  WiterallyWiftingWeights
//
//  Manage reusable workout templates (the A/B starters plus any custom ones).
//

import SwiftUI
import SwiftData

struct WorkoutTemplatesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutTemplate.sortOrder) private var templates: [WorkoutTemplate]

    @State private var editing: WorkoutTemplate?
    @State private var showingNew = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(templates) { template in
                    Button {
                        editing = template
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name).font(.headline)
                            Text(template.exerciseNames.isEmpty
                                 ? "No exercises"
                                 : template.exerciseNames.joined(separator: " · "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .tint(.primary)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNew = true } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if templates.isEmpty {
                    ContentUnavailableView("No Workouts",
                                           systemImage: "square.stack.3d.up",
                                           description: Text("Tap + to create a workout template."))
                }
            }
            .sheet(item: $editing) { WorkoutTemplateEditView(template: $0) }
            .sheet(isPresented: $showingNew) { WorkoutTemplateEditView(template: nil) }
        }
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            context.delete(templates[index])
        }
    }

    private func move(_ offsets: IndexSet, _ destination: Int) {
        var items = templates
        items.move(fromOffsets: offsets, toOffset: destination)
        for (index, template) in items.enumerated() {
            template.sortOrder = index
        }
    }
}

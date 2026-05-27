//
//  TodayView.swift
//  WiterallyWiftingWeights
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Environment(RestTimerManager.self) private var timer
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \Exercise.sortOrder) private var allExercises: [Exercise]
    @Query(sort: \WorkoutTemplate.sortOrder) private var templates: [WorkoutTemplate]

    @State private var showingTemplates = false
    @State private var confirmFinish = false
    @State private var confirmDiscard = false
    @State private var summarySession: WorkoutSession?

    /// Today's in-progress workout (started but not yet finished).
    private var activeSession: WorkoutSession? {
        sessions.first { Calendar.current.isDateInToday($0.date) && !$0.isFinished }
    }

    /// The most recently finished workout, used for repeat / suggestions.
    private var lastWorkout: WorkoutSession? {
        sessions.first { $0.isFinished }
    }

    private var availableExercises: [Exercise] {
        let used = Set(activeSession?.exercises.compactMap { $0.exercise?.persistentModelID } ?? [])
        return allExercises.filter { !$0.isArchived && !used.contains($0.persistentModelID) }
    }

    /// The template to nudge next: the one after whatever was done last,
    /// cycling through the list (so A/B alternates).
    private var suggestedTemplate: WorkoutTemplate? {
        guard !templates.isEmpty else { return nil }
        guard let lastWorkout else { return templates.first }
        let lastNames = Set(lastWorkout.orderedExercises.map(\.exerciseName))
        if let index = templates.firstIndex(where: { Set($0.exerciseNames) == lastNames }) {
            return templates[(index + 1) % templates.count]
        }
        return templates.first
    }

    var body: some View {
        NavigationStack {
            Group {
                if let session = activeSession {
                    sessionContent(session)
                } else {
                    startScreen
                }
            }
            .navigationTitle("Today")
            .toolbar {
                if let session = activeSession {
                    ToolbarItem(placement: .topBarTrailing) {
                        addMenu(for: session)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                confirmDiscard = true
                            } label: {
                                Label("Discard Workout", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .confirmationDialog("Discard this workout?",
                                            isPresented: $confirmDiscard,
                                            titleVisibility: .visible) {
                            Button("Discard Workout", role: .destructive) { discard(session) }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This deletes the workout without saving it.")
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingTemplates = true
                        } label: {
                            Image(systemName: "square.stack.3d.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTemplates) {
                WorkoutTemplatesView()
            }
            .sheet(item: $summarySession) { session in
                WorkoutSummaryView(session: session)
            }
        }
    }

    // MARK: - Active session

    private func sessionContent(_ session: WorkoutSession) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(session.date.formatted(date: .complete, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(session.orderedExercises) { logged in
                    LoggedExerciseCard(loggedExercise: logged)
                }

                if session.exercises.isEmpty {
                    ContentUnavailableView {
                        Label("No exercises yet", systemImage: "dumbbell")
                    } description: {
                        Text("Tap + to add exercises to today's workout.")
                    }
                    .padding(.top, 40)
                } else {
                    finishButton(session)
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
    }

    private func finishButton(_ session: WorkoutSession) -> some View {
        Button {
            confirmFinish = true
        } label: {
            Label("Finish Workout", systemImage: "checkmark.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.top, 8)
        .confirmationDialog("Finish this workout?",
                            isPresented: $confirmFinish,
                            titleVisibility: .visible) {
            Button("Finish Workout") { finish(session) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(session.completedSetCount) of \(session.totalSetCount) sets logged.")
        }
    }

    private func addMenu(for session: WorkoutSession) -> some View {
        Menu {
            if availableExercises.isEmpty {
                Text("All exercises added")
            } else {
                ForEach(availableExercises) { exercise in
                    Button(exercise.name) {
                        WorkoutBuilder.addExercise(exercise, to: session, context: context)
                        Haptics.light()
                    }
                }
            }
        } label: {
            Image(systemName: "plus")
        }
    }

    // MARK: - Start screen

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.tint)
                    Text("Ready to lift?")
                        .font(.title2).bold()
                    Text(lastWorkout == nil ? "Pick a workout to start." : "Pick up where you left off.")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 8)

                ForEach(templates) { template in
                    templateCard(template)
                }

                Button {
                    startWorkout(repeating: false)
                } label: {
                    Label("Start Empty Workout", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                if lastWorkout != nil {
                    Button {
                        startWorkout(repeating: true)
                    } label: {
                        Label("Repeat Last Workout", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button {
                    showingTemplates = true
                } label: {
                    Text("Manage Workouts")
                        .font(.subheadline)
                }
                .padding(.top, 4)
            }
            .padding()
        }
    }

    private func templateCard(_ template: WorkoutTemplate) -> some View {
        let isSuggested = template.persistentModelID == suggestedTemplate?.persistentModelID
        return Button {
            startTemplate(template)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(template.name).font(.headline)
                        if isSuggested {
                            Text("UP NEXT")
                                .font(.caption2).bold()
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.accentColor, in: Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                    Text(template.exerciseNames.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                if isSuggested {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.accentColor, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func finish(_ session: WorkoutSession) {
        session.finishedAt = .now
        if timer.isRunning { timer.skip() }
        Haptics.success()
        summarySession = session
    }

    private func discard(_ session: WorkoutSession) {
        if timer.isRunning { timer.skip() }
        context.delete(session)
        Haptics.light()
    }

    private func startTemplate(_ template: WorkoutTemplate) {
        let session = WorkoutSession(date: .now)
        context.insert(session)
        for name in template.exerciseNames {
            if let exercise = exercise(named: name) {
                WorkoutBuilder.addExercise(exercise, to: session, context: context)
            }
        }
        Haptics.light()
    }

    private func startWorkout(repeating: Bool) {
        let session = WorkoutSession(date: .now)
        context.insert(session)
        if repeating, let lastWorkout {
            for logged in lastWorkout.orderedExercises {
                if let exercise = logged.exercise ?? exercise(named: logged.exerciseName) {
                    WorkoutBuilder.addExercise(exercise, to: session, context: context)
                }
            }
        }
        Haptics.light()
    }

    private func exercise(named name: String) -> Exercise? {
        allExercises.first { !$0.isArchived && $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }
}

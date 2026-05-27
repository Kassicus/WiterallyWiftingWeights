//
//  CalendarView.swift
//  WiterallyWiftingWeights
//
//  Month grid marking workout days, plus a per-exercise progress chart.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @State private var month = Date()
    @State private var selectedSession: WorkoutSession?

    private let calendar = Calendar.current

    private var workoutDays: [Date: WorkoutSession] {
        var map: [Date: WorkoutSession] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.date)
            if map[day] == nil { map[day] = session }
        }
        return map
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    MonthCalendar(month: $month, workoutDays: workoutDays) { session in
                        selectedSession = session
                    }
                    ProgressChartView()
                }
                .padding()
            }
            .navigationTitle("Progress")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }
}

private struct MonthCalendar: View {
    @Binding var month: Date
    let workoutDays: [Date: WorkoutSession]
    let onSelect: (WorkoutSession) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 14) {
            header
            weekdayRow
            grid
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var header: some View {
        HStack {
            Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
            Spacer()
            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            Spacer()
            Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
        }
        .buttonStyle(.borderless)
    }

    private var weekdayRow: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let day {
                    let session = workoutDays[calendar.startOfDay(for: day)]
                    DayCell(date: day,
                            hasWorkout: session != nil,
                            isToday: calendar.isDateInToday(day))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let session { onSelect(session) }
                        }
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    /// Days for the visible month, padded with leading/trailing blanks so the
    /// grid aligns to weeks.
    private var days: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7
        let dayCount = calendar.range(of: .day, in: .month, for: month)?.count ?? 0

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<dayCount {
            result.append(calendar.date(byAdding: .day, value: offset, to: firstDay))
        }
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }

    private func changeMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: month) {
            month = newMonth
        }
    }
}

private struct DayCell: View {
    let date: Date
    let hasWorkout: Bool
    let isToday: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.callout)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isToday ? Color.accentColor : .primary)
            Circle()
                .fill(hasWorkout ? Color.accentColor : .clear)
                .frame(width: 6, height: 6)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

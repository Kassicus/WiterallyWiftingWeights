//
//  RestTimerBar.swift
//  WiterallyWiftingWeights
//
//  Floating rest-timer control shown above the tab bar while a timer runs.
//

import SwiftUI

struct RestTimerBar: View {
    @Environment(RestTimerManager.self) private var timer

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.25), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 0) {
                Text("REST")
                    .font(.caption2).bold()
                    .foregroundStyle(.white.opacity(0.85))
                Text(timeString)
                    .font(.title3).bold().monospacedDigit()
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 8)

            Button("−15") { timer.adjust(by: -15) }
            Button("+15") { timer.adjust(by: 15) }
            Button {
                timer.skip()
            } label: {
                Image(systemName: "forward.end.fill")
            }
        }
        .font(.subheadline.bold())
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.accentColor, in: Capsule())
        .foregroundStyle(.white)
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
    }

    private var timeString: String {
        let total = Int(timer.remaining.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

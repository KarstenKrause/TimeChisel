//
//  WeekScheduleEditor.swift
//  TimeChisel
//
//  Created by Karsten Krause on 05.07.26.
//

import SwiftUI

/// Formular-Editor für die Soll-Zeiten pro Wochentag bei festen Arbeitszeiten.
/// Pro Tag: aktiv/inaktiv, Beginn, Ende sowie eine feste Pause (Beginn + Dauer).
struct WeekScheduleEditor: View {
    @Binding var weekSchedule: [DaySchedule]

    let pauseSelection: [Int] = [15, 30, 45, 60]

    /// Wochenreihenfolge Mo…So als `Calendar.weekday`-Werte (1 = Sonntag).
    private static let weekdayOrder = [2, 3, 4, 5, 6, 7, 1]

    var body: some View {
        ForEach(Self.weekdayOrder, id: \.self) { weekday in
            Toggle(Self.weekdayName(for: weekday), isOn: isActiveBinding(for: weekday))

            if let day = dayBinding(for: weekday) {
                Group {
                    DatePicker("Beginn", selection: timeBinding(day.startMinuteOfDay), displayedComponents: .hourAndMinute)
                    DatePicker("Ende", selection: timeBinding(day.endMinuteOfDay), displayedComponents: .hourAndMinute)
                    DatePicker("Pausenbeginn", selection: timeBinding(pauseStartBinding(for: day)), displayedComponents: .hourAndMinute)

                    Picker("Pausendauer", selection: pauseDurationBinding(for: day)) {
                        ForEach(pauseSelection, id: \.self) { minutes in
                            Text("\(minutes) Minuten").tag(minutes)
                        }
                    }
                }
                .padding(.leading)
            }
        }
    }

    private static func weekdayName(for weekday: Int) -> String {
        Calendar.current.weekdaySymbols[weekday - 1]
    }

    /// Neuer Arbeitstag mit üblichen Standardwerten: 8:00–16:30, Pause 12:00 für 30 Minuten.
    private static func defaultDay(for weekday: Int) -> DaySchedule {
        DaySchedule(
            weekday: weekday,
            startMinuteOfDay: 8 * 60,
            endMinuteOfDay: 16 * 60 + 30,
            pauses: [ScheduledPause(startMinuteOfDay: 12 * 60, durationMinutes: 30)]
        )
    }

    private func isActiveBinding(for weekday: Int) -> Binding<Bool> {
        Binding(
            get: { weekSchedule.contains { $0.weekday == weekday } },
            set: { isActive in
                if isActive {
                    guard !weekSchedule.contains(where: { $0.weekday == weekday }) else { return }
                    weekSchedule.append(Self.defaultDay(for: weekday))
                } else {
                    weekSchedule.removeAll { $0.weekday == weekday }
                }
            }
        )
    }

    private func dayBinding(for weekday: Int) -> Binding<DaySchedule>? {
        guard weekSchedule.contains(where: { $0.weekday == weekday }) else { return nil }

        return Binding(
            get: {
                weekSchedule.first { $0.weekday == weekday } ?? Self.defaultDay(for: weekday)
            },
            set: { newValue in
                guard let index = weekSchedule.firstIndex(where: { $0.weekday == weekday }) else { return }
                weekSchedule[index] = newValue
            }
        )
    }

    private func pauseStartBinding(for day: Binding<DaySchedule>) -> Binding<Int> {
        Binding(
            get: { day.wrappedValue.pauses.first?.startMinuteOfDay ?? 12 * 60 },
            set: { newValue in
                if day.wrappedValue.pauses.isEmpty {
                    day.wrappedValue.pauses = [ScheduledPause(startMinuteOfDay: newValue, durationMinutes: 30)]
                } else {
                    day.wrappedValue.pauses[0].startMinuteOfDay = newValue
                }
            }
        )
    }

    private func pauseDurationBinding(for day: Binding<DaySchedule>) -> Binding<Int> {
        Binding(
            get: { day.wrappedValue.pauses.first?.durationMinutes ?? 30 },
            set: { newValue in
                if day.wrappedValue.pauses.isEmpty {
                    day.wrappedValue.pauses = [ScheduledPause(startMinuteOfDay: 12 * 60, durationMinutes: newValue)]
                } else {
                    day.wrappedValue.pauses[0].durationMinutes = newValue
                }
            }
        )
    }

    /// Übersetzt Minuten seit Mitternacht in eine Uhrzeit am heutigen Tag und zurück,
    /// damit `DatePicker` damit arbeiten kann.
    private func timeBinding(_ minuteOfDay: Binding<Int>) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.startOfDay(for: .now).addingTimeInterval(TimeInterval(minuteOfDay.wrappedValue * 60))
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                minuteOfDay.wrappedValue = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            }
        )
    }
}

#Preview {
    @Previewable @State var weekSchedule: [DaySchedule] = []

    Form {
        Section("Arbeitszeiten") {
            WeekScheduleEditor(weekSchedule: $weekSchedule)
        }
    }
}

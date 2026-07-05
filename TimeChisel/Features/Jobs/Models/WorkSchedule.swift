//
//  WorkSchedule.swift
//  TimeChisel
//
//  Created by Karsten Krause on 05.07.26.
//

import Foundation

/// Arbeitsmodell eines Jobs.
enum WorkScheduleType: String, Codable, CaseIterable {
    /// Vertrauensgleitzeit: Wochensoll gleichmäßig auf die Arbeitstage verteilt, Pausen frei wählbar.
    case flexible
    /// Feste Arbeitszeiten: Soll-Zeiten pro Wochentag mit festen Pausenzeiten.
    case fixed

    var displayName: String {
        switch self {
        case .flexible: return "Vertrauensgleitzeit"
        case .fixed: return "Feste Arbeitszeiten"
        }
    }
}

/// Eine fest geplante Pause innerhalb eines Arbeitstags.
struct ScheduledPause: Codable, Equatable {
    /// Soll-Beginn als Minuten seit Mitternacht (12:00 Uhr → 720).
    /// Minuten statt `Date`, damit der Plan datumsunabhängig ist.
    var startMinuteOfDay: Int
    var durationMinutes: Int

    /// Konkreter Soll-Beginn an einem bestimmten Tag.
    func start(on day: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: day).addingTimeInterval(TimeInterval(startMinuteOfDay * 60))
    }
}

/// Soll-Arbeitszeiten für einen Wochentag bei festen Arbeitszeiten.
struct DaySchedule: Codable, Equatable {
    /// Wochentag nach `Calendar.component(.weekday)`: 1 = Sonntag … 7 = Samstag.
    var weekday: Int
    /// Soll-Beginn als Minuten seit Mitternacht.
    var startMinuteOfDay: Int
    /// Soll-Ende als Minuten seit Mitternacht.
    var endMinuteOfDay: Int
    var pauses: [ScheduledPause]

    var pauseMinutes: Int {
        pauses.reduce(0) { $0 + $1.durationMinutes }
    }

    /// Netto-Tagessoll in Sekunden: Anwesenheit minus geplante Pausen.
    var targetWorkingSeconds: Int {
        max(0, endMinuteOfDay - startMinuteOfDay - pauseMinutes) * 60
    }
}

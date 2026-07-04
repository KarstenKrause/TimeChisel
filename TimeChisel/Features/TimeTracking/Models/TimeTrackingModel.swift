//
//  TimeTrackingModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 30.06.24.
//

import Foundation
import SwiftData

@Model
class TimeTrackingModel {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var pauses: [Pause]
    var income: Money?
    var job: JobModel?

    init(startDate: Date = .now) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = nil
        self.pauses = []
        self.income = nil
        self.job = nil
    }
}

// MARK: - Abgeleiteter Zustand

extension TimeTrackingModel {
    var isRunning: Bool {
        endDate == nil
    }

    var isPausing: Bool {
        isRunning && pauses.last?.end == nil && !pauses.isEmpty
    }

    /// Summe aller Pausen in Sekunden (laufende Pause bis `now`).
    func pausedSeconds(asOf now: Date = .now) -> Int {
        Int(pauses.reduce(0) { $0 + $1.duration(asOf: now) })
    }

    /// Effektive Arbeitszeit in Sekunden: (Ende − Start) − Summe der Pausen.
    func workedSeconds(asOf now: Date = .now) -> Int {
        let end = endDate ?? now
        let grossSeconds = Int(end.timeIntervalSince(startDate))
        return grossSeconds - pausedSeconds(asOf: now)
    }

    /// Arbeitszeit inkl. Überstunden gegen die Soll-Zeiten des Jobs.
    /// Zu lange Pausen (über das Tagessoll hinaus) sind bereits über `workedSeconds` abgezogen.
    var workingTime: WorkingTime {
        let worked = workedSeconds()
        let (hours, minutes) = worked.toHoursAndMinutes()

        let targetWorkingSeconds = Int((job?.workingHoursPerDay ?? 0) * 3600)
        let overtimeSeconds = worked - targetWorkingSeconds

        return WorkingTime(
            hours: hours,
            minutes: minutes,
            overtime: Overtime(seconds: overtimeSeconds)
        )
    }
}

// MARK: - Session-Ereignisse

extension TimeTrackingModel {
    /// Startet eine neue Pause. Ohne Wirkung, wenn bereits pausiert wird.
    func startPause(at date: Date = .now) {
        guard !isPausing else { return }
        pauses.append(Pause(start: date, end: nil))
    }

    /// Beendet die laufende Pause. Ohne Wirkung, wenn keine Pause läuft.
    func resumeWork(at date: Date = .now) {
        guard isPausing, let lastIndex = pauses.indices.last else { return }
        pauses[lastIndex].end = date
    }

    /// Schließt die Session ab: offene Pause beenden, Enddatum setzen und Verdienst snapshotten.
    func finish(hourlyRate: Money, at date: Date = .now) {
        resumeWork(at: date)
        endDate = date

        let totalHours = Double(workedSeconds()) / 3600.0
        let incomeValue = (totalHours * hourlyRate.value).rounded(toPlaces: 2)
        income = Money(value: incomeValue, currency: hourlyRate.currency)
    }
}

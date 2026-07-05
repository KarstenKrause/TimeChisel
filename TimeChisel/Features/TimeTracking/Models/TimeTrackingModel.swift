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
}

// MARK: - Feste Pausenzeiten

extension TimeTrackingModel {
    /// Karenzzeit um den Soll-Pausenbeginn: manuelles Einchecken frühestens so viele
    /// Minuten davor, automatischer Start so viele Minuten danach.
    static let scheduledPauseGraceMinutes = 10

    private static var scheduledPauseGrace: TimeInterval {
        TimeInterval(scheduledPauseGraceMinutes * 60)
    }

    /// Trägt bei festen Arbeitszeiten überfällige geplante Pausen rückwirkend nach und
    /// beendet laufende automatische Pausen nach Ablauf ihrer Soll-Dauer. Idempotent —
    /// gedacht für wiederholte Aufrufe (UI-Tick, App-Foreground, Session-Ende).
    func applyScheduledPauses(asOf now: Date = .now) {
        guard let schedule = job?.daySchedule(for: startDate) else { return }

        let sessionEnd = endDate ?? now

        for scheduled in schedule.pauses {
            let plannedStart = scheduled.start(on: startDate)
            let windowStart = plannedStart.addingTimeInterval(-Self.scheduledPauseGrace)
            let autoStart = plannedStart.addingTimeInterval(Self.scheduledPauseGrace)
            let duration = TimeInterval(scheduled.durationMinutes * 60)

            if let index = pauses.firstIndex(where: { $0.start >= windowStart && $0.start <= autoStart }) {
                // Slot ist bereits belegt. Laufende automatische Pausen nach Soll-Dauer beenden.
                if pauses[index].source == .automatic, pauses[index].end == nil {
                    let plannedEnd = pauses[index].start.addingTimeInterval(duration)
                    if now >= plannedEnd {
                        pauses[index].end = min(plannedEnd, sessionEnd)
                    }
                }
                continue
            }

            // Kein Check-in bis zum Ende des Fensters → Pause startet automatisch,
            // sofern die Session zu diesem Zeitpunkt lief.
            guard now >= autoStart, autoStart >= startDate, autoStart < sessionEnd else { continue }

            let plannedEnd = autoStart.addingTimeInterval(duration)
            let end: Date? = now >= plannedEnd ? min(plannedEnd, sessionEnd) : nil
            pauses.append(Pause(start: autoStart, end: end, source: .automatic))
        }
    }

    /// Bei festen Arbeitszeiten darf eine Pause nur im Fenster um einen noch nicht
    /// genommenen Soll-Pausenbeginn manuell gestartet werden. Bei Vertrauensgleitzeit
    /// und an Tagen ohne Tagesplan (z. B. Wochenendarbeit) sind Pausen jederzeit erlaubt.
    func canStartManualPause(asOf now: Date = .now) -> Bool {
        guard let job, job.scheduleType == .fixed else { return true }
        guard let schedule = job.daySchedule(for: startDate) else { return true }

        return schedule.pauses.contains { scheduled in
            let plannedStart = scheduled.start(on: startDate)
            let window = plannedStart.addingTimeInterval(-Self.scheduledPauseGrace)...plannedStart.addingTimeInterval(Self.scheduledPauseGrace)
            let alreadyTaken = pauses.contains { window.contains($0.start) }
            return !alreadyTaken && window.contains(now)
        }
    }
}

// MARK: - Session-Ereignisse

extension TimeTrackingModel {
    /// Startet eine neue Pause. Ohne Wirkung, wenn bereits pausiert wird oder
    /// das Arbeitsmodell gerade keine manuelle Pause zulässt.
    func startPause(at date: Date = .now) {
        guard !isPausing, canStartManualPause(asOf: date) else { return }
        pauses.append(Pause(start: date, end: nil))
    }

    /// Beendet die laufende Pause. Ohne Wirkung, wenn keine Pause läuft.
    func resumeWork(at date: Date = .now) {
        guard isPausing, let lastIndex = pauses.indices.last else { return }
        pauses[lastIndex].end = date
    }

    /// Schließt die Session ab: überfällige geplante Pausen nachtragen, offene Pause
    /// beenden, Enddatum setzen und Verdienst snapshotten.
    func finish(hourlyRate: Money, at date: Date = .now) {
        applyScheduledPauses(asOf: date)
        resumeWork(at: date)
        endDate = date

        let totalHours = Double(workedSeconds()) / 3600.0
        let incomeValue = (totalHours * hourlyRate.value).rounded(toPlaces: 2)
        income = Money(value: incomeValue, currency: hourlyRate.currency)
    }
}

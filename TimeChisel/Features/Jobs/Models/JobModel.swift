//
//  JobModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 09.02.24.
//

import Foundation
import SwiftData

@Model
class JobModel {
    @Attribute(.unique) var id: UUID
    var companyName: String
    var jobTitle: String
    var scheduleType: WorkScheduleType
    var workingHoursPerWeek: Int
    var workingDaysPerWeek: Int
    var pauseMinutesPerDay: Int
    /// Soll-Zeiten pro Wochentag — nur bei festen Arbeitszeiten (`scheduleType == .fixed`) befüllt.
    var weekSchedule: [DaySchedule]
    var hourlyRate: Money
    @Relationship(deleteRule: .cascade, inverse: \TimeTrackingModel.job) var timeTrackings: [TimeTrackingModel]

    var workingHoursPerDay: Double {
        Double(workingHoursPerWeek) / Double(workingDaysPerWeek)
    }

    init(companyName: String,
         jobTitle: String,
         scheduleType: WorkScheduleType = .flexible,
         workingHoursPerWeek: Int,
         workingDaysPerWeek: Int,
         pauseMinutesPerDay: Int,
         weekSchedule: [DaySchedule] = [],
         hourlyRate: Money) {
        self.id = UUID()
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.scheduleType = scheduleType
        self.workingHoursPerWeek = workingHoursPerWeek
        self.workingDaysPerWeek = workingDaysPerWeek
        self.pauseMinutesPerDay = pauseMinutesPerDay
        self.weekSchedule = weekSchedule
        self.hourlyRate = hourlyRate
        self.timeTrackings = []
    }
}

// MARK: - Soll-Zeiten

extension JobModel {
    /// Der Soll-Zeitplan für den Wochentag des übergebenen Datums — nur bei festen Arbeitszeiten.
    func daySchedule(for date: Date, calendar: Calendar = .current) -> DaySchedule? {
        guard scheduleType == .fixed else { return nil }
        let weekday = calendar.component(.weekday, from: date)
        return weekSchedule.first { $0.weekday == weekday }
    }

    /// Netto-Tagessoll in Sekunden für einen konkreten Tag.
    /// Vertrauensgleitzeit: Wochensoll gleichmäßig verteilt. Feste Arbeitszeiten:
    /// Soll des Wochentags, 0 an freien Tagen.
    func dailyTargetSeconds(for date: Date) -> Int {
        switch scheduleType {
        case .flexible:
            return Int(workingHoursPerDay * 3600)
        case .fixed:
            return daySchedule(for: date)?.targetWorkingSeconds ?? 0
        }
    }
}


/// Arbeitszeit und Überstunden eines Kalendertags über alle Sessions dieses Tags.
struct WorkDaySummary {
    let day: Date
    let workedSeconds: Int
    let overtimeSeconds: Int
}

extension JobModel {
    /// Nur abgeschlossene Sessions (mit Enddatum) fließen in die Gesamtsummen ein.
    private var completedTrackings: [TimeTrackingModel] {
        timeTrackings.filter { !$0.isRunning }
    }

    /// Abgeschlossene Sessions gruppiert nach Kalendertag (Tag des Session-Starts).
    /// Überstunden werden pro Tag gegen das Tagessoll gerechnet — nicht pro Session,
    /// damit mehrere Sessions am selben Tag das Soll nur einmal abziehen.
    var workDaySummaries: [WorkDaySummary] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: completedTrackings) { calendar.startOfDay(for: $0.startDate) }

        return byDay.map { day, trackings in
            let worked = trackings.reduce(0) { $0 + $1.workedSeconds() }
            return WorkDaySummary(
                day: day,
                workedSeconds: worked,
                overtimeSeconds: worked - dailyTargetSeconds(for: day)
            )
        }
        .sorted { $0.day < $1.day }
    }

    var totalWorkingTime: WorkingTime {
        let summaries = workDaySummaries
        let worked = summaries.reduce(0) { $0 + $1.workedSeconds }.toHoursAndMinutes()
        let overtimeSeconds = summaries.reduce(0) { $0 + $1.overtimeSeconds }

        return WorkingTime(
            hours: worked.hours,
            minutes: worked.minutes,
            overtime: Overtime(seconds: overtimeSeconds)
        )
    }

    var totalIncome: Money {
        let total = completedTrackings.reduce(0.0) { $0 + ($1.income?.value ?? 0) }
        return Money(value: total.rounded(toPlaces: 2), currency: hourlyRate.currency)
    }
}

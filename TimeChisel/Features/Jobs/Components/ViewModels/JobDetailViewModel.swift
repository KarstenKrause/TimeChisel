//
//  JobDetailViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 22.07.24.
//

import Foundation
import Observation

/// Wählbarer Zeitraum des Job-Dashboards.
enum DashboardPeriod: String, CaseIterable {
    case week
    case month
    case year

    var displayName: String {
        switch self {
        case .week: return "Woche"
        case .month: return "Monat"
        case .year: return "Jahr"
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        }
    }

    /// Bezeichnung der Vorperiode für das Delta-Label.
    var previousPeriodLabel: String {
        switch self {
        case .week: return "Vorwoche"
        case .month: return "Vormonat"
        case .year: return "Vorjahr"
        }
    }
}

/// Aggregierte Kennzahlen eines Zeitraums.
struct PeriodMetrics {
    var workedSeconds = 0
    var overtimeSeconds = 0
    var workDays = 0
    var manualPauseSeconds = 0
    var automaticPauseSeconds = 0
    var income: Money

    var totalPauseSeconds: Int {
        manualPauseSeconds + automaticPauseSeconds
    }

    var averageSecondsPerWorkDay: Int {
        workDays > 0 ? workedSeconds / workDays : 0
    }

    /// Durchschnittliches Tagessoll der getrackten Arbeitstage
    /// (Soll je Tag = Ist − Überstunden, daher ohne weitere Modelldaten herleitbar).
    var averageTargetSecondsPerWorkDay: Int {
        workDays > 0 ? (workedSeconds - overtimeSeconds) / workDays : 0
    }

    /// Durchschnittliches Einkommen pro getracktem Arbeitstag.
    var averageIncomePerWorkDay: Money {
        let average = workDays > 0 ? (income.value / Double(workDays)).rounded(toPlaces: 2) : 0
        return Money(value: average, currency: income.currency)
    }
}

/// Ein Balken im Dashboard-Chart: ein Tag (Woche/Monat) bzw. ein Monat (Jahr).
struct ChartEntry: Identifiable {
    let date: Date
    let workedSeconds: Int
    let targetSeconds: Int

    var id: Date { date }
}

@Observable
class JobDetailViewModel {
    var period: DashboardPeriod = .week
    /// Ankerdatum — bestimmt zusammen mit `period` den angezeigten Zeitraum.
    var referenceDate: Date = .now

    private let job: JobModel
    private let calendar = Calendar.current

    init(job: JobModel) {
        self.job = job
    }

    // MARK: - Zeitraum

    var dateInterval: DateInterval {
        calendar.dateInterval(of: period.calendarComponent, for: referenceDate)
            ?? DateInterval(start: referenceDate, duration: 0)
    }

    var title: String {
        switch period {
        case .week:
            let week = calendar.component(.weekOfYear, from: referenceDate)
            let year = calendar.component(.yearForWeekOfYear, from: referenceDate)
            return "KW \(week) · \(year)"
        case .month:
            return referenceDate.formatted(.dateTime.month(.wide).year())
        case .year:
            return String(calendar.component(.year, from: referenceDate))
        }
    }

    /// Vorwärtsblättern nur bis zur Periode, die „heute" enthält.
    var canGoForward: Bool {
        !dateInterval.contains(.now)
    }

    func goBack() {
        referenceDate = shiftedReferenceDate(by: -1)
    }

    func goForward() {
        guard canGoForward else { return }
        referenceDate = shiftedReferenceDate(by: 1)
    }

    private func shiftedReferenceDate(by value: Int) -> Date {
        calendar.date(byAdding: period.calendarComponent, value: value, to: referenceDate) ?? referenceDate
    }

    // MARK: - Kennzahlen

    var currentMetrics: PeriodMetrics {
        metrics(in: dateInterval)
    }

    var previousMetrics: PeriodMetrics {
        let previousInterval = calendar.dateInterval(of: period.calendarComponent, for: shiftedReferenceDate(by: -1))
        return metrics(in: previousInterval ?? dateInterval)
    }

    var workedDeltaSeconds: Int {
        currentMetrics.workedSeconds - previousMetrics.workedSeconds
    }

    var overtimeDeltaSeconds: Int {
        currentMetrics.overtimeSeconds - previousMetrics.overtimeSeconds
    }

    private func metrics(in interval: DateInterval) -> PeriodMetrics {
        var result = PeriodMetrics(income: Money(value: 0, currency: job.hourlyRate.currency))

        for summary in job.workDaySummaries where contains(interval, day: summary.day) {
            result.workedSeconds += summary.workedSeconds
            result.overtimeSeconds += summary.overtimeSeconds
            result.workDays += 1
        }

        // Einkommen und Pausen kommen aus den Sessions; die Zuordnung über den
        // Starttag ist konsistent zur Tages-Aggregation in `workDaySummaries`.
        for session in job.timeTrackings where !session.isRunning {
            guard contains(interval, day: calendar.startOfDay(for: session.startDate)) else { continue }

            result.income.value += session.income?.value ?? 0

            for pause in session.pauses {
                let seconds = Int(pause.duration())
                if pause.source == .manual {
                    result.manualPauseSeconds += seconds
                } else {
                    result.automaticPauseSeconds += seconds
                }
            }
        }

        result.income.value = result.income.value.rounded(toPlaces: 2)
        return result
    }

    /// Halboffener Intervall-Check [start, end) — `DateInterval.contains` schließt
    /// das Ende ein und würde den ersten Tag der Folgeperiode mitzählen.
    private func contains(_ interval: DateInterval, day: Date) -> Bool {
        interval.start <= day && day < interval.end
    }

    /// Geplante Arbeitstage im angezeigten Zeitraum. Feste Arbeitszeiten: Tage mit
    /// Tagesplan. Gleitzeit: anteilig aus `workingDaysPerWeek` hochgerechnet.
    var plannedWorkDays: Int {
        let interval = dateInterval

        switch job.scheduleType {
        case .fixed:
            var count = 0
            var day = interval.start
            while day < interval.end {
                if job.daySchedule(for: day) != nil {
                    count += 1
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }
            return count
        case .flexible:
            let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0
            return Int((Double(days) * Double(job.workingDaysPerWeek) / 7.0).rounded())
        }
    }

    // MARK: - Chart

    var chartEntries: [ChartEntry] {
        let interval = dateInterval
        let workedByDay = Dictionary(
            job.workDaySummaries.map { ($0.day, $0.workedSeconds) },
            uniquingKeysWith: +
        )

        switch period {
        case .week, .month:
            return dailyEntries(in: interval, workedByDay: workedByDay)
        case .year:
            return monthlyEntries(in: interval, workedByDay: workedByDay)
        }
    }

    private func dailyEntries(in interval: DateInterval, workedByDay: [Date: Int]) -> [ChartEntry] {
        var entries: [ChartEntry] = []
        var day = interval.start

        while day < interval.end {
            entries.append(ChartEntry(
                date: day,
                workedSeconds: workedByDay[day] ?? 0,
                targetSeconds: job.dailyTargetSeconds(for: day)
            ))

            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }

        return entries
    }

    private func monthlyEntries(in interval: DateInterval, workedByDay: [Date: Int]) -> [ChartEntry] {
        var entries: [ChartEntry] = []
        var monthStart = interval.start

        while monthStart < interval.end {
            guard let monthInterval = calendar.dateInterval(of: .month, for: monthStart) else { break }

            var worked = 0
            var target = 0
            var day = monthInterval.start
            while day < monthInterval.end {
                worked += workedByDay[day] ?? 0
                target += job.dailyTargetSeconds(for: day)

                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }

            entries.append(ChartEntry(date: monthStart, workedSeconds: worked, targetSeconds: target))
            monthStart = monthInterval.end
        }

        return entries
    }

    // MARK: - Formatierung

    /// Sekunden als "H:MM", z. B. "38:30".
    static func formatHours(_ seconds: Int) -> String {
        let (hours, minutes) = seconds.toHoursAndMinutes()
        return "\(hours):" + String(format: "%02d", minutes)
    }

    /// Sekunden als vorzeichenbehaftetes "±H:MM" für Delta-Anzeigen, z. B. "+2:15".
    static func formatDelta(_ seconds: Int) -> String {
        let sign = seconds < 0 ? "-" : "+"
        let (hours, minutes) = abs(seconds).toHoursAndMinutes()
        return "\(sign)\(hours):" + String(format: "%02d", minutes)
    }
}

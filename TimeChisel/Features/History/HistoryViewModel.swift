//
//  HistoryViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 06.07.26.
//

import Foundation
import Observation

/// Zeitraum-Voreinstellungen für den Verlaufs-Filter.
enum HistoryDateFilterKind: String, CaseIterable {
    case all
    case last30Days
    case thisYear
    case custom

    var displayName: String {
        switch self {
        case .all: return "Gesamter Zeitraum"
        case .last30Days: return "Letzte 30 Tage"
        case .thisYear: return "Dieses Jahr"
        case .custom: return "Eigener Zeitraum"
        }
    }
}

/// Ein Kalendertag im Verlauf mit allen Sessions und den Tages-Summen.
struct HistoryDayGroup: Identifiable {
    let day: Date
    let sessions: [TimeTrackingModel]
    let workedSeconds: Int
    /// Summe der per-Job-Salden dieses Tages (worked − Tagessoll je Job).
    let overtimeSeconds: Int

    var id: Date { day }
}

@Observable
class HistoryViewModel {
    var selectedJob: JobModel?
    var dateFilterKind: HistoryDateFilterKind = .all
    var customStart: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    var customEnd: Date = .now
    var onlyDaysWithBalance = false

    private let calendar = Calendar.current

    var hasActiveFilters: Bool {
        selectedJob != nil || dateFilterKind != .all || onlyDaysWithBalance
    }

    func resetFilters() {
        selectedJob = nil
        dateFilterKind = .all
        onlyDaysWithBalance = false
    }

    /// Effektiver Filter-Zeitraum — `nil` bedeutet keine Einschränkung.
    var dateInterval: DateInterval? {
        switch dateFilterKind {
        case .all:
            return nil
        case .last30Days:
            let end = calendar.startOfDay(for: .now).addingTimeInterval(24 * 3600)
            let start = calendar.date(byAdding: .day, value: -30, to: end) ?? end
            return DateInterval(start: start, end: end)
        case .thisYear:
            return calendar.dateInterval(of: .year, for: .now)
        case .custom:
            let start = calendar.startOfDay(for: customStart)
            let end = calendar.startOfDay(for: customEnd).addingTimeInterval(24 * 3600)
            return DateInterval(start: start, end: max(start, end))
        }
    }

    /// Gruppiert die abgeschlossenen, gefilterten Sessions nach Kalendertag —
    /// gleiche Tages-Konvention wie `JobModel.workDaySummaries` (Tag des Starts).
    func dayGroups(from sessions: [TimeTrackingModel]) -> [HistoryDayGroup] {
        let filtered = sessions.filter { session in
            guard !session.isRunning else { return false }
            if let selectedJob, session.job?.id != selectedJob.id { return false }
            if let interval = dateInterval {
                let day = calendar.startOfDay(for: session.startDate)
                guard interval.start <= day && day < interval.end else { return false }
            }
            return true
        }

        let byDay = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.startDate) }

        return byDay.map { day, daySessions in
            HistoryDayGroup(
                day: day,
                sessions: daySessions.sorted { $0.startDate > $1.startDate },
                workedSeconds: daySessions.reduce(0) { $0 + $1.workedSeconds() },
                overtimeSeconds: overtimeSeconds(for: daySessions, on: day)
            )
        }
        .filter { !onlyDaysWithBalance || $0.overtimeSeconds != 0 }
        .sorted { $0.day > $1.day }
    }

    /// Tages-Saldo über mehrere Jobs: Jeder Job wird gegen sein eigenes
    /// Tagessoll gerechnet, die Salden werden summiert.
    private func overtimeSeconds(for sessions: [TimeTrackingModel], on day: Date) -> Int {
        let byJob = Dictionary(grouping: sessions) { $0.job?.id.uuidString ?? "none" }

        return byJob.values.reduce(0) { total, jobSessions in
            let worked = jobSessions.reduce(0) { $0 + $1.workedSeconds() }
            let target = jobSessions.first?.job?.dailyTargetSeconds(for: day) ?? 0
            return total + (worked - target)
        }
    }
}

//
//  JobDashboardChart.swift
//  TimeChisel
//
//  Created by Karsten Krause on 05.07.26.
//

import SwiftUI
import Charts

/// Balkendiagramm der Arbeitszeit im gewählten Zeitraum mit gestrichelter Soll-Linie.
/// Woche/Monat: ein Balken pro Tag. Jahr: ein Balken pro Monat.
struct JobDashboardChart: View {
    let entries: [ChartEntry]
    let period: DashboardPeriod

    /// Vom Nutzer angetippte x-Position — Swift Charts liefert das Datum unter dem Finger.
    @State private var selectedDate: Date?

    private var xUnit: Calendar.Component {
        period == .year ? .month : .day
    }

    /// Der Eintrag, dessen Tag bzw. Monat die angetippte Position enthält.
    private var selectedEntry: ChartEntry? {
        guard let selectedDate else { return nil }
        return entries.first { Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: xUnit) }
    }

    var body: some View {
        Chart {
            ForEach(entries) { entry in
                BarMark(
                    x: .value("Datum", entry.date, unit: xUnit),
                    y: .value("Stunden", hours(entry.workedSeconds))
                )
                .foregroundStyle(Color("lightGreen").gradient)
                .cornerRadius(3)
                .opacity(selectedEntry == nil || selectedEntry?.id == entry.id ? 1 : 0.4)
            }

            ForEach(entries) { entry in
                LineMark(
                    x: .value("Datum", entry.date, unit: xUnit),
                    y: .value("Soll", hours(entry.targetSeconds))
                )
                .interpolationMethod(.stepCenter)
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundStyle(.blue)
            }

            if let entry = selectedEntry {
                RuleMark(x: .value("Ausgewählt", entry.date, unit: xUnit))
                    .foregroundStyle(.secondary.opacity(0.35))
                    .annotation(
                        position: .top,
                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                    ) {
                        tooltip(for: entry)
                    }
            }
        }
        .chartXSelection(value: $selectedDate)
        .onChange(of: period) { _, _ in
            selectedDate = nil
        }
        .chartXAxis {
            switch period {
            case .week:
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            case .month:
                AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day())
                }
            case .year:
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                    }
                }
            }
        }
        .frame(height: 220)
    }

    private func hours(_ seconds: Int) -> Double {
        Double(seconds) / 3600.0
    }

    private func tooltip(for entry: ChartEntry) -> some View {
        let overtimeSeconds = entry.workedSeconds - entry.targetSeconds

        return VStack(alignment: .leading, spacing: 4) {
            Text(tooltipDateLabel(for: entry.date))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Ist: \(JobDetailViewModel.formatHours(entry.workedSeconds))")
                .font(.caption)
                .bold()

            Text("Soll: \(JobDetailViewModel.formatHours(entry.targetSeconds))")
                .font(.caption)
                .foregroundStyle(.blue)

            Text("Saldo: \(JobDetailViewModel.formatDelta(overtimeSeconds))")
                .font(.caption)
                .foregroundStyle(overtimeSeconds < 0 ? .red : .green)
        }
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private func tooltipDateLabel(for date: Date) -> String {
        switch period {
        case .week:
            return date.formatted(.dateTime.weekday(.wide).day().month())
        case .month:
            return date.formatted(.dateTime.weekday(.abbreviated).day().month())
        case .year:
            return date.formatted(.dateTime.month(.wide).year())
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now

    let entries = (0..<7).map { offset in
        let day = calendar.date(byAdding: .day, value: offset, to: weekStart) ?? weekStart
        let isWeekend = calendar.isDateInWeekend(day)
        return ChartEntry(
            date: day,
            workedSeconds: isWeekend ? 0 : (7 * 3600 + offset * 45 * 60),
            targetSeconds: isWeekend ? 0 : 8 * 3600
        )
    }

    return JobDashboardChart(entries: entries, period: .week)
        .padding()
}

//
//  SessionDetailView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 06.07.26.
//

import SwiftUI
import SwiftData

/// Detailansicht einer einzelnen Zeiterfassung mit allen Pausen.
struct SessionDetailView: View {
    @Bindable var session: TimeTrackingModel
    @State private var showingEditSheet = false

    var body: some View {
        List {
            Section("Aufzeichnung") {
                LabeledContent("Job", value: session.job?.companyName ?? "—")
                LabeledContent("Datum", value: session.startDate.formatted(date: .complete, time: .omitted))
                LabeledContent("Start", value: session.startDate.formatted(date: .omitted, time: .shortened))
                LabeledContent("Ende", value: session.endDate?.formatted(date: .omitted, time: .shortened) ?? "läuft")
                LabeledContent("Arbeitszeit", value: JobDetailViewModel.formatHours(session.workedSeconds()))
            }

            Section("Pausen") {
                if session.pauses.isEmpty {
                    Text("Keine Pausen")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(session.pauses.indices, id: \.self) { index in
                        pauseRow(session.pauses[index])
                    }
                }
            }

            if let income = session.income {
                Section("Verdienst") {
                    LabeledContent("Verdienst", value: "\(income.value.formatted()) \(income.currency.rawValue)")
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Bearbeiten") {
                    showingEditSheet = true
                }
                .disabled(session.isRunning)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditSessionView(session: session)
        }
    }

    private func pauseRow(_ pause: Pause) -> some View {
        HStack {
            Text("\(pause.start.formatted(date: .omitted, time: .shortened)) – \(pause.end?.formatted(date: .omitted, time: .shortened) ?? "läuft")")

            Spacer()

            Text(JobDetailViewModel.formatHours(Int(pause.duration())))
                .foregroundStyle(.secondary)

            if pause.source == .automatic {
                Text("automatisch")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(.orange.opacity(0.2)))
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobModel.self, TimeTrackingModel.self, configurations: config)

    let job = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25, currency: .EUR))
    container.mainContext.insert(job)

    let start = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
    let session = TimeTrackingModel(startDate: start)
    container.mainContext.insert(session)
    session.job = job
    session.pauses = [
        Pause(start: start.addingTimeInterval(2 * 3600), end: start.addingTimeInterval(2 * 3600 + 15 * 60), source: .manual),
        Pause(start: start.addingTimeInterval(4 * 3600 + 10 * 60), end: start.addingTimeInterval(4 * 3600 + 40 * 60), source: .automatic)
    ]
    session.finish(hourlyRate: job.hourlyRate, at: start.addingTimeInterval(8 * 3600 + 45 * 60))

    return NavigationStack {
        SessionDetailView(session: session)
    }
    .modelContainer(container)
}

//
//  HistoryView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \TimeTrackingModel.startDate, order: .reverse) var sessions: [TimeTrackingModel]
    @Query(sort: \JobModel.companyName) var jobs: [JobModel]
    @State private var viewModel = HistoryViewModel()
    @State private var showingFilterSheet = false
    @State private var sessionToDelete: TimeTrackingModel?

    private var runningSession: TimeTrackingModel? {
        sessions.first { $0.isRunning }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.hasActiveFilters {
                    filterChips
                }

                content
            }
            .navigationTitle("Verlauf")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilterSheet = true
                    }, label: {
                        Image(systemName: viewModel.hasActiveFilters
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    })
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                filterSheet
            }
            .confirmationDialog(
                "Aufzeichnung löschen?",
                isPresented: Binding(
                    get: { sessionToDelete != nil },
                    set: { if !$0 { sessionToDelete = nil } }
                ),
                presenting: sessionToDelete
            ) { session in
                Button("Löschen", role: .destructive) {
                    context.delete(session)
                    sessionToDelete = nil
                }
                Button("Abbrechen", role: .cancel) {
                    sessionToDelete = nil
                }
            } message: { _ in
                Text("Die Aufzeichnung wird endgültig gelöscht und aus allen Statistiken entfernt.")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let groups = viewModel.dayGroups(from: sessions)

        if groups.isEmpty && runningSession == nil {
            ContentUnavailableView(
                viewModel.hasActiveFilters ? "Keine Treffer" : "Noch keine Aufzeichnungen",
                systemImage: "calendar.badge.clock",
                description: Text(viewModel.hasActiveFilters
                                  ? "Für die gewählten Filter gibt es keine Aufzeichnungen."
                                  : "Starte deine erste Aufzeichnung im Zeiterfassungs-Tab.")
            )
        } else {
            List {
                if let running = runningSession {
                    Section {
                        runningRow(running)
                    }
                }

                ForEach(groups) { group in
                    Section {
                        ForEach(group.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                sessionRow(session)
                            }
                            .swipeActions {
                                Button("Löschen", systemImage: "trash", role: .destructive) {
                                    sessionToDelete = session
                                }
                            }
                        }
                    } header: {
                        dayHeader(group)
                    }
                }
            }
        }
    }

    // MARK: - Zeilen

    private func runningRow(_ session: TimeTrackingModel) -> some View {
        HStack {
            Circle()
                .fill(Color("lightGreen"))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading) {
                Text("Läuft gerade")
                    .font(.headline)
                    .foregroundStyle(Color("lightGreen"))
                Text("\(session.job?.companyName ?? "Ohne Job") · seit \(session.startDate.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func sessionRow(_ session: TimeTrackingModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(timeRange(of: session))
                    .font(.headline)

                Spacer()

                Text(JobDetailViewModel.formatHours(session.workedSeconds()))
                    .font(.headline)
                    .foregroundStyle(Color("lightGreen"))
            }

            HStack {
                Text(session.job?.companyName ?? "Ohne Job")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(.blue.opacity(0.15)))

                Spacer()

                if session.pausedSeconds() > 0 {
                    Text("Pause \(JobDetailViewModel.formatHours(session.pausedSeconds()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let income = session.income {
                    Text("\(income.value.formatted()) \(income.currency.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func dayHeader(_ group: HistoryDayGroup) -> some View {
        HStack {
            Text(group.day.formatted(.dateTime.weekday(.abbreviated).day().month().year()))

            Spacer()

            Text(JobDetailViewModel.formatHours(group.workedSeconds))

            Text(JobDetailViewModel.formatDelta(group.overtimeSeconds))
                .foregroundStyle(group.overtimeSeconds < 0 ? .red : .green)
        }
    }

    private func timeRange(of session: TimeTrackingModel) -> String {
        let start = session.startDate.formatted(date: .omitted, time: .shortened)
        guard let endDate = session.endDate else { return start }
        return "\(start) – \(endDate.formatted(date: .omitted, time: .shortened))"
    }

    // MARK: - Filter

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let job = viewModel.selectedJob {
                    filterChip(job.companyName) { viewModel.selectedJob = nil }
                }

                if viewModel.dateFilterKind != .all {
                    filterChip(viewModel.dateFilterKind.displayName) { viewModel.dateFilterKind = .all }
                }

                if viewModel.onlyDaysWithBalance {
                    filterChip("Nur Saldo ≠ 0") { viewModel.onlyDaysWithBalance = false }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func filterChip(_ label: String, remove: @escaping () -> Void) -> some View {
        Button(action: remove) {
            HStack(spacing: 4) {
                Text(label)
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(.blue.opacity(0.15)))
        }
        .buttonStyle(.plain)
    }

    private var filterSheet: some View {
        NavigationView {
            Form {
                Section("Job") {
                    Picker("Job", selection: $viewModel.selectedJob) {
                        Text("Alle Jobs").tag(nil as JobModel?)
                        ForEach(jobs) { job in
                            Text(job.companyName).tag(job as JobModel?)
                        }
                    }
                }

                Section("Zeitraum") {
                    Picker("Zeitraum", selection: $viewModel.dateFilterKind) {
                        ForEach(HistoryDateFilterKind.allCases, id: \.self) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }

                    if viewModel.dateFilterKind == .custom {
                        DatePicker("Von", selection: $viewModel.customStart, displayedComponents: .date)
                        DatePicker("Bis", selection: $viewModel.customEnd, in: viewModel.customStart..., displayedComponents: .date)
                    }
                }

                Section {
                    Toggle("Nur Tage mit Saldo ≠ 0", isOn: $viewModel.onlyDaysWithBalance)
                }

                Section {
                    Button("Filter zurücksetzen", role: .destructive) {
                        viewModel.resetFilters()
                    }
                    .disabled(!viewModel.hasActiveFilters)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        showingFilterSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobModel.self, TimeTrackingModel.self, configurations: config)

    let jobA = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25, currency: .EUR))
    let jobB = JobModel(companyName: "Campus", jobTitle: "Werkstudent", workingHoursPerWeek: 10, workingDaysPerWeek: 2, pauseMinutesPerDay: 15, hourlyRate: Money(value: 15, currency: .EUR))
    container.mainContext.insert(jobA)
    container.mainContext.insert(jobB)

    let calendar = Calendar.current
    for dayOffset in 1...10 {
        guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: .now),
              !calendar.isDateInWeekend(day),
              let start = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: day) else { continue }

        let session = TimeTrackingModel(startDate: start)
        container.mainContext.insert(session)
        session.job = dayOffset % 3 == 0 ? jobB : jobA
        session.startPause(at: start.addingTimeInterval(4 * 3600))
        session.resumeWork(at: start.addingTimeInterval(4 * 3600 + 30 * 60))
        session.finish(hourlyRate: jobA.hourlyRate, at: start.addingTimeInterval(TimeInterval(8 * 3600 + 30 * 60 + dayOffset * 900)))

        // Zweite Session am selben Tag für die Tages-Gruppierung
        if dayOffset == 1, let eveningStart = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: day) {
            let evening = TimeTrackingModel(startDate: eveningStart)
            container.mainContext.insert(evening)
            evening.job = jobB
            evening.finish(hourlyRate: jobB.hourlyRate, at: eveningStart.addingTimeInterval(2 * 3600))
        }
    }

    let running = TimeTrackingModel(startDate: .now.addingTimeInterval(-45 * 60))
    container.mainContext.insert(running)
    running.job = jobA

    return HistoryView().modelContainer(container)
}

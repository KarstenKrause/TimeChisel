//
//  JobDetailView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 11.02.24.
//

import SwiftUI
import SwiftData

struct JobDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.timeTrackingStatus) var trackingStatus
    @State private var showingTimeIsTrackingAlert: Bool = false
    @State private var showingDeleteAlert = false
    @State private var showUpdateJobView: Bool = false
    @State var job: JobModel
    @State private var dashboardVM: JobDetailViewModel

    init(job: JobModel) {
        _job = State(initialValue: job)
        _dashboardVM = State(initialValue: JobDetailViewModel(job: job))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Zeitraum", selection: $dashboardVM.period) {
                    ForEach(DashboardPeriod.allCases, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                periodNavigation

                GroupBox {
                    JobDashboardChart(entries: dashboardVM.chartEntries, period: dashboardVM.period)
                }
                .backgroundStyle(.regularMaterial)

                kpiGrid
            }
            .padding()
        }
        .navigationTitle(job.companyName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    trackingStatus.isTracking ? showingTimeIsTrackingAlert.toggle() : showUpdateJobView.toggle()
                }, label: {
                    Image(systemName: "pencil.circle")
                })
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    trackingStatus.isTracking ? showingTimeIsTrackingAlert.toggle() : showingDeleteAlert.toggle()

                }, label: {
                    Image(systemName: "trash.circle")
                        .foregroundColor(.red)
                })
                .alert("Jobs können während einer Zeiterfassung nicht bearbeitet oder gelöscht werden.", isPresented: $showingTimeIsTrackingAlert) {
                    Button("OK", role: .cancel) {
                        showingTimeIsTrackingAlert = false
                    }
                }
                .alert("Der Job und alle zusammenhängenden Daten werden hierdurch entgültig gelöscht.", isPresented: $showingDeleteAlert) {
                    Button("Löschen", role: .destructive) {
                        context.delete(job)
                        dismiss()
                    }

                    Button("Abbrechen", role: .cancel) {}
                }
            }
        }
        .sheet(isPresented: $showUpdateJobView, content: {
            UpdateJobView(jobModel: job)
        })
    }

    private var periodNavigation: some View {
        HStack {
            Button(action: {
                dashboardVM.goBack()
            }, label: {
                Image(systemName: "chevron.left")
            })

            Spacer()

            Text(dashboardVM.title)
                .font(.headline)

            Spacer()

            Button(action: {
                dashboardVM.goForward()
            }, label: {
                Image(systemName: "chevron.right")
            })
            .disabled(!dashboardVM.canGoForward)
        }
        .padding(.horizontal, 4)
    }

    private var kpiGrid: some View {
        let metrics = dashboardVM.currentMetrics

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            kpiBox("Arbeitszeit",
                   value: JobDetailViewModel.formatHours(metrics.workedSeconds),
                   deltaSeconds: dashboardVM.workedDeltaSeconds)

            kpiBox("Überstunden",
                   value: Overtime(seconds: metrics.overtimeSeconds).formatted,
                   valueColor: metrics.overtimeSeconds < 0 ? .red : .green,
                   deltaSeconds: dashboardVM.overtimeDeltaSeconds)

            kpiBox("Einkommen",
                   value: "\(metrics.income.value.formatted()) \(metrics.income.currency.rawValue)",
                   subtitle: "Ø \(metrics.averageIncomePerWorkDay.value.formatted()) \(metrics.averageIncomePerWorkDay.currency.rawValue) pro Arbeitstag")

            kpiBox("Pausen",
                   value: JobDetailViewModel.formatHours(metrics.totalPauseSeconds),
                   subtitle: "\(JobDetailViewModel.formatHours(metrics.manualPauseSeconds)) manuell · \(JobDetailViewModel.formatHours(metrics.automaticPauseSeconds)) auto")

            kpiBox("Ø pro Arbeitstag",
                   value: JobDetailViewModel.formatHours(metrics.averageSecondsPerWorkDay),
                   subtitle: "Soll-Ø: \(JobDetailViewModel.formatHours(metrics.averageTargetSecondsPerWorkDay))")

            kpiBox("Arbeitstage",
                   value: "\(metrics.workDays)",
                   subtitle: "von \(dashboardVM.plannedWorkDays) geplant")
        }
    }

    private func kpiBox(_ title: String,
                        value: String,
                        valueColor: Color? = nil,
                        subtitle: String? = nil,
                        deltaSeconds: Int? = nil) -> some View {
        GroupBox(title) {
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .foregroundStyle(valueColor ?? .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                if let deltaSeconds {
                    Text("\(JobDetailViewModel.formatDelta(deltaSeconds)) vs. \(dashboardVM.period.previousPeriodLabel)")
                        .font(.caption)
                        .foregroundStyle(deltaSeconds < 0 ? .red : .green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
        }
        .groupBoxStyle(.jobDetails)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobModel.self, TimeTrackingModel.self, configurations: config)

    let job = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25.0, currency: .EUR))
    container.mainContext.insert(job)

    // Sessions der letzten zwei Wochen mit Pausen, damit das Dashboard Daten zeigt.
    let calendar = Calendar.current
    for dayOffset in 0...13 {
        guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: .now),
              !calendar.isDateInWeekend(day),
              let start = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: day) else { continue }

        let session = TimeTrackingModel(startDate: start)
        container.mainContext.insert(session)
        session.job = job

        session.startPause(at: start.addingTimeInterval(4 * 3600))
        session.resumeWork(at: start.addingTimeInterval(4 * 3600 + 30 * 60))
        session.finish(hourlyRate: job.hourlyRate, at: start.addingTimeInterval(TimeInterval(8 * 3600 + 30 * 60 + dayOffset * 900)))
    }

    return NavigationView {
        JobDetailView(job: job)
    }
    .modelContainer(container)
}

struct JobDetailsGroupboxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .bold()
                .padding(.bottom, 5)
            configuration.content
                .font(.title)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

extension GroupBoxStyle where Self == JobDetailsGroupboxStyle {
    static var jobDetails: JobDetailsGroupboxStyle { .init() }
}

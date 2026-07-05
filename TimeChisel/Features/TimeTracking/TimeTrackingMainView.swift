//
//  TimeTrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI
import SwiftData

struct TimeTrackingMainView: View {
    @Environment(\.modelContext) var context
    @Environment(\.timeTrackingStatus) var trackingStatus
    @Environment(\.scenePhase) var scenePhase
    @Query(sort: \JobModel.companyName) var jobs: [JobModel]

    /// Offene Sessions (ohne Enddatum) — existiert eine, läuft die Zeiterfassung
    /// und wird nach einem App-Neustart nahtlos fortgesetzt.
    @Query(filter: #Predicate<TimeTrackingModel> { $0.endDate == nil }) var openSessions: [TimeTrackingModel]

    @State private var selectedJob: JobModel? = nil

    var body: some View {
        VStack {
            if let session = openSessions.first {
                TrackingView(session: session)
            } else {
                Form {
                    Section("Job auswählen") {
                        Picker("Jobs", selection: $selectedJob) {
                            ForEach(jobs, id: \.self) { job in
                                Text(job.companyName).tag(job as JobModel?)
                            }
                        }
                    }
                }

                Button(action: {
                    startTracking()
                }, label: {
                    Text("Starten")
                        .bold()
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(selectedJob != nil ? .green.opacity(0.30) : .gray.opacity(0.35))
                        .foregroundColor(Color("lightGreen"))
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color("customBW"), lineWidth: 1.5)
                                .padding(4)
                        )
                })
                .padding(35)
                .disabled(selectedJob == nil)
            }
        }
        .onAppear {
            if !jobs.isEmpty {
                selectedJob = jobs[0]
            }
            // Nach einem App-Neustart mit offener Session den Tracking-Status synchronisieren.
            trackingStatus.isTracking = !openSessions.isEmpty
            openSessions.first?.applyScheduledPauses()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Beim Zurückkehren in den Vordergrund überfällige feste Pausen nachtragen —
            // im Hintergrund läuft kein Timer, der das übernehmen könnte.
            if newPhase == .active {
                openSessions.first?.applyScheduledPauses()
            }
        }
    }

    private func startTracking() {
        guard let job = selectedJob else { return }

        // Die Session wird sofort persistiert und überlebt damit einen App-Neustart.
        let session = TimeTrackingModel(startDate: .now)
        context.insert(session)
        session.job = job

        trackingStatus.isTracking = true
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    let container = try! ModelContainer(for: JobModel.self, TimeTrackingModel.self, configurations: config)

    let job: JobModel = JobModel(companyName: "DTS", jobTitle: "Softwareentwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25.0, currency: .EUR))

    container.mainContext.insert(job)

    return TimeTrackingMainView().modelContainer(container)
}

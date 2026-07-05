//
//  TrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 24.04.24.
//

import SwiftUI
import SwiftData

struct TrackingView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.timeTrackingStatus) var trackingStatus
    @Bindable var session: TimeTrackingModel
    @State private var showingConfirmation: Bool = false

    var body: some View {
        // Die Anzeige wird jede Sekunde aus den Zeitstempeln der Session neu berechnet.
        // Der Tick treibt auch das automatische Nachtragen fester Pausenzeiten an.
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            VStack {
                ZStack {
                    VStack {
                        if session.isPausing {
                            TimeView(timeVM: TimeViewModel(seconds: session.pausedSeconds(asOf: timeline.date), for: .breakTime))
                        } else {
                            TimeView(timeVM: TimeViewModel(seconds: session.workedSeconds(asOf: timeline.date), for: .workTime))
                        }
                    }

                    if let job = session.job {
                        ActivityRingsView(workingHours: Double(job.dailyTargetSeconds(for: session.startDate)) / 3600.0, pauseMinutes: job.daySchedule(for: session.startDate)?.pauseMinutes ?? job.pauseMinutesPerDay, secondsWorked: session.workedSeconds(asOf: timeline.date), secondsPaused: session.pausedSeconds(asOf: timeline.date))
                    } else {
                        Text("No Job Selected").foregroundStyle(.red)
                    }
                }
                .padding(50)

                Spacer()

                buttonRow(asOf: timeline.date)
            }
            .onChange(of: timeline.date) { _, newDate in
                session.applyScheduledPauses(asOf: newDate)
            }
        }
    }

    private func buttonRow(asOf now: Date) -> some View {
        VStack {
            HStack {
                if !session.isPausing {
                    let canPause = session.canStartManualPause(asOf: now)

                    Button(action: {
                        session.startPause()
                    }, label: {
                        Text("Pause")
                            .bold()
                            .font(.footnote)
                            .frame(width: 80, height: 80, alignment: .center)
                            .background(.blue.opacity(0.30))
                            .foregroundColor((colorScheme == .dark ? Color("lightBlue") : .blue))
                            .cornerRadius(100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(Color("customBW"), lineWidth: 1.5)
                                    .padding(4)
                            )
                    })
                    .disabled(!canPause)
                    .opacity(canPause ? 1 : 0.4)
                } else {
                    Button(action: {
                        session.resumeWork()
                    }, label: {
                        Text("Weiter")
                            .bold()
                            .font(.footnote)
                            .frame(width: 80, height: 80, alignment: .center)
                            .background(.green.opacity(0.30))
                            .foregroundColor(Color("lightGreen"))
                            .cornerRadius(100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(Color("customBW"), lineWidth: 1.5)
                                    .padding(4)
                            )
                    })
                }

                Spacer()

                Button(action: {
                    self.showingConfirmation = true

                }, label: {
                    Text("Beenden")
                        .bold()
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(.red.opacity(0.30))
                        .foregroundColor((colorScheme == .dark ? Color("lightBlue") : .red))
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color("customBW"), lineWidth: 1.5)
                                .padding(4)
                        )
                })
                .confirmationDialog("Zeiterfassung beenden?", isPresented: $showingConfirmation) {
                    Button("OK") {
                        finishTracking()
                    }

                    Button("Abbrechen", role: .cancel) {
                        self.showingConfirmation = false
                    }
                    .tint(.red)

                } message: {
                    Text("Die aufgenommene Arbeitszeit und Pausenzeit wird hierdurch gespeichert.")
                }
            }
            .padding(40)
        }
    }

    /// Schließt die laufende Session ab. Die Session ist bereits persistiert —
    /// hier werden nur Enddatum gesetzt und der Verdienst gesnapshottet.
    private func finishTracking() {
        guard let job = session.job else {
            print("No Job selected.")
            return
        }

        session.finish(hourlyRate: job.hourlyRate)
        self.showingConfirmation = false
        trackingStatus.isTracking = false
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobModel.self, TimeTrackingModel.self, configurations: config)

    let job = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25.0, currency: .EUR))
    container.mainContext.insert(job)

    let session = TimeTrackingModel(startDate: .now)
    container.mainContext.insert(session)
    session.job = job

    return TrackingView(session: session).modelContainer(container)
}

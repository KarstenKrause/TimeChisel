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
        VStack {
            // Die Anzeige wird jede Sekunde aus den Zeitstempeln der Session neu berechnet.
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                ZStack {
                    VStack {
                        if session.isPausing {
                            TimeView(timeVM: TimeViewModel(seconds: session.pausedSeconds(asOf: timeline.date), for: .breakTime))
                        } else {
                            TimeView(timeVM: TimeViewModel(seconds: session.workedSeconds(asOf: timeline.date), for: .workTime))
                        }
                    }

                    if let job = session.job {
                        ActivityRingsView(workingHours: job.workingHoursPerDay, pauseMinutes: job.pauseMinutesPerDay, secondsWorked: session.workedSeconds(asOf: timeline.date), secondsPaused: session.pausedSeconds(asOf: timeline.date))
                    } else {
                        Text("No Job Selected").foregroundStyle(.red)
                    }
                }
            }
            .padding(50)

            Spacer()

            VStack {
                HStack {
                    if !session.isPausing {
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

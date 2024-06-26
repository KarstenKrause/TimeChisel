//
//  TrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 24.04.24.
//

import SwiftUI

struct TrackingView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isWorkingTimerRunning: Bool
    @Binding var selectedJob: JobModel?
    @Bindable var trackingVM = TrackingViewModel()
    @State private var isPauseTimerRunning: Bool = false
    @State private var timeTrackingCanceled: Bool = false
    @State private var showingAlert: Bool = false
    

    var body: some View {
        
        VStack {
            ZStack {
                VStack {
                    if isPauseTimerRunning {
                        TimeView(timeVM: TimeViewModel(seconds: trackingVM.secondsPaused, for: .breakTime))
                    } else {
                        TimeView(timeVM: TimeViewModel(seconds: trackingVM.secondsWorked, for: .workTime))
                    }
                }
                
                ActivityRingsView(workingHours: Int(selectedJob?.workingHoursPerDay ?? 0), pauseMinutes: Int(selectedJob?.pauseMinutesPerDay ?? 0), secondsWorked: $trackingVM.secondsWorked, secondsPaused: $trackingVM.secondsPaused)
            }
            .padding(50)
            Spacer()
            VStack {
                HStack {
                    if !isPauseTimerRunning {
                        Button(action: {
                            self.isPauseTimerRunning = true
                            trackingVM.stopWorkedTimer()
                            trackingVM.startPausedTimer()
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
                            self.isPauseTimerRunning = false
                            trackingVM.stopPausedTimer()
                            trackingVM.startWorkedTimer()
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
                        self.showingAlert = true
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
                                // TODO: create custom background color for light-/darkmode
                                    .stroke(Color("customBW"), lineWidth: 1.5)
                                    .padding(4)
                            )
                    })
                    .alert("Zeiterfassung beenden?", isPresented: $showingAlert) {
                        Button("OK") {
                            self.timeTrackingCanceled = true
                            self.isWorkingTimerRunning = false
                            trackingVM.endAll()
                            self.showingAlert = false
                        }
                       
                        Button("Abbrechen", role: .cancel) {
                            self.showingAlert = false
                        }
                        
                    } message: {
                        Text("Die aufgenommene Arbeitszeit und Pausenzeit wird hierdurch gespeichert.")

                    }
                }
                .padding(40)
            }
        }
        .onAppear() {
            trackingVM.startWorkedTimer()
            print("Tage die Woche: \(selectedJob?.workingDaysPerWeek ?? 0)")
        }
    }
    
}

#Preview {
    struct PreviewWrapper: View {
        @State var isWorkingTimerRunning: Bool = false
        @State var selectedJob: JobModel? = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: HourlyRate(value: 25.0, currency: .EUR))
        
        var body: some View {
            TrackingView(isWorkingTimerRunning: $isWorkingTimerRunning, selectedJob: $selectedJob)
        }
    }
    
    return PreviewWrapper()
}

//
//  TrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 24.04.24.
//

import SwiftUI

struct TrackingView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.timeTrackingStatus) var trackingStatus
    @Binding var isWorkingTimerRunning: Bool
    @Binding var selectedJob: JobModel?
    @Bindable var trackingVM = TrackingViewModel()
    @State private var isPauseTimerRunning: Bool = false
    @State private var timeTrackingCanceled: Bool = false
    @State private var showingConfirmation: Bool = false
    
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
                
                if let selectedJob = selectedJob {
                    ActivityRingsView(workingHours: (selectedJob.workingHoursPerDay), pauseMinutes: Int(selectedJob.pauseMinutesPerDay), secondsWorked: $trackingVM.secondsWorked, secondsPaused: $trackingVM.secondsPaused)
                } else {
                    Text("No Job Selected").foregroundStyle(.red)
                }
                
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
                            storeAndCancel()
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
        .onAppear() {
            trackingVM.startWorkedTimer()
        }
    }
    
    private func storeAndCancel() {
        saveTrackedTimes()
        self.timeTrackingCanceled = true
        self.isWorkingTimerRunning = false
        self.trackingVM.endAll()
        self.showingConfirmation = false
        trackingStatus.isTracking = false
    }
    
    private func saveTrackedTimes() {
        guard let selectedJob = selectedJob else {
            print("No Job selected.")
            return
        }
        
        let calculatedWorktime: WorkingTime = trackingVM.getCalculatedWorkingTime(
            secondsWorked: trackingVM.secondsWorked,
            secondsPaused: trackingVM.secondsPaused,
            targetWorkingHours: selectedJob.workingHoursPerDay,
            targetPauseMinutes: Int(selectedJob.pauseMinutesPerDay)
        )
        
        let calculatedIncome: Money = trackingVM.getCalculatedIncome(
            hourlyRate: selectedJob.hourlyRate,
            workTime: calculatedWorktime
        )
        
        let timeTrack = TimeTrackingModel(date: Date(), workingTime: calculatedWorktime, income: calculatedIncome)
        
        selectedJob.timeTrackings.append(timeTrack)
        
    }
    
}

#Preview {
    struct PreviewWrapper: View {
        @State var isWorkingTimerRunning: Bool = false
        @State var selectedJob: JobModel? = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25.0, currency: .EUR))
        
        var body: some View {
            TrackingView(isWorkingTimerRunning: $isWorkingTimerRunning, selectedJob: $selectedJob)
        }
    }
    
    return PreviewWrapper()
}

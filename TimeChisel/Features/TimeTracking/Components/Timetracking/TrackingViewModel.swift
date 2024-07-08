//
//  TrackingViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 21.06.24.
//

import SwiftUI
import Observation
import Combine

@Observable
class TrackingViewModel {
    var secondsWorked: Int = 0
    var secondsPaused: Int = 0
    var workedTimer: AnyCancellable?
    var pausedTimer: AnyCancellable?
    
    func startWorkedTimer() {
        workedTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            //            withAnimation {
            //                self.secondsWorked += 1
            //            }
            self.secondsWorked += 1
        }
    }
    
    func stopWorkedTimer() {
        workedTimer?.cancel()
    }
    
    func startPausedTimer() {
        pausedTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            //            withAnimation {
            //                self.secondsPaused += 1
            //            }
            self.secondsPaused += 1
            
        }
    }
    
    func stopPausedTimer() {
        pausedTimer?.cancel()
    }
    
    func endAll() {
        stopWorkedTimer()
        stopPausedTimer()
        
        self.secondsWorked = 0
        self.secondsPaused = 0
    }
    
    func getCalculatedWorkingTime(secondsWorked: Int, secondsPaused: Int, targetWorkingHours: Int, targetPauseMinutes: Int) -> WorkingTime {
        let hoursWorked = secondsWorked / 3600
        let minutesWorked = (secondsWorked % 3600) / 60
        
        let targetWorkingSeconds = targetWorkingHours * 3600
        let targetPauseSeconds = targetPauseMinutes * 60
        
        var overtimeSeconds = secondsWorked - targetWorkingSeconds
        
        if secondsPaused > targetPauseSeconds {
            overtimeSeconds -= (secondsPaused - targetPauseSeconds)
        }
        
        let overtimeHours = overtimeSeconds / 3600
        let overtimeMinutes = (overtimeSeconds % 3600) / 60
        
        return WorkingTime(
            hours: hoursWorked,
            minutes: minutesWorked,
            overtime: Overtime(hours: overtimeHours, minutes: overtimeMinutes)
        )
    }
    
    func getCalculatedIncome(hourlyRate: Money, workTime: WorkingTime) -> Money {
        let totalMinutes = (workTime.hours * 60) + workTime.minutes
        
        let totalHours = Double(totalMinutes) / 60.0
        let incomeValue = totalHours * hourlyRate.value
        
        // Rückgabe des berechneten Einkommens als MonetaryAmount
        return Money(value: incomeValue, currency: hourlyRate.currency)
    }
}

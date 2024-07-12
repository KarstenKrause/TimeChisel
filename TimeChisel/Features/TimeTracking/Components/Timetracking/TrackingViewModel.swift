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
    
    func getCalculatedWorkingTime(secondsWorked: Int, secondsPaused: Int, targetWorkingHours: Double, targetPauseMinutes: Int) -> WorkingTime {
        let hoursWorked = secondsWorked / 3600
        let minutesWorked = (secondsWorked % 3600) / 60
        
        let targetWorkingSeconds = targetWorkingHours * 3600
        let targetPauseSeconds = targetPauseMinutes * 60
        
        var overtimeSeconds = secondsWorked - Int(targetWorkingSeconds)
        
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
    
    func getTotalWorkingTime(hours: Int, minutes: Int, overTime: Overtime) -> WorkingTime {
        let totalTime = getTotalTime(hours: hours, minutes: minutes)
        let totalOverTime = getTotalOverTime(overTime: overTime)
        
        return WorkingTime(hours: totalTime.hours, minutes: totalTime.minutes, overtime: totalOverTime)
    }
    
    func getTotalOverTime(overTime: Overtime) -> Overtime {
        let totalTime = getTotalTime(hours: overTime.hours, minutes: overTime.minutes)
        
        return Overtime(hours: totalTime.hours, minutes: totalTime.minutes)
    }
    
    func getTotalTime(hours: Int, minutes: Int) -> (hours: Int, minutes: Int) {
        var totalHours = hours
        var totalMinutes = minutes
        
        totalHours = totalMinutes / 60
        totalMinutes %= 60
        
        return (totalHours, totalMinutes)
    }
    
    func getCalculatedIncome(hourlyRate: Money, workTime: WorkingTime) -> Money {
        let totalMinutes = (workTime.hours * 60) + workTime.minutes
        
        let totalHours = Double(totalMinutes) / 60.0
        let incomeValue = totalHours * hourlyRate.value
        
        return Money(value: incomeValue, currency: hourlyRate.currency)
    }
}

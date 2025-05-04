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
        workedTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.secondsWorked += 1
            }
    }
    
    func stopWorkedTimer() {
        workedTimer?.cancel()
    }
    
    func startPausedTimer() {
        pausedTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
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
    
    // MARK: - Hauptberechnung
    
    func getCalculatedWorkingTime(
        secondsWorked: Int,
        secondsPaused: Int,
        targetWorkingHours: Double,
        targetPauseMinutes: Int
    ) -> WorkingTime {
        
        print("secondsWorked: \(secondsWorked)")
        print("secondsPaused: \(secondsPaused)")
        print("targetWorkingHours: \(targetWorkingHours)")
        print("targetPauseMinutes: \(targetPauseMinutes)")
        let (workedHours, workedMinutes) = secondsWorked.toHoursAndMinutes()
        
        let targetWorkingSeconds = Int(targetWorkingHours * 3600)
        let targetPauseSeconds = targetPauseMinutes * 60
        
        var overtimeSeconds = secondsWorked - targetWorkingSeconds
        
        // Abziehen der zu langen Pausen
        if secondsPaused > targetPauseSeconds {
            overtimeSeconds -= (secondsPaused - targetPauseSeconds)
        }
        
        let (overtimeHours, overtimeMinutes) = overtimeSeconds.toSignedHoursAndMinutes()
        
        return WorkingTime(
            hours: workedHours,
            minutes: workedMinutes,
            overtime: Overtime(hours: overtimeHours, minutes: overtimeMinutes)
        )
    }
    
    func getTotalWorkingTime(hours: Int, minutes: Int, overTime: Overtime) -> WorkingTime {
        let totalTime = getTotalTime(hours: hours, minutes: minutes)
        let totalOverTime = getTotalOverTime(overTime: overTime)
        
        return WorkingTime(
            hours: totalTime.hours,
            minutes: totalTime.minutes,
            overtime: totalOverTime
        )
    }

    func getTotalOverTime(overTime: Overtime) -> Overtime {
        let totalTime = getTotalTime(hours: overTime.hours, minutes: overTime.minutes)
        return Overtime(hours: totalTime.hours, minutes: totalTime.minutes)
    }

    func getTotalTime(hours: Int, minutes: Int) -> (hours: Int, minutes: Int) {
        let totalSeconds = (hours * 3600) + (minutes * 60)
        return totalSeconds.toSignedHoursAndMinutes()
    }

    func getCalculatedIncome(hourlyRate: Money, workTime: WorkingTime) -> Money {
        let totalMinutes = (workTime.hours * 60) + workTime.minutes
        let totalHours = Double(totalMinutes) / 60.0
        let incomeValue = totalHours * hourlyRate.value
        let roundedIncomeValue = incomeValue.rounded(toPlaces: 2)
        
        return Money(value: roundedIncomeValue, currency: hourlyRate.currency)
    }
}

 extension Int {
    func toHoursAndMinutes() -> (hours: Int, minutes: Int) {
        var hours = self / 3600
        var minutes = (self % 3600) / 60
        
        if minutes < 0 {
            hours -= 1
            minutes += 60
        }
        
        return (hours, minutes)
    }
}

 extension Int {
    func toSignedHoursAndMinutes() -> (hours: Int, minutes: Int) {
        var totalSeconds = self
        let isNegative = totalSeconds < 0
        totalSeconds = abs(totalSeconds)
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if isNegative {
            return (-hours, minutes)
        } else {
            return (hours, minutes)
        }
    }
}

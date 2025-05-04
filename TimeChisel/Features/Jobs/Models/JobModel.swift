//
//  JobModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 09.02.24.
//

import Foundation
import SwiftData

@Model
class JobModel {
    @Attribute(.unique) var id: UUID
    var companyName: String
    var jobTitle: String
    var workingHoursPerWeek: Int
    var workingDaysPerWeek: Int
    var pauseMinutesPerDay: Int
    var hourlyRate: Money
    @Relationship(deleteRule: .cascade) var timeTrackings: [TimeTrackingModel]
    
    var workingHoursPerDay: Double {
        Double(workingHoursPerWeek) / Double(workingDaysPerWeek)
    }

    init(companyName: String,
         jobTitle: String,
         workingHoursPerWeek: Int,
         workingDaysPerWeek: Int,
         pauseMinutesPerDay: Int,
         hourlyRate: Money) {
        self.id = UUID()
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.workingHoursPerWeek = workingHoursPerWeek
        self.workingDaysPerWeek = workingDaysPerWeek
        self.pauseMinutesPerDay = pauseMinutesPerDay
        self.hourlyRate = hourlyRate
        self.timeTrackings = []
    }
}


extension JobModel {
    var totalWorkingTime: WorkingTime {
        timeTrackings.reduce(WorkingTime(hours: 0, minutes: 0, overtime: Overtime(hours: 0, minutes: 0))) { total, tracking in
            let totalWorkedSeconds = (total.hours * 3600 + total.minutes * 60) + (tracking.workingTime.hours * 3600 + tracking.workingTime.minutes * 60)
            let newWorked = totalWorkedSeconds.toHoursAndMinutes()

            let totalOvertimeSeconds = total.overtime.totalSeconds + tracking.workingTime.overtime.totalSeconds
            let (oH, oM) = totalOvertimeSeconds.toSignedHoursAndMinutes()

            return WorkingTime(
                hours: newWorked.hours,
                minutes: newWorked.minutes,
                overtime: Overtime(hours: oH, minutes: oM)
            )
        }
    }

    var totalIncome: Money {
        let total = timeTrackings.reduce(0.0) { $0 + $1.income.value }
        return Money(value: total.rounded(toPlaces: 2), currency: hourlyRate.currency)
    }
}

extension Int {
    var totalSeconds: Int {
        return self
    }

}

extension Overtime {
    var totalSeconds: Int {
        (hours * 3600) + (minutes * 60)
    }
}

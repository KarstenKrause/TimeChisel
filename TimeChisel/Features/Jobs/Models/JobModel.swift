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
    @Relationship(deleteRule: .cascade, inverse: \TimeTrackingModel.job) var timeTrackings: [TimeTrackingModel]
    
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
    /// Nur abgeschlossene Sessions (mit Enddatum) fließen in die Gesamtsummen ein.
    private var completedTrackings: [TimeTrackingModel] {
        timeTrackings.filter { !$0.isRunning }
    }

    var totalWorkingTime: WorkingTime {
        completedTrackings.reduce(WorkingTime(hours: 0, minutes: 0, overtime: Overtime(seconds: 0))) { total, tracking in
            let totalWorkedSeconds = (total.hours * 3600 + total.minutes * 60) + tracking.workedSeconds()
            let newWorked = totalWorkedSeconds.toHoursAndMinutes()
            let totalOvertimeSeconds = total.overtime.seconds + tracking.workingTime.overtime.seconds

            return WorkingTime(
                hours: newWorked.hours,
                minutes: newWorked.minutes,
                overtime: Overtime(seconds: totalOvertimeSeconds)
            )
        }
    }

    var totalIncome: Money {
        let total = completedTrackings.reduce(0.0) { $0 + ($1.income?.value ?? 0) }
        return Money(value: total.rounded(toPlaces: 2), currency: hourlyRate.currency)
    }
}

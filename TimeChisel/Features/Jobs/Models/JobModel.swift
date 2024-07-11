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
    var totalWorkingTime: WorkingTime
    var totalIncome: Money
    @Relationship(deleteRule: .cascade) var timeTrackings: [TimeTrackingModel]
    
    var workingHoursPerDay: Double {
        return Double( Double(workingHoursPerWeek) / Double(workingDaysPerWeek))
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
        
        self.totalWorkingTime = WorkingTime(hours: 0, minutes: 0, overtime: Overtime(hours: 0, minutes: 0))
        self.totalIncome = Money(value: 0, currency: .EUR)
        
        self.timeTrackings = []
    }
}

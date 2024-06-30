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
    var hourlyRate: HourlyRate
    @Relationship(deleteRule: .cascade) var timeTrackings: [TimeTrackingModel]
    
    var workingHoursPerDay: Double {
        return Double(workingHoursPerWeek / workingDaysPerWeek)
    }
    
    init(companyName: String,
         jobTitle: String,
         workingHoursPerWeek: Int,
         workingDaysPerWeek: Int,
         pauseMinutesPerDay: Int,
         hourlyRate: HourlyRate) {
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

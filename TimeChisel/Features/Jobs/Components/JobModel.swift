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
    var companyName: String
    var jobTitle: String
    var hourlyWage: String
    var workingHoursPerWeek: Int
    var workingDaysPerWeek: Int
    var pauseMinutesPerDay: Int
    
    init(companyName: String, jobTitle: String, hourlyWage: String, workingHoursPerWeek: Int, workingDaysPerWeek: Int, pauseMinutesPerDay: Int) {
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.hourlyWage = hourlyWage
        self.workingHoursPerWeek = workingHoursPerWeek
        self.workingDaysPerWeek = workingDaysPerWeek
        self.pauseMinutesPerDay = pauseMinutesPerDay
    }
    
}

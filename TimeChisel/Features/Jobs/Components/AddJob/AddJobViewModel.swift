//
//  AddJobViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 05.02.24.
//

import SwiftUI
import Observation


@Observable class JobViewModel {
    var companyName = ""
    var jobTitle = ""
    var hourlyWage = ""
    var workingHoursPerWeek = 1
    var workingDaysPerWeek = 1
    var pauseMinutesPerDay = 0
    
    
    init(companyName: String, jobTitle: String, hourlyWage: String, workingHoursPerWeek: Int, workingDaysPerWeek: Int, pauseMinutesPerDay: Int) {
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.hourlyWage = hourlyWage
        self.workingHoursPerWeek = workingHoursPerWeek
        self.workingDaysPerWeek = workingDaysPerWeek
        self.pauseMinutesPerDay = pauseMinutesPerDay
    }
    
}

//
//  AddJobViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 05.02.24.
//

import SwiftUI
import Observation


@Observable 
class JobViewModel {
    var companyName: String
    var jobTitle: String
    var workingHoursPerWeek: Int
    var workingDaysPerWeek: Int
    var pauseMinutesPerDay: Int
    
    init(companyName: String, jobTitle: String, workingHoursPerWeek: Int, workingDaysPerWeek: Int, pauseMinutesPerDay: Int) {
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.workingHoursPerWeek = workingHoursPerWeek
        self.workingDaysPerWeek = workingDaysPerWeek
        self.pauseMinutesPerDay = pauseMinutesPerDay
    }
    
}

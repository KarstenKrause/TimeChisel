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
    var hourlyRate: HourlyRate
    var focus: FocusableField?
    
    init() {
        self.companyName = ""
        self.jobTitle = ""
        self.workingHoursPerWeek = 0
        self.workingDaysPerWeek = 1
        self.pauseMinutesPerDay = 0
        self.hourlyRate = HourlyRate(value: 0, currency: .EUR)
    }
    
    func hourlyRateBinding() -> Binding<Double?> {
        Binding<Double?>(
            get: {
                self.hourlyRate.value > 0 ? self.hourlyRate.value : nil
            },
            
            set: { newValue in
                self.hourlyRate.value = newValue ?? 0
            }
        )
    }
    
    func workingHoursBinding () -> Binding <Int?> {
        Binding<Int?>(
            get: {
                self.workingHoursPerWeek > 0 ? self.workingHoursPerWeek : nil
            },
            set: { newValue in
                self.workingHoursPerWeek = newValue ?? 0
            }
        )
    }
    
    func next() {
        guard let currentInput = focus,
              let lastIndex = FocusableField.allCases.last?.rawValue else { return }
        
        let index = min(currentInput.rawValue + 1, lastIndex)
        self.focus = FocusableField(rawValue: index)
    }
    
    func previous() {
        guard let currentInput = focus,
              let lastIndex = FocusableField.allCases.last?.rawValue else { return }
        
        let index = min(currentInput.rawValue - 1, lastIndex)
        self.focus = FocusableField(rawValue: index)
    }
    
    func dismissKeyboard() {
        self.focus = nil
    }
}

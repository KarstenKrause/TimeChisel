//
//  JobDetailViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 22.07.24.
//

import SwiftUI
import Observation

@Observable
class JobDetailViewModel {
    
    init() {}
    
    func determineOverHoursString(overHours: Int, overMinutes: Int) -> String {
        if overHours < 0 || overMinutes < 0 {
            let overHoursWithoutSign = abs(overHours)
            let overMinutesWithoutSign = abs(overMinutes)
            return "- \(overHoursWithoutSign):\(overMinutesWithoutSign)"
        }
        return "\(overHours):\(overMinutes)"
    }
}

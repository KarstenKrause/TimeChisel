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
        print("display overHours: \(overHours)")
        print("display overMinutes: \(overMinutes)")

        return "\(overHours):\(overMinutes)"
    }
}

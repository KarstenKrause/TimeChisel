//
//  TimeViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 23.06.24.
//

import Foundation
import SwiftUI
import Observation

@Observable
class TimeViewModel {
    var seconds: Int
    var timeType: TimeType
    
    init(seconds: Int, for timeTimeType: TimeType) {
        self.seconds = seconds
        self.timeType = timeTimeType
    }
    
    func getTime() -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = self.seconds % 60
        
        let hoursString = hours < 10 ? "0\(hours)" : "\(hours)"
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        
        return "\(hoursString):\(minutesString):\(secondsString)"
    }
    
    
    
}

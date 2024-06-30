//
//  TimeTrackingModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 30.06.24.
//

import Foundation
import SwiftData

@Model
class TimeTrackingModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var workingTime: WorkingTime
    var pausedTime: PausedTime
    
    init(id: UUID, date: Date, workingTime: WorkingTime, pausedTime: PausedTime) {
        self.id = id
        self.date = date
        self.workingTime = workingTime
        self.pausedTime = pausedTime
    }
}

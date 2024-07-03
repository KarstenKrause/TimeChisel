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
    
    init(date: Date, workingTime: WorkingTime) {
        self.id = UUID()
        self.date = date
        self.workingTime = workingTime
    }
}

//
//  TimeTrackingStatus.swift
//  TimeChisel
//
//  Created by Karsten Krause on 26.06.24.
//

import SwiftUI
import Observation

@Observable
class TimeTrackingStatus {
    var isTracking: Bool = false
}

struct TimeTrackingStatusKey: EnvironmentKey {
    static let defaultValue: TimeTrackingStatus = TimeTrackingStatus()
}

extension EnvironmentValues {
    var timeTrackingStatus: TimeTrackingStatus {
        get { self[TimeTrackingStatusKey.self] }
        set { self[TimeTrackingStatusKey.self] = newValue }
    }
}

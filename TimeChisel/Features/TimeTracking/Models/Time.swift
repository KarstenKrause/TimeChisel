//
//  Time.swift
//  TimeChisel
//
//  Created by Karsten Krause on 30.06.24.
//

import Foundation


protocol TimeProtocol {
    var hours: Int { get set }
    var minutes: Int { get set }
}

struct PausedTime: TimeProtocol, Codable {
    var hours: Int
    var minutes: Int
    var overtime: Overtime
}

struct Overtime: TimeProtocol, Codable {
    var hours: Int
    var minutes: Int
}

struct WorkingTime: TimeProtocol, Codable {
    var hours: Int
    var minutes: Int
    var overtime: Overtime
}

extension WorkingTime {
    var remainingTime: Overtime? {
        if overtime.hours < 0 || overtime.minutes < 0 {
            return Overtime(
                hours: abs(overtime.hours),
                minutes: abs(overtime.minutes)
            )
        }
        return nil
    }
}

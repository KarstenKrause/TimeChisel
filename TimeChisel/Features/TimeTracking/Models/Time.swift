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

struct Overtime: TimeProtocol, Codable {
    var hours: Int
    var minutes: Int
}

struct WorkingTime: TimeProtocol, Codable {
    var hours: Int
    var minutes: Int
    var overtime: Overtime
}

struct PausedTime: TimeProtocol, Codable {
    var hours: Int
    var minutes: Int
    var overtime: Overtime
}

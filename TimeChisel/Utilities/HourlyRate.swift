//
//  HourlyRate.swift
//  TimeChisel
//
//  Created by Karsten Krause on 27.05.24.
//

import Foundation

struct HourlyRate: Codable, Equatable {
    var value: Double
    var currency: Currency
    
    enum Currency: String, CaseIterable, Codable {
        case USD = "$"
        case EUR = "€"
        case GBP = "£"
    }
}

//
//  HourlyRate.swift
//  TimeChisel
//
//  Created by Karsten Krause on 27.05.24.
//

import Foundation

struct Money: Codable, Equatable {
    var value: Double
    var currency: Currency
    
    enum Currency: String, CaseIterable, Codable {
        case USD = "$"
        case EUR = "€"
        case GBP = "£"
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

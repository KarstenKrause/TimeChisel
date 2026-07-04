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

/// Ein einzelnes Pausenintervall. `end == nil` bedeutet, die Pause läuft gerade.
struct Pause: Codable {
    var start: Date
    var end: Date?

    /// Dauer der Pause in Sekunden. Für laufende Pausen wird `now` als vorläufiges Ende verwendet.
    func duration(asOf now: Date = .now) -> TimeInterval {
        (end ?? now).timeIntervalSince(start)
    }
}

/// Über- bzw. Minusstunden als ein einziger vorzeichenbehafteter Sekundenwert.
/// Ein getrenntes Stunden/Minuten-Paar würde das Vorzeichen bei Minuszeiten
/// unter einer Stunde verlieren (−15 min → (0, 15), da -0 == 0).
struct Overtime: Codable {
    var seconds: Int

    var isNegative: Bool { seconds < 0 }
    var hours: Int { abs(seconds) / 3600 }
    var minutes: Int { (abs(seconds) % 3600) / 60 }

    /// Formatiert als vorzeichenbehaftetes "H:MM", z. B. "-0:15" oder "1:30".
    var formatted: String {
        let sign = isNegative ? "-" : ""
        return "\(sign)\(hours):" + String(format: "%02d", minutes)
    }
}

struct WorkingTime: TimeProtocol, Codable {
    var hours: Int
    var minutes: Int
    var overtime: Overtime
}

extension WorkingTime {
    /// Verbleibende Zeit bis zum Tagessoll — nur vorhanden, wenn das Soll noch nicht erreicht ist.
    var remainingTime: Overtime? {
        if overtime.isNegative {
            return Overtime(seconds: -overtime.seconds)
        }
        return nil
    }
}

extension Int {
    func toHoursAndMinutes() -> (hours: Int, minutes: Int) {
        var hours = self / 3600
        var minutes = (self % 3600) / 60

        if minutes < 0 {
            hours -= 1
            minutes += 60
        }

        return (hours, minutes)
    }
}

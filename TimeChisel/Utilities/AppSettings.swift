//
//  AppSettings.swift
//  TimeChisel
//
//  Created by Karsten Krause on 09.07.26.
//

import SwiftUI

/// Darstellungsmodus der App.
enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Hell"
        case .dark: return "Dunkel"
        }
    }

    /// `nil` bedeutet: der Systemeinstellung folgen.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Zentrale UserDefaults-Keys und Defaults der App-Einstellungen.
enum AppSettings {
    static let graceMinutesKey = "scheduledPauseGraceMinutes"
    static let defaultGraceMinutes = 10

    static let appearanceKey = "appearanceMode"

    static let defaultCurrencyKey = "defaultCurrency"

    /// Standardwährung für neue Jobs — Fallback EUR.
    static var defaultCurrency: Money.Currency {
        let raw = UserDefaults.standard.string(forKey: defaultCurrencyKey) ?? ""
        return Money.Currency(rawValue: raw) ?? .EUR
    }
}

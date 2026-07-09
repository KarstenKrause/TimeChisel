//
//  SettingsView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var context
    @Environment(\.timeTrackingStatus) var trackingStatus
    @AppStorage(AppSettings.graceMinutesKey) private var graceMinutes = AppSettings.defaultGraceMinutes
    @AppStorage(AppSettings.appearanceKey) private var appearanceRaw = AppearanceMode.system.rawValue
    @AppStorage(AppSettings.defaultCurrencyKey) private var defaultCurrencyRaw = Money.Currency.EUR.rawValue
    @State private var showingResetDialog = false

    private let graceSelection = [5, 10, 15]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Karenzzeit feste Pausen", selection: $graceMinutes) {
                        ForEach(graceSelection, id: \.self) { minutes in
                            Text("\(minutes) Minuten").tag(minutes)
                        }
                    }
                } header: {
                    Text("Zeiterfassung")
                } footer: {
                    Text("Bei festen Arbeitszeiten kann die Pause so viele Minuten vor dem geplanten Beginn manuell gestartet werden — genauso viele Minuten danach startet sie automatisch.")
                }

                Section("Darstellung") {
                    Picker("Erscheinungsbild", selection: $appearanceRaw) {
                        ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    }
                }

                Section {
                    Picker("Standardwährung", selection: $defaultCurrencyRaw) {
                        ForEach(Money.Currency.allCases, id: \.rawValue) { currency in
                            Text(currency.rawValue).tag(currency.rawValue)
                        }
                    }
                } header: {
                    Text("Jobs")
                } footer: {
                    Text("Vorbelegte Währung beim Anlegen neuer Jobs.")
                }

                Section("Daten") {
                    Button("Alle Aufzeichnungen löschen", role: .destructive) {
                        showingResetDialog = true
                    }
                }

                Section("Über") {
                    LabeledContent("Version", value: bundleValue("CFBundleShortVersionString"))
                    LabeledContent("Build", value: bundleValue("CFBundleVersion"))
                }
            }
            .navigationTitle("Einstellungen")
            .confirmationDialog("Alle Aufzeichnungen löschen?", isPresented: $showingResetDialog) {
                Button("Löschen", role: .destructive) {
                    deleteAllTrackings()
                }

                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Alle Zeiterfassungen werden endgültig gelöscht. Jobs bleiben erhalten.")
            }
        }
    }

    private func bundleValue(_ key: String) -> String {
        Bundle.main.infoDictionary?[key] as? String ?? "—"
    }

    /// Löscht alle Sessions einzeln statt per Batch-Delete, damit SwiftData die
    /// Job-Beziehungen sauber aktualisiert. Beendet auch eine laufende Erfassung.
    private func deleteAllTrackings() {
        let allTrackings = (try? context.fetch(FetchDescriptor<TimeTrackingModel>())) ?? []
        for tracking in allTrackings {
            context.delete(tracking)
        }
        trackingStatus.isTracking = false
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobModel.self, TimeTrackingModel.self, configurations: config)

    return SettingsView().modelContainer(container)
}

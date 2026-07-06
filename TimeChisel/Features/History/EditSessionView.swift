//
//  EditSessionView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 06.07.26.
//

import SwiftUI
import SwiftData

/// Sheet zum nachträglichen Korrigieren einer abgeschlossenen Zeiterfassung.
/// Änderungen werden erst beim Speichern auf das Model geschrieben; der Verdienst
/// wird dabei mit dem aktuellen Stundenlohn des Jobs neu berechnet.
struct EditSessionView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var session: TimeTrackingModel

    @State private var startDate: Date
    @State private var endDate: Date
    @State private var pauses: [Pause]

    init(session: TimeTrackingModel) {
        self.session = session
        _startDate = State(initialValue: session.startDate)
        _endDate = State(initialValue: session.endDate ?? session.startDate)
        _pauses = State(initialValue: session.pauses)
    }

    private var validationError: String? {
        guard endDate > startDate else {
            return "Das Ende muss nach dem Start liegen."
        }

        for pause in pauses {
            guard let pauseEnd = pause.end else {
                return "Jede Pause braucht ein Ende."
            }
            guard pauseEnd > pause.start else {
                return "Das Pausen-Ende muss nach dem Pausen-Beginn liegen."
            }
            guard pause.start >= startDate, pauseEnd <= endDate else {
                return "Pausen müssen innerhalb der Arbeitszeit liegen."
            }
        }

        return nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Arbeitszeit") {
                    DatePicker("Start", selection: $startDate)
                    DatePicker("Ende", selection: $endDate)
                }

                Section("Pausen") {
                    ForEach(pauses.indices, id: \.self) { index in
                        pauseEditor(at: index)
                    }
                    .onDelete { offsets in
                        pauses.remove(atOffsets: offsets)
                    }

                    Button("Pause hinzufügen") {
                        addPause()
                    }
                }

                if let validationError {
                    Section {
                        Text(validationError)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        save()
                        dismiss()
                    }
                    .disabled(validationError != nil)
                }
            }
        }
    }

    private func pauseEditor(at index: Int) -> some View {
        VStack(alignment: .leading) {
            if pauses[index].source == .automatic {
                Text("Automatische Pause — wird beim Ändern zur manuellen")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            DatePicker("Beginn", selection: pauseStartBinding(at: index), displayedComponents: .hourAndMinute)
            DatePicker("Ende", selection: pauseEndBinding(at: index), displayedComponents: .hourAndMinute)
        }
    }

    /// Bearbeitete Pausen gelten als manuell — die Automatik-Kennzeichnung wäre sonst irreführend.
    private func pauseStartBinding(at index: Int) -> Binding<Date> {
        Binding(
            get: { pauses[index].start },
            set: { newValue in
                pauses[index].start = newValue
                pauses[index].source = .manual
            }
        )
    }

    private func pauseEndBinding(at index: Int) -> Binding<Date> {
        Binding(
            get: { pauses[index].end ?? pauses[index].start },
            set: { newValue in
                pauses[index].end = newValue
                pauses[index].source = .manual
            }
        )
    }

    private func addPause() {
        let midpoint = startDate.addingTimeInterval(endDate.timeIntervalSince(startDate) / 2)
        let end = min(midpoint.addingTimeInterval(30 * 60), endDate)
        pauses.append(Pause(start: midpoint, end: end, source: .manual))
    }

    private func save() {
        session.startDate = startDate
        session.endDate = endDate
        session.pauses = pauses

        if let job = session.job {
            let totalHours = Double(session.workedSeconds()) / 3600.0
            session.income = Money(
                value: (totalHours * job.hourlyRate.value).rounded(toPlaces: 2),
                currency: job.hourlyRate.currency
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobModel.self, TimeTrackingModel.self, configurations: config)

    let job = JobModel(companyName: "DTS", jobTitle: "Software Entwickler", workingHoursPerWeek: 40, workingDaysPerWeek: 5, pauseMinutesPerDay: 30, hourlyRate: Money(value: 25, currency: .EUR))
    container.mainContext.insert(job)

    let start = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
    let session = TimeTrackingModel(startDate: start)
    container.mainContext.insert(session)
    session.job = job
    session.pauses = [Pause(start: start.addingTimeInterval(4 * 3600), end: start.addingTimeInterval(4 * 3600 + 30 * 60), source: .automatic)]
    session.finish(hourlyRate: job.hourlyRate, at: start.addingTimeInterval(8 * 3600 + 30 * 60))

    return EditSessionView(session: session)
        .modelContainer(container)
}

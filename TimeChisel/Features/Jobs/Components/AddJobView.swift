//
//  AddJobView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 04.02.24.
//

import SwiftUI
import SwiftData

struct AddJobView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Bindable var jobVM = JobViewModel()
    @FocusState var focus: FocusableField?
    let pauseSelection: [Int] = [15, 30, 45, 60]
    let daysSelection: [Int] = [1, 2, 3, 4, 5, 6]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Jobinfos") {
                        TextField("Name des Unternehmens", text: $jobVM.companyName)
                            .focused($focus, equals: .company)
                        
                        TextField("Job-Titel", text: $jobVM.jobTitle)
                            .focused($focus, equals: .jobTitle)
                        
                        HStack {
                            TextField("Stundenlohn", value: jobVM.hourlyRateBinding(), format: .number)
                                .keyboardType(.decimalPad)
                                .focused($focus, equals: .hourlyRate)
                            
                            Picker("", selection: $jobVM.hourlyRate.currency) {
                                ForEach(Money.Currency.allCases, id: \.self) { currency in
                                    Text(currency.rawValue).tag(currency)
                                }
                            }
                        }
                    }
                    
                    Section("Arbeitszeiten") {
                        TextField("Stunden pro Woche", value: jobVM.workingHoursBinding(), format: .number)
                            .keyboardType(.decimalPad)
                            .focused($focus, equals: .workingHours)
                        
                        Picker("Tage pro Woche", selection: $jobVM.workingDaysPerWeek) {
                            ForEach(daysSelection, id: \.self) { days in
                                Text("\(days) Tage").tag(days)
                            }
                        }
                        
                        Picker("Pause am Tag", selection: $jobVM.pauseMinutesPerDay) {
                            ForEach(pauseSelection, id: \.self) { minutes in
                                Text("\(minutes) Minuten").tag(minutes)
                            }
                        }
                    }
                    
                    Section {
                        HStack{
                            Button(action: {
                                addJob()
                                dismiss()
                            }, label: {
                                Text("Speichern")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            })
                            .disabled((jobVM.companyName.isEmpty || jobVM.jobTitle.isEmpty))
                        }
                    }
                    .buttonStyle(.borderless)
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle("Job hinzufügen")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button {
                            jobVM.previous()
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        
                        Button {
                            jobVM.next()
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        
                        Spacer()
                        
                        Button("Fertig") {
                            jobVM.dismissKeyboard()
                        }
                        
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Label("Schließen", systemImage: "xmark.circle.fill")
                        })
                    }
                }
            }
        }
        .focusStateSync($jobVM.focus, with: _focus)
    }
    
    private func addJob() {
        let job: JobModel = JobModel(companyName: jobVM.companyName, jobTitle: jobVM.jobTitle, workingHoursPerWeek: jobVM.workingHoursPerWeek, workingDaysPerWeek: jobVM.workingDaysPerWeek, pauseMinutesPerDay: jobVM.pauseMinutesPerDay, hourlyRate: jobVM.hourlyRate )
        
        print("Working days saved: \(jobVM.workingDaysPerWeek)")
        
        context.insert(job)
        try! context.save()
    }
}

#Preview {
    AddJobView()
}


//
//  AddExpenseView.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddExpenseView: View {
    @Environment(\.modelContext) var modelContext
    @Binding var isPresented: Bool
    @State private var selectedItem: PhotosPickerItem?
    @State private var date: Date = Date()
    @State private var total: String = ""
    @State private var currency: String = Locale.current.currency?.identifier ?? "RON"
    @State private var type: ExpenseType = .receipt
    @State var photoData: Data?
    let currencies: [String] = NSLocale.isoCurrencyCodes
    
    var body: some View {
        HStack {
            Button("Cancel") {
                isPresented = false
            }.padding()
            Spacer()
            Button("Save") {
                addExpense()
                isPresented = false
            }.padding()
        }
        Form {
            Section {
                if let imageData = photoData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Select a photo", systemImage: "camera")
                }
            }
            Section {
                Picker("Type", selection: $type) {
                    ForEach(ExpenseType.allCases, id: \.self) { type in
                        Text(type.description).tag(Optional(type))
                    }
                }
                Picker("Currency", selection: $currency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField(text: $total, prompt: Text("Amount")) {
                        Text("Amount")
                    }
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numbersAndPunctuation)
                        
                }
                DatePicker("Expense date",
                            selection: $date,
                            displayedComponents: [.date])
                            .datePickerStyle(.automatic)
            }
        }
        .onChange(of: selectedItem, loadPhoto)
    }
    
    private func addExpense() {
        let newItem = Expense(date: date, total: Double(total) ?? 0, currency: currency, photoData: photoData, type: type)
        modelContext.insert(newItem)
    }
    
    func loadPhoto() {
        Task { @MainActor in
            photoData = try await selectedItem?.loadTransferable(type: Data.self)
        }
    }
}

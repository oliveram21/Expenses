//
//  EditExpenseView.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import PhotosUI
import SwiftData

struct ExpenseView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.createDataHandler) private var createDataHandler
    @Environment(\.dismiss) private var dismiss
    var expense: Expense?
    let currencies: [String] = NSLocale.isoCurrencyCodes
    @State var photoData: Data?
    @State var expenceType: ExpenseType = .invoice
    @State var date: Date = Date()
    @State var total: Double = 0
    @State var currency: String = "RON"
    @State var expenseID: PersistentIdentifier?
    @State private var showCamera = false
   
    var body: some View {
        Form {
            Section {
                if let imageData = photoData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
                HStack {
                    Button("Take photo", systemImage: "camera") {
                        self.showCamera.toggle()
                        
                    }
                    .foregroundColor(.expenseLabel)
                    .fullScreenCover(isPresented: self.$showCamera) {
                        CameraView(selectedImage: $photoData)
                    }
              }
            }
            Section {
                Picker("Type", selection: $expenceType) {
                    ForEach(ExpenseType.allCases, id: \.self) { type in
                        Text(type.description).tag(Optional(type))
                    }
                }
                .tint(.secondary)
                .fontWeight(.semibold)
                .foregroundStyle(.expenseLabel)
                Picker("Currency", selection: $currency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .tint(.secondary)
                .fontWeight(.semibold)
                .foregroundStyle(.expenseLabel)
                HStack {
                    Text("Amount")
                        .tint(.secondary)
                        .fontWeight(.semibold)
                        .foregroundStyle(.expenseLabel)
                    Spacer()
                    TextField("Amount", value: $total, format: .number)
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numbersAndPunctuation)
                    .foregroundStyle(.secondary)
                        
                }
                DatePicker("Expense date",selection: $date, displayedComponents: [.date])
                .datePickerStyle(.automatic)
                .tint(.secondary)
                .fontWeight(.semibold)
                .foregroundStyle(.expenseLabel)
            }
        }
        .toolbar() {
            ToolbarItem(placement: .topBarTrailing) {
                ToolBarContent()
            }
        }.onAppear() {
            if let expense = expense {
                photoData = expense.photo
                expenceType =  expense.type
                total = expense.total
                currency = expense.currency
                date = expense.date
                expenseID = expense.persistentModelID
            }
        }
    }
    @ViewBuilder
    func ToolBarContent() -> some View {
        Button("Save") {
            saveExpense()
            dismiss()
        }
    }
    
    fileprivate func saveExpense() {
        let sendableExpense = SendableExpenseModel(date:date,
                                                   total: total,
                                                   currency: currency,
                                                   photoData: photoData,
                                                   type: expenceType,
                                                   persistentId: expenseID)
        let createDataHandler = createDataHandler
        let isNewExpense = (expense == nil)
        Task.detached {
            let dataHandler = await createDataHandler()
            do {
                if isNewExpense {
                    try await dataHandler.newData(sendableExpense)
                } else {
                    try await dataHandler.update(sendableExpense)
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    let previewer = Previewer()
    return ExpenseView(expense: previewer.expense)
        .modelContainer(previewer.container)
}


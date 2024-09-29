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
    @Environment(\.dismiss) private var dismiss
    @Environment(ExpensesStore.self) var expensesStore: ExpensesStore
    var expenseId: UUID?
    @SceneStorage("ExpenseView.photoData") var photoData: Data?
    @SceneStorage("ExpenseView.expenceType") var expenceType: ExpenseType = .invoice
    @SceneStorage("ExpenseView.date") var date = Date()
    @SceneStorage("ExpenseView.total") var total: Double = 0
    @SceneStorage("ExpenseView.currency") var currency: String = "RON"
    @SceneStorage("ExpenseView.showCamera")  var showCamera = false
    
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
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraView(selectedImage: $photoData)
                            .ignoresSafeArea()
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
                    ForEach(expensesStore.currencies, id: \.self) { currency in
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
                DatePicker("Expense date",selection:$date, displayedComponents: [.date])
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
            if let expenseId = expenseId {
                Task {
                    if let expense = await expensesStore.searchExpenseById(id: expenseId) {
                        updateFromExpense(expense: expense)
                    }
                }
                
            }
        }
    }
    @ViewBuilder @MainActor
    func ToolBarContent() -> some View {
        Button("Save") {
            dismiss()
            saveExpense()
        }
    }
    @MainActor
    fileprivate func saveExpense() {
        let isNewExpense = (expenseId == nil)
        let sendableExpense = SendableExpenseModel(date: date,
                                                   total: total,
                                                   currency: currency,
                                                   photoData: photoData,
                                                   type: expenceType,
                                                   id: expenseId
                                                   )
       
        Task{
            await expensesStore.saveExpense(sendableExpense, isNew: isNewExpense)
        }
        //reset state to initial state in order to cleanup scenestorage.
        resetStateToDefaultValues()
    }
    
    func resetStateToDefaultValues() {
        photoData = nil
        expenceType = .invoice
        date = Date()
        total = 0
        currency = "RON"
        showCamera = false
    }
    
    func updateFromExpense(expense: SendableExpenseModel) {
        photoData = expense.photo
        expenceType =  ExpenseType.init(rawValue: expense.type) ?? .invoice
        total = expense.total
        currency = expense.currency
        date = expense.date
    }
}

#Preview {
    struct ExpensePreviewContainer : View {
       var body: some View {
           NavigationStack {
               ExpenseView()
           }
       }
    }
    let previewer = Previewer()
    return ExpensePreviewContainer()
        .environment(previewer.expensesStore)
}

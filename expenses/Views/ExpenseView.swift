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
    @Bindable var expense: Expense
    @State private var selectedItem: PhotosPickerItem?
    let currencies: [String] = NSLocale.isoCurrencyCodes
    
    var body: some View {
        Form {
            Section {
                if let imageData = expense.photo, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Select a photo", systemImage: "camera")
                }
            }
            Section {
                Picker("Type", selection: $expense.type) {
                    ForEach(ExpenseType.allCases, id: \.self) { type in
                        Text(type.description).tag(Optional(type))
                    }
                }
                Picker("Currency", selection: $expense.currency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $expense.total, format: .number)
                   
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numbersAndPunctuation)
                        
                }
                DatePicker("Expense date",
                           selection: $expense.date,
                            displayedComponents: [.date])
                            .datePickerStyle(.automatic)
            }
        }
        .onChange(of: selectedItem, loadPhoto)
    }
   
    func loadPhoto() {
        Task { @MainActor in
            expense.photo = try await selectedItem?.loadTransferable(type: Data.self)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return ExpenseView(expense: previewer.expense)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}


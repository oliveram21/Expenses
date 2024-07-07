//
//  ExpenseTypyView.swift
//  expenses
//
//  Created by Olivera Miatovici on 07.07.2024.
//

import SwiftUI

struct ExpenseTypeView: View {
    var text: String
    
    var body: some View {
        ZStack {
            Color.purple
            Text(text)
        }
        .frame(width: 41, height: 41)
        .cornerRadius(11)
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return ExpenseTypeView(text: previewer.expense.type.rawValue.first!.uppercased())
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

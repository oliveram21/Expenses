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
            Color.expenseTint
            Text(text)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .frame(width: 41, height: 41)
        .cornerRadius(11)
    }
}

#Preview {
    return ExpenseTypeView(text: "R")
}

//
//  expensesApp.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData

@main
struct expensesApp: App {
    let dataProvider = DataProvider.shared
   
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ExpensesStore(createHandler: dataProvider.dataHandlerCreator()))

        }
    }
}

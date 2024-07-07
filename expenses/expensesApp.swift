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
            .environment(\.createDataHandler, dataProvider.dataHandlerCreator())
            .environment(\.createDataHandlerWithMainContext, dataProvider.dataHandlerWithMainContextCreator())
        }
        .modelContainer(dataProvider.sharedModelContainer)    }
}

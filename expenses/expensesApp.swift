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
           
            ContentView(modelContext: dataProvider.sharedModelContainer.mainContext, createDataHandler: dataProvider.dataHandlerCreator())
        }
        .modelContainer(dataProvider.sharedModelContainer)
    }
}

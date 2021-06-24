//
//  DevoteApp.swift
//  Devote
//
//  Created by Erik Salas on 6/17/21.
//

import SwiftUI

@main
struct DevoteApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                //the managedObjectContext is injected for the core data container in the whole SwiftUI app hierarchy and it's all child views
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

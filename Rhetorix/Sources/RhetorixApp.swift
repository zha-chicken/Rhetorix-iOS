import SwiftUI

@main
struct RhetorixApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .task {
                    store.bootstrap()
                }
        }
    }
}


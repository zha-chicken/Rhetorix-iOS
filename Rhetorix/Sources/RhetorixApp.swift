import SwiftUI

@main
struct RhetorixApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.appTheme.colorScheme)
                .task {
                    store.bootstrap()
                }
        }
    }
}

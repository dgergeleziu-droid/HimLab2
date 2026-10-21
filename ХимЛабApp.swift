import SwiftUI

@main
struct HimLabApp: App {
    @StateObject private var store = ProgressStore.shared
    @StateObject private var content = ContentLoader.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(content)
                .preferredColorScheme(nil)
        }
    }
}
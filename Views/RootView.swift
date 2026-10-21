import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader
    @State private var showAI = false

    var body: some View {
        TabView {
            HomeView(showAI: $showAI)
                .tabItem { Label("Главная", systemImage: "house.fill") }
            LearnView()
                .tabItem { Label("Учиться", systemImage: "book.fill") }
            LabView()
                .tabItem { Label("Лаборатория", systemImage: "flask.fill") }
            GamesView()
                .tabItem { Label("Игры", systemImage: "gamecontroller.fill") }
            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
        }
        .sheet(isPresented: $showAI) {
            AIView()
                .environmentObject(store)
                .environmentObject(content)
        }
    }
}

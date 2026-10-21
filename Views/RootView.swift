import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var showAI = false

    var body: some View {
        TabView {
            HomeView(showAI: $showAI)
                .tabItem { Label("Главная", systemImage: "house.fill") }
            
            LearnView()
                .tabItem { Label("Учиться", systemImage: "book.fill") }
            
            // Новая вкладка каталога реакций из сети
            ReactionsView()
                .tabItem { Label("Реакции", systemImage: "arrow.left.arrow.right") }
            
            LabView()
                .tabItem { Label("Лаборатория", systemImage: "flask.fill") }
            
            GamesView()
                .tabItem { Label("Игры", systemImage: "gamecontroller.fill") }
            
            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
        }
        .tint(.teal)
        .sheet(isPresented: $showAI) {
            AIView()
                .environmentObject(store)
                .environmentObject(ContentLoader.shared)
        }
    }
}

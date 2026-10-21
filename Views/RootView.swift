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
            LabView()
                .tabItem { Label("Лаборатория", systemImage: "flask.fill") }
            GamesView()
                .tabItem { Label("Игры", systemImage: "gamecontroller.fill") }
            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
        }
        .tint(.teal) // Задаем основной цвет приложения
        .sheet(isPresented: $showAI) {
            AIView().environmentObject(store)
        }
    }
}

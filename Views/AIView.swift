import SwiftUI

struct AIView: View {
    var articleTitle: String? = nil
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader
    @Environment(\.dismiss) private var dismiss

    @State private var messages: [AIMessage] = []
    @State private var input = ""
    @State private var loading = false
    @State private var errorText: String?
    @State private var showPrivacy = false
    @State private var agreed = false

    private let service: AIService = MockAIService()   // позже: RemoteAIService(endpoint: URL(...)!)

    var body: some View {
        NavigationStack {
            VStack {
                if !agreed {
                    privacyPanel
                } else {
                    chatPanel
                }
            }
            .navigationTitle("ИИ-помощник")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }

    private var privacyPanel: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield").font(.largeTitle).foregroundStyle(.purple)
            Text("При подключении сетевого ИИ текст ваших вопросов будет отправляться на сервер. Имя, возраст и другие личные данные не отправляются.")
                .multilineTextAlignment(.center)
            Button("Понятно, продолжить") { agreed = true }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var chatPanel: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🤖 Демонстрационный режим. Это не настоящий ИИ.")
                            .font(.caption).foregroundStyle(.orange)
                        ForEach(messages) { m in
                            messageBubble(m).id(m.id)
                        }
                        if loading { ProgressView().padding() }
                        if let e = errorText {
                            HStack {
                                Text(e).foregroundStyle(.red)
                                Button("Повторить") { sendLast() }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last { withAnimation { proxy.scrollTo(last.id) } }
                }
            }
            quickButtons
            HStack {
                TextField("Ваш вопрос…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button {
                    send(input)
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || loading)
            }
            .padding()
        }
    }

    private var quickButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(["Объясни проще", "Дай подсказку", "Разбери пример", "Проверь мой ответ"], id: \.self) { t in
                    Button(t) { send(t) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
            .padding(.horizontal)
        }
    }

    private func messageBubble(_ m: AIMessage) -> some View {
        HStack {
            if m.role == .user { Spacer() }
            Text(m.text)
                .padding(10)
                .background(m.role == .user ? Color.accentColor.opacity(0.2)
                                            : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            if m.role == .assistant { Spacer() }
        }
    }

    private func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        messages.append(AIMessage(role: .user, text: trimmed))
        input = ""
        loading = true
        errorText = nil
        Task {
            do {
                let reply = try await service.send(
                    question: trimmed,
                    grade: store.data.selectedGrade,
                    articleTitle: articleTitle,
                    taskText: nil
                )
                messages.append(AIMessage(role: .assistant, text: reply))
            } catch {
                errorText = "Ошибка: \(error.localizedDescription)"
            }
            loading = false
        }
    }

    private func sendLast() {
        if let last = messages.last(where: { $0.role == .user }) {
            send(last.text)
        }
    }
}

import SwiftUI
import EventKit

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let description: String
}

struct ContentView: View {
    @State private var events: [Event] = [
        Event(title: "Концерт в парке", date: Date().addingTimeInterval(3600*24), description: "Живой концерт в городском парке."),
        Event(title: "Выставка в музее", date: Date().addingTimeInterval(3600*48), description: "Современное искусство."),
        Event(title: "Ярмарка на площади", date: Date().addingTimeInterval(3600*72), description: "Городская ярмарка с едой и музыкой.")
    ]
    
    var body: some View {
        ZStack {
            ForEach(events) { event in
                EventCard(event: event) {
                    removeEvent(event)
                }
            }
        }
        .padding()
    }
    
    func removeEvent(_ event: Event) {
        withAnimation {
            events.removeAll { $0.id == event.id }
        }
    }
}

struct EventCard: View {
    let event: Event
    var onRemove: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var showMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(event.title)
                .font(.largeTitle)
                .bold()
            
            Text(event.date.formatted(date: .long, time: .shortened))
                .foregroundColor(.gray)
            
            Text(event.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                addToCalendar(event: event)
                showMessage = true
            }) {
                Label("Добавить в календарь", systemImage: "calendar.badge.plus")
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 400)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 150 {
                        onRemove()
                    } else {
                        offset = .zero
                    }
                }
        )
        .alert("Событие добавлено!", isPresented: $showMessage) {
            Button("OK", role: .cancel) {}
        }
    }
    
    func addToCalendar(event: Event) {
        let store = EKEventStore()
        store.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                let ekEvent = EKEvent(eventStore: store)
                ekEvent.title = event.title
                ekEvent.startDate = event.date
                ekEvent.endDate = event.date.addingTimeInterval(2 * 60 * 60)
                ekEvent.notes = event.description
                ekEvent.calendar = store.defaultCalendarForNewEvents
                do {
                    try store.save(ekEvent, span: .thisEvent)
                    print("Событие добавлено в календарь")
                } catch {
                    print("Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
}





#Preview {
    ContentView()
}

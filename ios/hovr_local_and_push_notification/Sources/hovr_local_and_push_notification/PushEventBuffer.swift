import Flutter
import Foundation

final class PushEventBuffer {
    private var sink: FlutterEventSink?
    private var pending: [[String: Any?]] = []

    func attach(_ sink: @escaping FlutterEventSink) {
        self.sink = sink
        flushPending()
    }

    func detach() {
        sink = nil
    }

    func emit(_ event: [String: Any?]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let sink = self.sink {
                sink(event)
                return
            }
            if self.pending.count >= NotificationLimits.maxPendingEvents {
                self.pending.removeFirst()
            }
            self.pending.append(event)
        }
    }

    private func flushPending() {
        guard let sink else { return }
        let toSend = pending
        pending.removeAll()
        for event in toSend {
            sink(event)
        }
    }
}

import Foundation
import Combine

class CombineTimer {
    private let intervalSubject: CurrentValueSubject<TimeInterval, Never>

    var interval: TimeInterval {
        get {
            intervalSubject.value
        }
        set {
            intervalSubject.send(newValue)
        }
    }

    var publisher: AnyPublisher<Date, Never> {
        intervalSubject
            .map {
                Timer.TimerPublisher(interval: $0, runLoop: .main, mode: .default).autoconnect()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    init(interval: TimeInterval = 1.0) {
        intervalSubject = CurrentValueSubject<TimeInterval, Never>(interval)
    }

}

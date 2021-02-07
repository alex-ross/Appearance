import Foundation
import Combine
import SwiftUI

struct Theme {
    var objectDidChange = PassthroughSubject<Theme, Never>()

    var colorScheme: ColorScheme {
        didSet {
            if oldValue != colorScheme {
                objectDidChange.send(self)
            }
        }
    }
}

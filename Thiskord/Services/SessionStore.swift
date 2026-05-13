import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var currentUser: String = ""
    @Published private(set) var currentUserId: Int?
    @Published private(set) var token: String = ""

    var isLoggedIn: Bool {
        !token.isEmpty
    }

    func login(user: User, token: String) {
        currentUser = user.userName
        currentUserId = user.userId
        self.token = token
    }

    func logout() {
        currentUser = ""
        currentUserId = nil
        token = ""
    }
}

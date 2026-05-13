//
//  ContentView.swift
//  Thiskord
//
//  Created by Julien Ejupi on 12/05/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if session.isLoggedIn {
                NavigatorView()
            } else {
                LoginView()
            }
        }
        .environmentObject(session)
    }
}

#Preview {
    ContentView()
}

//
//  AuthViewModel.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import Foundation
import KeychainAccess
import Combine

class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    
    private let keychain = Keychain(service: "com.thirdparty_ios")
    private let tokenKey = "authToken"
    
    init() {
        checkIfLoggedIn()
    }
    
    func checkIfLoggedIn() {
        if let _ = try? keychain.get(tokenKey) {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
    
    func saveToken(_ token: String) {
        do {
            try keychain.set(token, key: tokenKey)
            isLoggedIn = true
        } catch {
            print("Failed to save token: \(error)")
        }
    }
    
    func logout() {
        do {
            try keychain.remove(tokenKey)
            isLoggedIn = false
        } catch {
            print("Failed to remove token: \(error)")
        }
    }
    
    func getToken() -> String? {
        return try? keychain.get(tokenKey)
    }
}

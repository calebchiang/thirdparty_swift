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
    
    func signInWithApple(identityToken: String) {
        guard let url = URL(string: "https://thirdpartyserver-production.up.railway.app/apple_login") else {
            print("Invalid backend URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["identityToken": identityToken]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            print("Failed to encode identity token")
            return
        }

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {

                if let error = error {
                    print("Apple login error:", error.localizedDescription)
                    return
                }

                guard let data,
                      let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response from backend")
                    return
                }

                guard httpResponse.statusCode == 200 else {
                    print("Backend returned status:", httpResponse.statusCode)
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {

                    self.saveToken(token)
                    print("Apple login successful")

                } else {
                    print("Invalid JSON format from backend")
                }
            }
        }.resume()
    }
}

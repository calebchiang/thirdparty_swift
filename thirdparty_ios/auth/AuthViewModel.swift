//
//  AuthViewModel.swift
//  thirdparty_ios
//

import Foundation
import KeychainAccess
import Combine
import RevenueCat

class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    private let keychain = Keychain(service: "com.thirdparty_ios")
    private let tokenKey = "authToken"
    
    private let baseURL = "https://thirdpartyserver-production.up.railway.app"
    
    init() {
        checkIfLoggedIn()
    }
    
    // MARK: - Session Check
    
    func checkIfLoggedIn() {
        if let _ = try? keychain.get(tokenKey) {
            isLoggedIn = true
            fetchCurrentUser()
        } else {
            isLoggedIn = false
        }
    }
    
    // MARK: - Token Handling
    
    func saveToken(_ token: String) {
        do {
            try keychain.set(token, key: tokenKey)
            isLoggedIn = true
            fetchCurrentUser()
        } catch {
            print("Failed to save token: \(error)")
        }
    }
    
    func logout() {
        do {
            try keychain.remove(tokenKey)
            currentUser = nil
            isLoggedIn = false
            
            // Also log out RevenueCat
            Purchases.shared.logOut { _, _ in }
            
        } catch {
            print("Failed to remove token: \(error)")
        }
    }
    
    func getToken() -> String? {
        return try? keychain.get(tokenKey)
    }
        
    func fetchCurrentUser() {
        
        RequestManager.shared.sendRequest(
            endpoint: "/users/me",
            method: "GET",
            responseType: User.self
        ) { result in
            
            switch result {
            case .success(let fetchedUser):
                
                self.currentUser = fetchedUser
                
                Purchases.shared.logIn(String(fetchedUser.id)) { _, _, error in
                    if let error = error {
                        print("RevenueCat login failed:", error.localizedDescription)
                    } else {
                        print("RevenueCat identified user:", fetchedUser.id)
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch current user:", error)
            }
        }
    }
    
    // MARK: - RevenueCat Identification
    
    private func identifyRevenueCatUser(with userID: Int) {
        Purchases.shared.logIn(String(userID)) { _, _, error in
            if let error = error {
                print("RevenueCat login failed:", error.localizedDescription)
            } else {
                print("RevenueCat identified as user:", userID)
            }
        }
    }
    
    // MARK: - Apple Login
    
    func signInWithApple(identityToken: String) {
        guard let url = URL(string: "\(baseURL)/apple_login") else {
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
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Invalid response from backend")
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

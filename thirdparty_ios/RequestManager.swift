//
//  RequestManager.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import Foundation
import KeychainAccess

final class RequestManager {
    
    static let shared = RequestManager()
    
    private let keychain = Keychain(service: "com.thirdparty_ios")
    
    private let baseURL = URL(string: "https://thirdpartyserver-production.up.railway.app")!
    
    private init() {}
        
    func sendRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let token = try? keychain.get("authToken") else {
            completion(.failure(APIError.missingToken))
            return
        }
        
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    print("❌ Network error:", error)
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    completion(.failure(APIError.noData))
                    return
                }
                
                // 🔥 PRINT RAW BACKEND RESPONSE
                if let rawString = String(data: data, encoding: .utf8) {
                    print("====================================")
                    print("🔥 RAW BACKEND RESPONSE for \(endpoint)")
                    print(rawString)
                    print("====================================")
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    print("✅ Decoding succeeded")
                    completion(.success(decoded))
                } catch {
                    print("❌ Decoding failed:", error)
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
    
    enum APIError: Error {
        case missingToken
        case invalidURL
        case noData
    }
    
    func uploadArgument(
        personAName: String,
        personBName: String,
        persona: String,
        audioURL: URL,
        completion: @escaping (Result<ArgumentResponse, Error>) -> Void
    ) {
        guard let token = try? keychain.get("authToken") else {
            completion(.failure(APIError.missingToken))
            return
        }
        
        guard let url = URL(string: "/arguments", relativeTo: baseURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        func appendField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        appendField(name: "person_a_name", value: personAName)
        appendField(name: "person_b_name", value: personBName)
        appendField(name: "persona", value: persona)
        
        if let audioData = try? Data(contentsOf: audioURL) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"live_recording.m4a\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
            body.append(audioData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                if let http = response as? HTTPURLResponse {
                    if http.statusCode == 401 {
                        print("Unauthorized. Token likely invalid.")
                    }
                }
                
                do {
                    let decoded = try JSONDecoder().decode(ArgumentResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    print(String(data: data, encoding: .utf8) ?? "")
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
}

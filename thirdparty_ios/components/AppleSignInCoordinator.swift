//
//  AppleSignInCoordinator.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import Foundation
import AuthenticationServices
import UIKit

class AppleSignInCoordinator: NSObject {
    
    static let shared = AppleSignInCoordinator()
    
    var authViewModel: AuthViewModel?
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8),
              let auth = authViewModel else {
            return
        }
        
        auth.signInWithApple(identityToken: tokenString)
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        print("Apple Sign-In failed:", error.localizedDescription)
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}

//
//  AppleLoginManager.swift
//  Wedgram
//
//  Created by WC IOS 01 on 01/02/22.
//

import Foundation
import UIKit
import AuthenticationServices


class AppleLoginManager: NSObject {
    
    private var delegate: SocialLoginManagerDelegate?
    
    var onPresent:UIViewController?
    
    init(delegate: SocialLoginManagerDelegate?,viewController:UIViewController) {
        super.init()
        self.delegate = delegate
        self.onPresent = viewController
    }
    
    deinit {
        Logger.log("Going")
    }
    
    /**
     handle LogIn With AppleID
     */
    func handleLogInWithAppleID(){
        if #available(iOS 13.0, *) {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
}


//MARK:-  ASAuthorizationControllerDelegate
extension AppleLoginManager: ASAuthorizationControllerDelegate{
    
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //AlertUtility.showAlert(self, title: "Somthing bad happen \(error)")
        delegate?.socialLoginFailed(error, isCancelled: false, socialType: .apple)
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            var user: AppleUser?
            if let _user = AppleUser.fetchFromKeychain(providerId: appleIDCredential.user ) {
                user = _user
                //Update email in key chain
                if let email = appleIDCredential.email {
                    if email != user?.email {
                        user?.update(email: email)
                        user?.email = email
                    }
                }
            } else {
                user = AppleUser(credentials: appleIDCredential)
                user?.saveInKeychain()
            }
            
            let resultDict: [String: String] = [
                "token" : user?.token ?? "",
                "socialId" : user?.providerId ?? "",
                "name" : user?.firstName ?? "",
                "email" : user?.email ?? "",
                "pictureUrl" : ""
            ]
            
            self.delegate?.socialLoginSuccess(socialType: .apple, result: resultDict)
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
        default:
            break
        }
        
    }
}


extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding{
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return onPresent!.view.window!
    }
}

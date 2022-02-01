//
//  GoogleLoginManager.swift
//  Wedgram
//
//  Created by Danish Khan on 01/02/2022.
//

import Foundation
import GoogleSignIn
import Firebase
import UIKit
import SwiftyJSON

class GoogleLoginManager: NSObject {
    
    private var delegate: SocialLoginManagerDelegate?
    private var uidelegate: GIDSignInDelegate?
    
    var onPresent:UIViewController?
    
    init(delegate: SocialLoginManagerDelegate?,viewController:UIViewController) {
        super.init()
        self.delegate = delegate
        self.uidelegate = viewController as? GIDSignInDelegate
        self.onPresent = viewController
        GIDSignIn.sharedInstance()?.delegate = self
    }
    deinit {
        Logger.log("Going")
    }
    
    func login() {
        GIDSignIn.sharedInstance().presentingViewController = onPresent
        GIDSignIn.sharedInstance()?.delegate = self
        
        if let token = GIDAuthentication().accessToken {
            // loggedInUser = GIDGoogleUser().self
            // delegate?.socialLoginSuccess(socialType: .google)
            return
        }
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func logout() {
        GIDSignIn.sharedInstance()?.delegate = self
        
        GIDSignIn.sharedInstance()?.signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension GoogleLoginManager: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //Return if error
        if error != nil {
            delegate?.socialLoginFailed(error, isCancelled: false, socialType: .google)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        //Save User Detail
        let token = user.authentication.accessToken
        let socialId = user.userID
        let name = user.profile.name
        let email = user.profile.email
        let pictureUrl = user.profile.imageURL(withDimension: 100)?.absoluteString
        
        let resultDict: [String: String] = [
            "token" : token ?? "",
            "socialId" : socialId ?? "",
            "name" : name ?? "",
            "email" : email ?? "",
            "pictureUrl" : pictureUrl ?? ""
        ]
        
        delegate?.socialLoginSuccess(socialType: .google, result: resultDict)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        delegate?.didSocialLogout(socialType: .google)
    }
}

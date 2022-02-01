//
//  FacebookLoginManager.swift
//  Wedgram
//
//  Created by Danish Khan on 01/02/2022.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

enum SocialType: String {
    case facebook = "facebook"
    case google   = "google"
    case apple    = "apple"
}

protocol SocialLoginManagerDelegate {
    func socialLoginSuccess(socialType: Constants.SocialType,result:[String:String])
    func socialLoginFailed(_ error:Error?, isCancelled:Bool, socialType: Constants.SocialType )
    func didSocialLogout(socialType: Constants.SocialType )
}

class FacebookLoginManager: NSObject {
    
    private var delegate: SocialLoginManagerDelegate?
    
    init(delegate: SocialLoginManagerDelegate?) {
        super.init()
        self.delegate = delegate
    }
    
    /**
     Login to facebook and return access token
     */
    func login(requestParameters:[String], controller: UIViewController) {
        LoginManager().logOut()
        //        if let token = AccessToken.current?.tokenString {
        //            delegate?.socialLoginSuccess(token: token, socialType: .facebook, user: nil)
        //            return
        //        }
        LoginManager().logIn(permissions: requestParameters, from: controller) { (result, error) in
            //Check for error
            if error != nil {
                self.delegate?.socialLoginFailed(error, isCancelled: false, socialType: .facebook)
                return
            }
            //Check for cancelled by user
            if (result?.isCancelled ?? true) {
                self.delegate?.socialLoginFailed(error, isCancelled: true, socialType: .facebook)
                return
            }
            //Check token
            guard  let token = result?.token?.tokenString else {
                self.delegate?.socialLoginFailed(nil, isCancelled: false, socialType: .facebook)
                return
            }
            self.getUserData(parameters: Constants.FacebookParameter.parameters) { (data, error) in
                if let data = data {
                    let json =  JSON(data)
                    //Save user data here
                    
                    let resultDict = [
                        "name"        : json["name"].string ?? "",
                        "socialId"    : json["id"].string ?? "",
                        "email"       : json["email"].string ?? "",
                        "socialToken" : token
                    ]
                    
                    self.delegate?.socialLoginSuccess(socialType: .facebook, result: resultDict)
                }
            }
        }
    }
    
    /**
     Logout from facebook
     */
    func logout() {
        LoginManager().logOut()
        delegate?.didSocialLogout(socialType: .facebook)
    }
    
    /**
     Return user data of facebook user
     */
    private  func getUserData(parameters: [String:Any], completion:@escaping (Any?,Error?)->()) {
        //If access token is nil than dont check for user data
        if AccessToken.current == nil {
            completion(nil,nil)
            return
        }
        let graphRequest = GraphRequest(graphPath: "/me", parameters: parameters)
        graphRequest.start { (connection, data, error) in
            //Check for error
            if error != nil {
                completion(nil,error)
                return
            }
            //If no error return Data
            completion(data,nil)
        }
    }
}

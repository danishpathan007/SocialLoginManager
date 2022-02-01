# SocialLoginManager


    private var facebookLoginManager: FacebookLoginManager?
    private var googleLoginManager: GoogleLoginManager?
    private var appleLoginManager: AppleLoginManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginManager = FacebookLoginManager(delegate: self)
        googleLoginManager = GoogleLoginManager(delegate: self, viewController: self)
        appleLoginManager = AppleLoginManager(delegate: self, viewController: self)
    }
    
    //MARK:-  Social login manager delegates
    extension SocialLoginViewController: SocialLoginManagerDelegate {
     /**
      On Logout
      */
     func didSocialLogout(socialType: Constants.SocialType) {
         Logger.log("Logged out from\(socialType)")
     }
    
     /**
      On Login Success
      */
     func socialLoginSuccess(socialType: Constants.SocialType,result: [String:String]) {
         Logger.log(socialType)
         Logger.log(result)
     }
    
      /**
      On Login Failed
      */
     func socialLoginFailed(_ error: Error?, isCancelled: Bool, socialType: Constants.SocialType) {
         Logger.log("Failed to login:\(socialType)")
     }
   }

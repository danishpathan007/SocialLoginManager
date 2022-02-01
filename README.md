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

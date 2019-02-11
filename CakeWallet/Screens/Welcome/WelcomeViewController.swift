import UIKit

final class WelcomeViewController: BaseViewController<WelcomeView> {
    weak var signUpFlow: SignUpFlow?
    weak var restoreWalletFlow: RestoreWalletFlow?
    
    init(signUpFlow: SignUpFlow, restoreWalletFlow: RestoreWalletFlow) {
        self.signUpFlow = signUpFlow
        self.restoreWalletFlow = restoreWalletFlow
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func configureBinds() {
        contentView.createWallet.addTarget(self, action: #selector(createWalletAction), for: .touchUpInside)
        contentView.recoveryWallet.addTarget(self, action: #selector(recoverWalletAction), for: .touchUpInside)
        contentView.restoreFromCloud.addTarget(self, action: #selector(restoreFromCloud), for: .touchUpInside)
        if let appName = Bundle.main.displayName {
            
            // FIXME: Unnamed constant
            
            contentView.welcomeLabel.text = String(format: NSLocalizedString("welcome", comment: ""), appName)
            contentView.welcomeSubtitleLabel.text = NSLocalizedString("first_wallet_text", comment: "")
        }
        
        // FIXME: Unnamed constant
        
        contentView.restoreFromBackupLabel.text = "You can also restore the whole app from a backed-up file."

        contentView.descriptionTextView.text = NSLocalizedString("starting_creation_selection", comment: "")
        + "\n\n"
        + NSLocalizedString("love_your_feedback", comment: "")
    }
    
    @objc
    private func createWalletAction() {
        signUpFlow?.change(route: .setupPin({ signUpFlow  in
            signUpFlow.change(route: .createWallet)
        }))
    }
    
    @objc
    private func recoverWalletAction() {
        signUpFlow?.change(route: .setupPin({ [weak self] _  in
            self?.restoreWalletFlow?.change(route: .root)
        }))
    }
    
    @objc
    private func restoreFromCloud() {
        signUpFlow?.change(route: .restoreFromCloud)
    }
}

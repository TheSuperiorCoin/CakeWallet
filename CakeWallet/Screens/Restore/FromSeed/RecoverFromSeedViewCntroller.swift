import UIKit
import CakeWalletLib
import CakeWalletCore


final class RecoverFromSeedViewCntroller: BaseViewController<RecoverFromSeedView> {
    let store: Store<ApplicationState>
    let type: WalletType
    weak var restoreWalletFlow: RestoreWalletFlow?
    
    init(store: Store<ApplicationState>, type: WalletType = .monero, restoreWalletFlow: RestoreWalletFlow) {
        self.store = store
        self.type = type
        self.restoreWalletFlow = restoreWalletFlow
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("restore_seed_card_title", comment: "")
        contentView.doneButton.addTarget(self, action: #selector(recoverAction), for: .touchUpInside)
        contentView.pasteSeedButton.addTarget(self, action: #selector(pasteSeedAction), for: .touchUpInside)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        super.configureBinds()
    }
    
    private func done() {
        if let alert = presentedViewController {
            alert.dismiss(animated: true) { [weak self] in
                self?.restoreWalletFlow?.doneHandler?()
            }
            return
        }
        
        restoreWalletFlow?.doneHandler?()
    }
    
    @objc
    private func pasteSeedAction() {
        let pasteboardString: String? = UIPasteboard.general.string
        if let expectedSeed = pasteboardString {
//            contentView.seedField.paste(expectedSeed)
            
//            contentView.seedField.textField.text = expectedSeed
//            contentView.seedField.textField.placeholder = ""
//            contentView.seedField.flex.markDirty()
//            contentView.flex.layout()
        }
    }
    
    @objc
    private func recoverAction() {
        contentView.doneButton.showLoading()
        
        if let walletName = contentView.walletNameField.text,
            let seed = contentView.seedField.text {
            
            self.store.dispatch(
                WalletActions.restoreFromSeed(
                    withName: walletName,
                    andSeed: seed,
                    restoreHeight: contentView.restoreFromHeightView.restoreHeight,
                    type: type,
                    handler: { [weak self] result in
                        switch result {
                        case .success(_):
                            self?.done()
                        case let .failed(error):
                            self?.contentView.doneButton.hideLoading()
                            self?.showErrorAlert(error: error)
                        }
                    }
                )
            )
        }
    }
}

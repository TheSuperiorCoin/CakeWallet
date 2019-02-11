import UIKit
import FlexLayout

final class WelcomeView: BaseScrollFlexViewWithBottomSection {
    let titleContainer: UIView
    let bodyContainer: UIView
    let welcomeLabel: UILabel
    let welcomeSubtitleLabel: UILabel
    let descriptionTextView: UITextView
    let buttonsContiner: UIView
    let createWallet: UIButton
    let recoveryWallet: UIButton
    let restoreFromCloud: UIButton
    let restoreFromBackupLabel: UILabel
    let separatorView: UIView
    
    required init() {
        titleContainer = UIView()
        bodyContainer = UIView()
        welcomeLabel = UILabel(fontSize: 32)
        welcomeSubtitleLabel = UILabel(fontSize: 24)
        descriptionTextView = UITextView()
        buttonsContiner = UIView()
        createWallet = PrimaryButton(title: NSLocalizedString("create_new", comment: ""))
        recoveryWallet = SecondaryButton(title: NSLocalizedString("restore_from_seed_keys", comment: ""))
        restoreFromCloud = SecondaryButton(title: "Restore from backup")
        restoreFromBackupLabel = UILabel(fontSize: 12)
        separatorView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        descriptionTextView.font = .systemFont(ofSize: 20)
        descriptionTextView.textColor = UIColor(red: 126, green: 147, blue: 177)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.isScrollEnabled = false
        welcomeLabel.numberOfLines = 0
        welcomeSubtitleLabel.numberOfLines = 0
        welcomeSubtitleLabel.textColor = UIColor(red: 126, green: 147, blue: 177)
        restoreFromBackupLabel.textColor = .gray
        restoreFromBackupLabel.textAlignment = .center
        restoreFromBackupLabel.numberOfLines = 0
    }
    
    override func configureConstraints() {
        titleContainer.flex.define { flex in
            flex.addItem(welcomeLabel)
            flex.addItem(welcomeSubtitleLabel)
        }
        
        bodyContainer.flex.define { flex in
            flex.addItem(titleContainer)
            flex.addItem(descriptionTextView).marginTop(45)
        }
        
        buttonsContiner.flex.define { flex in
            flex.addItem(createWallet).height(56)
            flex.addItem(recoveryWallet).height(56).marginTop(10)
            flex.addItem(separatorView).height(1).width(100%).backgroundColor(.vividBlue).margin(UIEdgeInsets(top: 25, left: 0, bottom: 10, right: 0))
            flex.addItem(restoreFromBackupLabel).width(100%).marginBottom(15)
            flex.addItem(restoreFromCloud).height(56).marginTop(10).marginBottom(25)
        }
        
        rootFlexContainer.flex.justifyContent(.spaceBetween).padding(45, 10, 0, 10).define { flex in
            flex.addItem(bodyContainer) //.marginLeft(47).marginRight(55).marginTop(45)
        }
        
        bottomSectionView.flex.define { flex in
            flex.addItem(buttonsContiner).alignSelf(.center).width(90%)//.marginBottom(20)
        }
    }
}

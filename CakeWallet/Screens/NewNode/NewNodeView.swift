import UIKit
import FlexLayout

final class NewNodeView: BaseFlexView {
    let cardView: UIView
    let nodeAddressTextField: CWTextField
    let nodePortTextField: CWTextField
    let loginTextField: CWTextField
    let passwordTextField: CWTextField
    let saveButton: UIButton
    let resetSettings: UIButton
    let buttonsContainer: UIView
    
    required init() {
        cardView = CardView()
        nodeAddressTextField = CWTextField(placeholder: NSLocalizedString("node_address", comment: "")) //FloatingLabelTextField(placeholder: NSLocalizedString("node_address", comment: ""))
        nodePortTextField = CWTextField(placeholder: NSLocalizedString("node_port", comment: "")) //FloatingLabelTextField(placeholder: NSLocalizedString("node_port", comment: ""))
        loginTextField = CWTextField(placeholder: NSLocalizedString("login", comment: "")) //FloatingLabelTextField(placeholder: NSLocalizedString("login", comment: ""), isOptional: true)
        passwordTextField = CWTextField(placeholder: NSLocalizedString("password", comment: "")) //FloatingLabelTextField(placeholder: NSLocalizedString("password", comment: ""), isOptional: true)
        saveButton = PrimaryButton(title: NSLocalizedString("save", comment: ""))
        resetSettings = SecondaryButton(title: NSLocalizedString("reset", comment: ""))
        buttonsContainer = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        nodePortTextField.keyboardType = .numberPad
        passwordTextField.isSecureTextEntry = true
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20).justifyContent(.spaceBetween).define { flex in
            flex.addItem(nodeAddressTextField).height(50).marginTop(10)
            flex.addItem(nodePortTextField).height(50).marginTop(10)
            flex.addItem(loginTextField).height(50).marginTop(10)
            flex.addItem(passwordTextField).height(50).marginTop(10)
        }
        
        buttonsContainer.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(resetSettings).height(56).width(45%)
            flex.addItem(saveButton).height(56).width(45%)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)).define { flex in
            flex.addItem(cardView).width(100%)
            flex.addItem(buttonsContainer).width(100%).marginTop(20)
        }
    }
}

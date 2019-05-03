import UIKit
import CakeWalletLib
import CakeWalletCore
import CWMonero

final class NewNodeViewController: BaseViewController<NewNodeView> {
    private let nodesList: NodesList
    
    init(nodesList: NodesList = NodesList.shared) {
        self.nodesList = nodesList
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("node_new", comment: "")
        contentView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        contentView.resetSettings.addTarget(self, action: #selector(onResetSetting), for: .touchUpInside)
    }
    
    private func setSettings(_ node: NodeDescription) {
        setAddress(fromUri: node.uri)
        contentView.loginTextField.textField.text = node.login
        contentView.passwordTextField.textField.text =  node.password
    }
    
    private func setAddress(fromUri uri: String) {
        let splitedUri = uri.components(separatedBy: ":")
        let address = splitedUri.first ?? ""
        let port = Int(splitedUri.last ?? "") ?? 0
        
        contentView.nodeAddressTextField.textField.text = address
        contentView.nodePortTextField.textField.text  = "\(port)"
    }
    
    @objc
    private func onResetSetting() {
        setSettings(MoneroNodeDescription(uri: "", login: "", password: ""))
    }
    
    @objc
    private func save() {
        guard
            let address = contentView.nodeAddressTextField.textField.text,
            let port = contentView.nodePortTextField.textField.text else {
                return
        }

        showSpinnerAlert(withTitle: NSLocalizedString("saving", comment: "")) { alert in
            let uri = "\(address):\(port)"
            
            let nodeDescription = MoneroNodeDescription(
                uri: uri,
                login: self.contentView.loginTextField.textField.text ?? "",
                password: self.contentView.passwordTextField.textField.text ?? "")
            
            do {
                try self.nodesList.add(node: nodeDescription)
                alert.dismiss(animated: true) { [weak self] in
                    self?.showOKInfoAlert(title: NSLocalizedString("saved", comment: "")) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                alert.dismiss(animated: true) { [weak self] in
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
}

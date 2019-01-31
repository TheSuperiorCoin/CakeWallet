import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout
import SwiftyJSON

protocol JSONExportable {
    var primaryKey: String { get }
    func toJSON() -> JSON
}

protocol JSONImportable {
    init?(from json: JSON)
}

protocol JSONConvertable: JSONExportable, JSONImportable {}

extension Contact: JSONConvertable {
    init?(from json: JSON) {
        guard
            let typeRaw = json["type"].string,
            let type = CryptoCurrency(from: typeRaw) else {
                return nil
        }
        
        self.uuid = json["uuid"].stringValue
        self.type = type
        self.name = json["name"].stringValue
        self.address = json["address"].stringValue
    }
    
    var primaryKey: String {
        return "uuid"
    }
    
    func toJSON() -> JSON {
        return JSON(["uuid": uuid, "name": name, "type": type.formatted(), "address": address])
    }
}

class AddressBook {
    static let shared: AddressBook = AddressBook()
    
    private static let name = "address_book.json"
    
    private static var url: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    }
    
    private static func load() -> JSON {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        
        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSON(data: data) else {
                return JSON()
        }
        
        return json
    }
    
    private var json: JSON
    
    private init() {
        json = AddressBook.load()
    }
    
    func all() -> [Contact] {
        return json.array?.map({ json -> Contact? in
            return Contact(from: json)
        }).compactMap({ $0 }) ?? []
    }
    
    func addOrUpdate(contact: Contact) throws {
        let isExist = json.arrayValue
            .filter({ $0[contact.primaryKey].stringValue == contact.uuid })
            .first != nil
        let updatedJson: JSON
        
        if isExist {
            updatedJson = JSON(json.arrayValue.map({ json -> JSON in
                let currentUuid = json[contact.primaryKey].stringValue
                
                if currentUuid == contact.uuid {
                    return contact.toJSON()
                }
                
                return json
            }))
        } else {
            let array = json.arrayValue + [contact.toJSON()]
            updatedJson = JSON(array)
        }
        
        try save(json: updatedJson)
        json = updatedJson
    }
    
    func delete(for uuid: String) throws {
        let updatedJson = JSON(json.arrayValue.filter({ json -> Bool in
            let contactUuid = json["uuid"].stringValue

            if contactUuid != uuid {
                return true
            }
            
            return false
        }))
        
        try save(json: updatedJson)
        json = updatedJson
    }
    
    private func save(json: JSON) throws {
        try json.rawData().write(to: AddressBook.url)
    }
}


final class AddressTableCell: FlexCell {
    let nameLabel = UILabel(fontSize: 15)
    let typeLabel = UILabel(fontSize: 12)
    let leftViewWrapper = UIView()
    let typeViewWrapper = UIView()
    let typeView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
        backgroundColor = .clear
        contentView.layer.applySketchShadow(color: .wildDarkBlue, alpha: 0.25, x: 10, y: 3, blur: 13, spread: 2)
        selectionStyle = .none

        typeLabel.textColor = .white
        typeView.layer.borderWidth = 1
        typeView.layer.cornerRadius = 8
        typeView.layer.masksToBounds = true
    }
    
    override func configureConstraints() {
        contentView.flex
            .margin(UIEdgeInsets(top: 7, left: 20, bottom: 0, right: 20))
            .padding(5, 10, 5, 10)
            .height(50)
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .define { flex in
                flex.addItem(leftViewWrapper).define({ wrapperFlex in
                    wrapperFlex
                        .direction(.row)
                        .justifyContent(.spaceBetween)
                        .alignItems(.center)
                        .addItem(typeViewWrapper)
                            .width(90)
                            .alignItems(.center)
                            .addItem(typeView)
                                .marginRight(14)
                                .padding(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
                                .addItem(typeLabel)
                    wrapperFlex.addItem(nameLabel)
                })
        }
    }
    
    func configure(name: String, type: String, color: UIColor) {
        nameLabel.text = name
        typeLabel.text = type
        typeLabel.textColor = color
        typeView.layer.borderColor = color.cgColor
        nameLabel.flex.markDirty()
        typeLabel.flex.markDirty()
        contentView.flex.layout()
    }
}

struct Contact {
    let uuid: String
    let type: CryptoCurrency
    let name: String
    let address: String
    
    init(uuid: String? = nil, type: CryptoCurrency, name: String, address: String) {
        if let uuid = uuid {
            self.uuid = uuid
        } else {
            self.uuid = UUID().uuidString
        }
        
        self.type = type
        self.name = name
        self.address = address
    }
}

extension Contact: CellItem {
    private func color(for currency: CryptoCurrency) -> UIColor {
        switch currency {
        case .bitcoin:
            return UIColor(hex: 0xFF9900)
        case .bitcoinCash:
            return UIColor(hex: 0xee8c28)
        case .monero:
            return UIColor(hex: 0xff7519)
        case .ethereum:
            return UIColor(hex: 0x303030)
        case .liteCoin:
            return UIColor(hex: 0x88caf5)
        case .dash:
            return UIColor(hex: 0x008de4)
        }
    }
    
    func setup(cell: AddressTableCell) {
        cell.configure(name: name, type: type.formatted(), color: color(for: type))
    }
}

final class AddressBookViewController: BaseViewController<AddressBookView>, UITableViewDelegate, UITableViewDataSource {
    let addressBook: AddressBook
    let store: Store<ApplicationState>
    let isReadOnly: Bool?
    var doneHandler: ((String) -> Void)?
    
    private var contacts: [Contact]
    
    init(addressBook: AddressBook, store: Store<ApplicationState>, isReadOnly: Bool?) {
        self.addressBook = addressBook
        self.store = store
        self.isReadOnly = isReadOnly
        contacts = addressBook.all()
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Address Book"

        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [Contact.self])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContacts()
        
        let isModal = self.isModal
        renderActionButtons(for: isModal)
    }
    
    private func renderActionButtons(for isModal: Bool) {
        if !isModal {
            let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNewAddressItem))
            navigationItem.rightBarButtonItems = [addButton]
        } else {
            let doneButton = StandartButton.init(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 12, height: 12)))
            doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
            doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
        }
    }
    
    private func refreshContacts() {
        contacts = addressBook.all()
        contentView.table.reloadData()
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
    
    @objc
    private func addNewAddressItem(){
        navigationController?.pushViewController(NewAddressViewController(addressBoook: AddressBook.shared), animated: true)
    }
    
    @objc
    private func copyAction() {
        showInfo(title: NSLocalizedString("copied", comment: ""), withDuration: 1, actions: [CWAlertAction.okAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = contacts.count == 0 ? createNoDataLabel(with: tableView.bounds.size) : nil
        tableView.separatorStyle = .none
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        return tableView.dequeueReusableCell(withItem: contact, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        
        if let isReadOnly = self.isReadOnly, isReadOnly {
            dismissAction()
            doneHandler?(contact.address)
        } else {
            showInfo(
                title: contact.name,
                message: contact.address,
                actions: [
                    CWAlertAction(title: "Send", handler: { action in
                        action.alertView?.dismiss(animated: true) {
                            let sendVC = SendViewController(store: self.store, address: contact.address)
                            let sendNavigation = UINavigationController(rootViewController: sendVC)
                            self.present(sendNavigation, animated: true)
                        }
                    }),
                    CWAlertAction(title: "Copy", handler: { action in
                        UIPasteboard.general.string = contact.address
                        action.alertView?.dismiss(animated: true)
                    })
                ]
            )
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { [weak self] (action, view, completionHandler ) in
            guard let contact = self?.contacts[indexPath.row] else {
                return
            }
            let newContactVC = NewAddressViewController(
                addressBoook: AddressBook.shared,
                contact: contact
            )
            self?.navigationController?.pushViewController(newContactVC, animated: true)
        })
        
        editAction.image = UIImage(named: "edit_icon")
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completionHandler ) in
            guard let uuid = self?.contacts[indexPath.row].uuid else {
                return
            }
            
            do {
                try self?.addressBook.delete(for: uuid)
                self?.contacts = self?.addressBook.all() ?? []
                self?.contentView.table.reloadData()
            } catch {
                self?.showError(error: error)
            }
        })
        
        deleteAction.image = UIImage(named: "trash_icon")
        
        let confrigation = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return confrigation
    }
    
    private func createNoDataLabel(with size: CGSize) -> UIView {
        let noDataLabel: UILabel = UILabel(frame: CGRect(origin: .zero, size: size))
        noDataLabel.text = "No contacts yet"
        noDataLabel.textColor = UIColor(hex: 0x9bacc5)
        noDataLabel.textAlignment = .center
        
        return noDataLabel
    }
}

import UIKit
import FlexLayout

final class ExchangeCardView: BaseFlexView {
    let cardType: ExchangeCardType
    let cardTitle: UILabel
    let topCardView: UIView
    let pickerRow: UIView
    let pickerButton: UIView
    let pickedCurrency: UILabel
    let walletNameLabel: UILabel
    let amountTextField: TextField
    let addressTextField: IconTextField
    let pickerIcon: UIImageView
    let receiveView: UIView
    let receiveViewTitle: UILabel
    let receiveViewAmount: UILabel
    
    required init(cardType: ExchangeCardType, cardTitle: String) {
        self.cardType = cardType
        self.cardTitle = UILabel(text: cardTitle)
        topCardView = UIView()
        pickerRow = UIView()
        pickerButton = UIView()
        pickedCurrency = UILabel(text: "BTC")
        walletNameLabel = UILabel(text: "Main wallet")
        amountTextField = TextField(placeholder: "0.000", fontSize: 25, withTextAlignmentReverse: true)
        addressTextField = IconTextField(placeholder: "Refund address", fontSize: 16)
        pickerIcon = UIImageView(image: UIImage(named: "arrow_bottom_purple_icon"))
        receiveView = UIView()
        receiveViewTitle = UILabel(text: "You will receive")
        receiveViewAmount = UILabel(text: "24.092")
        
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        cardTitle.font = applyFont(ofSize: 17, weight: .semibold)
        
        pickedCurrency.font = applyFont(ofSize: 26, weight: .bold)
        walletNameLabel.font = applyFont(ofSize: 13)
        walletNameLabel.textColor = UIColor.wildDarkBlue
        
        amountTextField.textField.keyboardType = .decimalPad
        
        receiveViewTitle.font = applyFont(ofSize: 15)
        receiveViewTitle.textColor = UIColor.wildDarkBlue
        
        receiveViewAmount.font = applyFont(ofSize: 22, weight: .semibold)
        receiveViewAmount.textColor = UIColor.purpley
    }
    
    override func configureConstraints() {
        rootFlexContainer.layer.cornerRadius = 12
        rootFlexContainer.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 0, blur: 20, spread: -10)
        rootFlexContainer.backgroundColor = Theme.current.card.background
        
        pickerButton.flex.width(100).height(50).define{ flex in
            flex.addItem(pickedCurrency)
            flex.addItem(walletNameLabel)
            flex.addItem(pickerIcon).position(.absolute).top(10).right(35)
        }
        
        receiveView.flex
            .alignItems(.end)
            .define{ flex in
            flex.addItem(receiveViewTitle)
            flex.addItem(receiveViewAmount)
        }
        
        topCardView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.end)
            .width(100%)
            .define{ flex in
                flex.addItem(pickerButton)
                flex.addItem(cardType == ExchangeCardType.deposit ? amountTextField : receiveView)
                    .width(67%)
                    .paddingBottom(7)
        }
        
        rootFlexContainer.flex
            .justifyContent(.start)
            .alignItems(.center)
            .padding(18, 15, 35, 15)
            .marginBottom(25)
            .define{ flex in
                flex.addItem(cardTitle).marginBottom(25)
                flex.addItem(topCardView).marginBottom(25)
                flex.addItem(addressTextField).width(100%)
        }
    }
}

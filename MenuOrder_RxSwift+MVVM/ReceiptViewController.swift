//
//  ReceiptViewController.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/13.
//

import UIKit

class ReceiptViewController: UIViewController {
    
    @IBOutlet weak var itemsTextView: UITextView!
    @IBOutlet weak var itemsPrice: UILabel!
    @IBOutlet weak var vatPrice: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    
    var orderList: [(menu:Menu, cnt:Int)]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateOrderInfo()
        updateTextHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func updateOrderInfo() {
        guard let list = orderList else { return }
        
        let allItemText = list.map { "\($0.menu.name) \($0.cnt)개" }.joined(separator: "\n")
        let itemPrice = list.map{ $0.menu.price * $0.cnt }.reduce(0, +)
        let vatItemPrice = Int(Double(itemPrice) * 0.1)
        
        itemsTextView.text = allItemText
        itemsPrice.text = itemPrice.currencyKR()
        vatPrice.text = vatItemPrice.currencyKR()
        totalPrice.text = Int(itemPrice + vatItemPrice).currencyKR()
    }
    
    //MARK: - items TextView height
    @IBOutlet var itemsTextViewHeight: NSLayoutConstraint!
    
    func heightWithConstrainedWidth(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        //
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)  // .greatestFiniteMegnitude : 최대 유한 크기
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font : font],
                                            context: nil)
        // .usesLineFragmentOrigin : 기준점 원점 대신 선 조각 원점 기준으로 함
        // .usesFontLeading : 폰트 행간을 사용하여 높이 계산
        return boundingBox.height
    }
    
    func updateTextHeight() {
        let height = heightWithConstrainedWidth(text: itemsTextView.text,
                                                width: itemsTextView.bounds.width,
                                                font: itemsTextView.font ?? .systemFont(ofSize: 32))
        
        print("height : \(height), font : \(itemsTextView.font), text : \(itemsTextView.text)")
        itemsTextViewHeight.constant = height + 40
    }

}

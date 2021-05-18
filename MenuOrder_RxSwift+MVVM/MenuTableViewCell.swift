//
//  MenuTableViewCell.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/14.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var countUPBtn: UIStackView!
    @IBOutlet weak var countDownBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var onChangeCount: ((Int) -> Void) = { _ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(_ item: (menu:Menu, cnt:Int)) {
        nameLabel.text = item.menu.name
        priceLabel.text = "\(item.menu.price)"
        countLabel.text = "\(item.cnt)"
    }

    @IBAction func onIncreaseCont(_ sender: UIButton) {
        onChangeCount(1)
    }
    
    @IBAction func onDecreaseCount(_ sender: UIButton) {
        onChangeCount(-1)
    }
}

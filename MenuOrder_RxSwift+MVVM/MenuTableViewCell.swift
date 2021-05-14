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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ menu: Menu) {
        nameLabel.text = menu.name
        priceLabel.text = "\(menu.price)"
    }

}

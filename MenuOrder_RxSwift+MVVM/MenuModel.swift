//
//  MenuModel.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/14.
//

import Foundation
import RxSwift
import RxCocoa

struct Menu: Decodable {
    var name: String
    var price: Int
}

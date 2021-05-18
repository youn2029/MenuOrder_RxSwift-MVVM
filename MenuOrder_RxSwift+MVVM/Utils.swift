//
//  Utils.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/18.
//

import Foundation

extension Int {
    func currencyKR() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

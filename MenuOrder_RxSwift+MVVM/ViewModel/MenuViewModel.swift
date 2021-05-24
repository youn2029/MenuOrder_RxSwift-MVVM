//
//  MenuViewModel.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/24.
//

import Foundation
import RxSwift

/*
 
 데이터를 처리하는 View Model
 
 처리할 요소
 1. menu items data
 2. total Price
 3. item count
 
 */


class MenuViewModel {
    
    var menus: [(menu:Menu, cnt: Int)] = []     // cnt 수정을 위해 menu에 cnt를 넣었던 걸, 밖으로 뺌
    var disposeBag = DisposeBag()
    
    var menuSubject = BehaviorSubject<[(menu:Menu, cnt:Int)]>(value: [])
    
    
//    func fetchMenusRx() {
//        indicatorView.isHidden = false
//        indicatorView.startAnimating()
//
//        APIService.fetchMenuURLRx()
//            .map{ APIService.jsonToMenus(data: $0) }
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] list in
//                self?.menus = list
//                self?.menuSubject.onNext(list)
//                self?.indicatorView.stopAnimating()
//                self?.indicatorView.isHidden = true
//                self?.menuTableView.refreshControl?.endRefreshing()
//
//            }, onError: { [weak self] err in
//                self?.showAlert(title: "error", msg: err.localizedDescription)
//                self?.indicatorView.stopAnimating()
//                self?.indicatorView.isHidden = true
//            })
//            .disposed(by: disposeBag)
//    }
    
    func totalPrice() -> Observable<String> {
        return menuSubject.map{ $0.map{ $0.menu.price * $0.cnt }.reduce(0, +) }.map{ $0.currencyKR() }
    }
    
    func itemCount() -> Observable<String> {
        return menuSubject.map{ $0.map{ $0.cnt }.reduce(0, +) }.map{ "\($0)" }
    }
    
}

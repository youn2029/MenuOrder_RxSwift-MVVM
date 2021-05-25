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
    
    // total price text
    lazy var totalPrice = menuSubject.map{ $0.map{ $0.menu.price * $0.cnt }.reduce(0, +) }.map{ $0.currencyKR() }
    
    // item count
    lazy var itemCount = menuSubject.map{ $0.map{ $0.cnt }.reduce(0, +) }.map{ "\($0)" }
    
    // menu item count clear
    lazy var clearItem = menuSubject
        .map{ $0.map{ ($0.menu, 0) } }
        .bind(to: menuSubject.asObserver())
    
}


/*
 곰튀김님의 Menu order 프로그램의 MVVM 패턴 자료 --> 공부하기 위해 가져옴
 
 // protocol을 만든 이유는 어떤 데이터를 처리할껀지 확인하기 위해?? -> 구현부가 init에 존재해서 protocol로 정의함
 protocol MenuViewModelType {
     var fetchMenus: AnyObserver<Void> { get }
     var clearSelections: AnyObserver<Void> { get }
     var makeOrder: AnyObserver<Void> { get }
     var increaseMenuCount: AnyObserver<(menu: ViewMenu, inc: Int)> { get }

     var activated: Observable<Bool> { get }
     var errorMessage: Observable<NSError> { get }
     var allMenus: Observable<[ViewMenu]> { get }
     var totalSelectedCountText: Observable<String> { get }
     var totalPriceText: Observable<String> { get }
     var showOrderPage: Observable<[ViewMenu]> { get }
 }

 class MenuViewModel: MenuViewModelType {
     let disposeBag = DisposeBag()

     // INPUT

     let fetchMenus: AnyObserver<Void>
     let clearSelections: AnyObserver<Void>
     let makeOrder: AnyObserver<Void>
     let increaseMenuCount: AnyObserver<(menu: ViewMenu, inc: Int)>

     // OUTPUT

     let activated: Observable<Bool>                 //
     let errorMessage: Observable<NSError>
     let allMenus: Observable<[ViewMenu]>
     let totalSelectedCountText: Observable<String>
     let totalPriceText: Observable<String>
     let showOrderPage: Observable<[ViewMenu]>

     // init을 통해
     init(domain: MenuFetchable = MenuStore()) {
         
         // 데이터를 가져오기 위한 subject??
         let fetching = PublishSubject<Void>()      // url을 통해 통신 정보를 가져오는 것
         let clearing = PublishSubject<Void>()      // menu item 갯수를 0으로 리셋
         let ordering = PublishSubject<Void>()      // menu item 갯수가 1이상인 것만 주문
         let incleasing = PublishSubject<(menu: ViewMenu, inc: Int)>()      // menu item List

         let menus = BehaviorSubject<[ViewMenu]>(value: [])     // menu Data List
         let activating = BehaviorSubject<Bool>(value: false)   //
         let error = PublishSubject<Error>()                    // error

         // INPUT

         fetchMenus = fetching.asObserver()

         fetching
             .do(onNext: { _ in activating.onNext(true) })
             .flatMap(domain.fetchMenus)
             .map { $0.map { ViewMenu($0) } }
             .do(onNext: { _ in activating.onNext(false) })
             .do(onError: { err in error.onNext(err) })
             .subscribe(onNext: menus.onNext)
             .disposed(by: disposeBag)

         clearSelections = clearing.asObserver()

         clearing.withLatestFrom(menus)
             .map { $0.map { $0.countUpdated(0) } }
             .subscribe(onNext: menus.onNext)
             .disposed(by: disposeBag)

         makeOrder = ordering.asObserver()

         increaseMenuCount = incleasing.asObserver()

         incleasing.map { $0.menu.countUpdated(max(0, $0.menu.count + $0.inc)) }
             .withLatestFrom(menus) { (updated, originals) -> [ViewMenu] in
                 originals.map {
                     guard $0.name == updated.name else { return $0 }
                     return updated
                 }
             }
             .subscribe(onNext: menus.onNext)
             .disposed(by: disposeBag)

 
 
         // OUTPUT

         // menu Data
         allMenus = menus

         // ??
         activated = activating.distinctUntilChanged()

         // 에러 처리?
         errorMessage = error.map { $0 as NSError }

         // 선택한 menu item 갯수 Data
         totalSelectedCountText = menus
             .map { $0.map { $0.count }.reduce(0, +) }
             .map { "\($0)" }

         // total price text Data
         totalPriceText = menus
             .map { $0.map { $0.price * $0.count }.reduce(0, +) }
             .map { $0.currencyKR() }

         // order page에 선택한 메뉴 item Data
         showOrderPage = ordering.withLatestFrom(menus)
             .map { $0.filter { $0.count > 0 } }
             .do(onNext: { items in
                 if items.count == 0 {
                     let err = NSError(domain: "No Orders", code: -1, userInfo: nil)
                     error.onNext(err)
                 }
             })
             .filter { $0.count > 0 }
     }
 }
 */

//
//  ViewController.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/12.
//

import UIKit
import RxCocoa
import RxSwift
import RxViewController

/*
 
 RxSwift를 이용할 수 있는 요소
 
 1. 비동기 함수를 통해 데이터를 받아올 때 -> return 을 통해 받을 수 있게 해줌
 2. 화면을 구성하는 요소 -> 데이터 변화에 따라 표시되는 값들이 변하는 요소들을 stream을 통해 간편하게 해줌
 
 ==> 이 프로젝트에서 화면을 구성하는 요소 : menu의 count, 주문할 total count, 주문할 total price
     menus에서 확인 할 수 있는 주문할 total count와 주문할 total price
 
 Observable은 나오는 데이터만을 확일 할 수 있었다면, Subject는 데이터를 입력 할 수도 있다.
 그래서 값의 변화를 저장하고 그에 따른 변화도 처리가능
 
 Subject에는 PublishSubject, BehaviorSubject, AsyncSubject, ReplaySubject 의 4가지 종류가 있다
 
 - PublishSubject : 생성되는 시점부터 값을 출력
 - BehaviorSubject : 초기 값을 출력하고 다음부터 변환되는 값을 출력 -> 초기 설정값이 필요함
 - AsyncSubject : 쓰레드가 종류될 때 결과물을 출력
 - ReplaySubject : 생성되는 시점 이전에 출력된 값을 모두 출력
 * 참조 - http://reactivex.io/documentation/subject.html
 
 RxCocoa에서 제공하는 설정값은 Binder로 RxSwift의 bind(to:)를 통해 사용 가능하다
 Binder는 순환 참조 없이 데이터를 그래도 전달한다.
 
 - 라이브러리 추가 -> RxViewController : ViewController의 LifeCycle을 controllEvent로 사용 가능하게 해줌
 */

class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var orderItemCntLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var orderBtn: UIButton!
    
    var menuVM = MenuViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMenusRx()
        updateOrderInfoRx()
    }
    
    //MARK: - UI Logic
    
    //MARK: UI setting
    func showAlert(title: String?, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func updateOrderInfoRx() {
        
        // menu의 count -> Table Cell -> tableView setting
        menuSubject
            .observe(on: MainScheduler.instance)
            .bind(to: menuTableView.rx.items(cellIdentifier: "menuTableCell", cellType: MenuTableViewCell.self)){
                index, item, cell in
                
                cell.setData(item)
                cell.onChangeCount = {[weak self] num in
                    guard let self = self else { return }
                    var count = item.cnt + num
                    if count < 0 { count = 0 }
                    
                    var items = try! self.menuSubject.value()
                    items[index] = (item.menu, count)
                    self.menuSubject.onNext(items)
                }
            }
            .disposed(by: disposeBag)
        
        
        // order Item Count -> orderItemCntLabel
//        menuSubject
//            .map{ "\($0.map{ $0.cnt }.reduce(0, +))" }
//            .observe(on: MainScheduler.instance)
//            .bind(to: orderItemCntLabel.rx.text)
//            .disposed(by: disposeBag)
        
        menuVM.itemCount
            .bind(to: orderItemCntLabel.rx.text)
            .disposed(by: disposeBag)
        
        // order Total Price -> totalPriceLabel
//        menuSubject
//            .map{ $0.map{ $0.menu.price * $0.cnt }.reduce(0, +) }
//            .map{ $0.currencyKR() }
//            .observe(on: MainScheduler.instance)
//            .bind(to: totalPriceLabel.rx.text)
//            .disposed(by: disposeBag)
        
        menuVM.totalPrice
            .bind(to: totalPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 그 외 RxCocoa로 설정가능
        // RefreshControl 이벤트 처리
        let refresh = UIRefreshControl()
        refresh.rx.controlEvent(.valueChanged)
            .subscribe(onNext: fetchMenusRx)
            .disposed(by: disposeBag)
        menuTableView.refreshControl = refresh
        
        // clear버튼 이벤트 처리
        let viewWillAppear = rx.viewWillAppear.map{ _ in }
        let clearBtnTap = clearBtn.rx.tap.map{ _ in }
        
        Observable.merge([viewWillAppear, clearBtnTap])
            .withLatestFrom(menuSubject)
            .map{ $0.map{ ($0.menu, 0) } }
            .bind(to: menuSubject)
            .disposed(by: disposeBag)
        /*
         - marge() : 두 개 이상의 옵져버블을 하나의 옵져버블로 병합한다.
         - rx.viewWillAppear : viewWillAppear을 controlEvent로 사용 가능하게 해줌
         - map : return 값이 Observable<Result>이기에 Observable로 변환하기 위해 사용
         */
//        Observable.merge([viewWillAppear, clearBtnTap])
//            .bind(to: menuVM.clearItem)
//            .disposed(by: disposeBag)
        
        // order버튼 이벤트 처리
        orderBtn.rx.tap
            .withLatestFrom(menuSubject)
            .map{ $0.map{ $0.cnt }.reduce(0, +) }
            .do(onNext: { [weak self] orderCount in
                if orderCount <= 0 {
                    self?.showAlert(title: "", msg: "주문할 메뉴가 없습니다.")
                }
            })
            .filter{ $0 > 0 }
            .map{ _ in "ReceiptViewController" }
            .subscribe(onNext:{ [weak self] in
                self?.performSegue(withIdentifier: $0, sender: nil)
            })
            .disposed(by: disposeBag)
        /*
         - rx.controlEvent() : event
         - withLatestFrom() : 두 개의 옵저버블을 합치는 operator (CombineLatest의 설명과 같음)
            rx에 사용이 되면 동작하는 데이터를 사용하는게 가능
         
         - do() : 옵져버블 life cycle 이벤트에 대해 수행할 작업 등록
         
         - bind(to:) : parameter로 subject가 들어가면 subject의 데이터를 onNext하는 것
         */
        
    }
    
    //MARK: - IBAction
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier,
              id == "ReceiptViewController",
              let receiptVC = segue.destination as? ReceiptViewController,
              let item = try? menuSubject.value() else {
            return
        }

        let parameter = item.filter{ $0.cnt > 0 }
        receiptVC.orderList = parameter
    }
    
    //MARK: - Business Logic
    
    var menus: [(menu:Menu, cnt: Int)] = []     // cnt 수정을 위해 menu에 cnt를 넣었던 걸, 밖으로 뺌
    var disposeBag = DisposeBag()
    
    var menuSubject = BehaviorSubject<[(menu:Menu, cnt:Int)]>(value: [])
    
    func fetchMenusRx() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        
        APIService.fetchMenuURLRx()
            .map{ APIService.jsonToMenus(data: $0) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                self?.menus = list
                self?.menuSubject.onNext(list)
                self?.indicatorView.stopAnimating()
                self?.indicatorView.isHidden = true
                self?.menuTableView.refreshControl?.endRefreshing()
                
            }, onError: { [weak self] err in
                self?.showAlert(title: "error", msg: err.localizedDescription)
                self?.indicatorView.stopAnimating()
                self?.indicatorView.isHidden = true
            })
            .disposed(by: disposeBag)
    }
}

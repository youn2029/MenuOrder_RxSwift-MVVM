//
//  ReceiptViewController.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/13.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController

class ReceiptViewController: UIViewController {
    
    @IBOutlet weak var itemsTextView: UITextView!
    @IBOutlet weak var itemsPrice: UILabel!
    @IBOutlet weak var vatPrice: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    
    var orderList: [(menu:Menu, cnt:Int)]!
    
    var orderListSubject = BehaviorSubject<[(menu:Menu, cnt:Int)]>(value: [])
    var disposBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateOrderInfo()
    }
    
    func updateOrderInfo() {
        
        // viewWillAppear
        rx.viewWillAppear
            .take(1)
            .subscribe(onNext: { [weak navigationController] _ in
                navigationController?.isNavigationBarHidden = false
            })
            .disposed(by: disposBag)
        
        // viewWillDisappear
        rx.viewWillDisappear
            .take(1)
            .subscribe(onNext: { [weak navigationController] _ in
                navigationController?.isNavigationBarHidden = true
            })
            .disposed(by: disposBag)
        /*
         - task(Int) : 몇 번 실행할지 결정하는 operator
         */
        
        orderListSubject.onNext(orderList)
        
        // order items text
        orderListSubject
            .map{ $0.map{ "\($0.menu.name) \($0.cnt)개" }.joined(separator: "\n") }
            .bind(to: itemsTextView.rx.text)
            .disposed(by: disposBag)
        
        // order items textView height constraint
        itemsTextView.rx.text.orEmpty
            .map{ [weak self] in
                let width = self?.itemsTextView.bounds.width ?? 0
                let font = self?.itemsTextView.font ?? UIFont.systemFont(ofSize: 32, weight: .thin)
                let height = self?.heightWithConstrainedWidth(text: $0, width: width, font: font)
                return height ?? 0
            }
            .bind(to: itemsTextViewHeight.rx.constant)
            .disposed(by: disposBag)
        /*
         - orEmpty : 옵셔널값을 캐스팅하는 operator
         */
        
        // item price, vat price 값을 계산하는 observable
        let priceInfo = orderListSubject
            .map{ items in
                items.map{ $0.menu.price * $0.cnt }.reduce(0, +)
            }
            .map{ itemsPrice in
                (items: itemsPrice, vat: Int(Double(itemsPrice) * 0.1) )
            }
            .share(replay: 1, scope: .whileConnected)
        /*
         itmesPrice를 통해 vatPirce가 나오고,
         itemsPrice와 vatPrice를 합쳐야 totalPrice가 나옴
         observable에서 한번에 계산되야함
         
         - share(replay:Int, scope: SubjectLifetimeScope) : subscribe가 호출되면 해당 observable의 값을 공유하는 operator
            replay : 생성되는 버퍼의 갯수 -> 만약 1이면 subscribe가 한번 호출되면 실행되고 2번째부터는 처음 실행된 값을 공유한다
            scope : .forever와 .whileConnected 가 있는데 default는 .whilConnected 이다.
                    .forever는 subscribe 호출이 0이 되어도 값을 유지 / .whilConnected는 subscribe 요청이 0이 되면 지우고 replay시 새로 요청함
         
         참조
         - http://reactivex.io/documentation/operators/replay.html
         - https://jusung.github.io/shareReplay/
         */
        
        // itemsPrice
        priceInfo
            .map{ $0.items.currencyKR() }
            .bind(to: itemsPrice.rx.text)
            .disposed(by: disposBag)
        
        // vatPrice
        priceInfo
            .map{ $0.vat.currencyKR() }
            .bind(to: vatPrice.rx.text)
            .disposed(by: disposBag)
        
        // totalPrice
        priceInfo
            .map{ $0.items + $0.vat }
            .map{ $0.currencyKR() }
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposBag)
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
}

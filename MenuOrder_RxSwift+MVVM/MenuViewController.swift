//
//  ViewController.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/12.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier,
              id == "ReceiptViewController",
              let receiptVC = segue.destination as? ReceiptViewController,
              let data = sender as? String else {
            return
        }
        
        receiptVC.item = data
    }

    @IBAction func onOrder(_ sender: Any) {
        let data = "성공"
        performSegue(withIdentifier: "ReceiptViewController", sender: data)
    }
    
}


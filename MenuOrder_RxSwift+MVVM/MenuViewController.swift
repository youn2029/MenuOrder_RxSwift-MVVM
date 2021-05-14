//
//  ViewController.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/12.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var orderItemCntLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var menus: [Menu] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        menuTableView.refreshControl = refresh
        
        APIService.loadMenu { (list) in
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.menus = list
                self.menuTableView.reloadData()
            }
        }
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
    
    @objc func refreshAction() {
        indicatorView.startAnimating()
        APIService.loadMenu { (list) in
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
                self.menus = list
                self.menuTableView.reloadData()
                self.menuTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func fetchMenus() {
        
        APIService.loadMenu { (list) in
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
                self.menus = list
                self.menuTableView.reloadData()
                self.menuTableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = menus[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuTableCell") as! MenuTableViewCell
        cell.setData(data)
        
        return cell
    }
}


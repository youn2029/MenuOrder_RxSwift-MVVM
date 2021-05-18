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
        
        setRefresh()
        
        fetchMenus()
        updateOrderInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        onClear()
    }
    
    //MARK: - UI Setting
    func setRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        menuTableView.refreshControl = refresh
    }
    
    @objc func refreshAction() {
        fetchMenus()
    }
    
    func fetchMenus() {
        
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        
        APIService.fetchMenuURL { [weak self] result in
            switch result {
            case .failure(let err) :
                self?.showAlert(title: "error", msg: err.localizedDescription)
                DispatchQueue.main.async {
                    self?.indicatorView.stopAnimating()
                    self?.indicatorView.isHidden = true
                }
                
            case .success(let data) :
                DispatchQueue.main.async {
                    self?.indicatorView.stopAnimating()
                    self?.indicatorView.isHidden = true
                    self?.menus = APIService.jsonToMenus(data: data)
                    self?.menuTableView.reloadData()
                    self?.menuTableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    func updateOrderInfo() {
        let totalCnt = menus.map{ $0.count }.reduce(0, +)
        let totalPrice = menus.map{ $0.price * $0.count }.reduce(0, +)
        
        orderItemCntLabel.text = "\(totalCnt)"
        totalPriceLabel.text = totalPrice.currencyKR()
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - IBAction
    @IBAction func onClear() {
        (0..<menus.count).forEach{ menus[$0].count = 0 }
        menuTableView.reloadData()
        updateOrderInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier,
              id == "ReceiptViewController",
              let receiptVC = segue.destination as? ReceiptViewController,
              let data = sender as? [Menu] else {
            return
        }
        
        receiptVC.orderList = data
    }

    @IBAction func onOrder(_ sender: Any) {
        let orderList = menus.filter{ $0.count > 0 }
        performSegue(withIdentifier: "ReceiptViewController", sender: orderList)
    }
}

//MARK: - Table View Delegate & Data Source
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuTableCell") as! MenuTableViewCell
        let data = menus[indexPath.row]
        
        cell.setData(data)
        cell.onChangeCount = {[weak self] num in
            guard let self = self else { return }
            var count = data.count + num
            if count < 0 { count = 0 }
            self.menus[indexPath.row].count = count
            print(self.menus[indexPath.row])
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            self.updateOrderInfo()
        }
        
        return cell
    }
}


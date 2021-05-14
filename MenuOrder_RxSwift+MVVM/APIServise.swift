//
//  APIServise.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/14.
//

import Foundation

let MENU_URL = "https://firebasestorage.googleapis.com/v0/b/rxswiftin4hours.appspot.com/o/fried_menus.json?alt=media&token=42d5cb7e-8ec4-48f9-bf39-3049e796c936"

class APIService {
    
    static func loadMenu(completed: @escaping ([Menu]) -> Void, errored: @escaping (Error) -> Void) {
        
        let task = URLSession.shared.dataTask(with: URL(string: MENU_URL)!) { (data, response, error) in
            
            if let err = error {
                errored(err)
                return
            }
            
            guard let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
               let list = json["menus"] as? [NSDictionary] else {
                
                return
            }
            
            var menus: [Menu] = []
            
            list.forEach{ value in
                let menu = Menu(name: value["name"] as! String, price: value["price"] as! Int)
                menus.append(menu)
            }

            completed(menus)
        }
        task.resume()
    }
}

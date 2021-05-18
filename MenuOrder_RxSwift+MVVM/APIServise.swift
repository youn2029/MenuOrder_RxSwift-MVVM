//
//  APIServise.swift
//  MenuOrder_RxSwift+MVVM
//
//  Created by 윤성호 on 2021/05/14.
//

import Foundation
import RxSwift
import RxCocoa

let MENU_URL = "https://firebasestorage.googleapis.com/v0/b/rxswiftin4hours.appspot.com/o/fried_menus.json?alt=media&token=42d5cb7e-8ec4-48f9-bf39-3049e796c936"

class APIService {
    
    static func fetchMenuURL(completed: @escaping (Result<Data, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: URL(string: MENU_URL)!) { (data, response, error) in
            
            if let err = error {
                completed(.failure(err))
                return
            }
            
            guard let data = data else {
                
                let httpResponse = response as! HTTPURLResponse
                completed(.failure(NSError(domain: "no Data", code: httpResponse.statusCode, userInfo: nil)))
                return
            }

            completed(.success(data))
        }
        task.resume()
    }
    
    static func jsonToMenus(data: Data) -> [(menu:Menu, cnt: Int)] {
        
        struct Response: Decodable {
            var menus: [Menu]
        }
        
        guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
            return []
        }
        
        return response.menus.map{ ($0, 0) }
    }
    
    static func fetchMenuURLRx() -> Observable<Data> {
        
        return Observable.create{ emitter in
            
            fetchMenuURL { result in
                
                switch result {
                case .failure(let err):
                    emitter.onError(err)
                    
                case .success(let data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}

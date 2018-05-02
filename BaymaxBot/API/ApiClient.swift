//
//  WetherApi.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import Alamofire
import ObjectMapper

class ApiClient {
    
    private let weatherBaseUrl = "http://weather.livedoor.com/forecast/webservice/json/v1"
    private var weatherParameters = [
        "city": "130010"
    ]
    
    func weatherRequest() {
        Alamofire.request(self.weatherBaseUrl, method: .get, parameters: self.weatherParameters).responseJSON { response in
            switch response.result {
                case .success:
                    print("Success: \(String(describing: response.result.value))")
                    break
                case .failure:
                    print("Failure: \(String(describing: response.error))")
                    break
            }
        }
    }
}

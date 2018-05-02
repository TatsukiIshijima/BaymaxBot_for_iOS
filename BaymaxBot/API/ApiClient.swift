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
        "city": "130010"                // 東京
    ]
    
    func weatherRequest(cityCode: String) {
        weatherParameters["city"] = cityCode
        Alamofire.request(self.weatherBaseUrl, method: .get, parameters: self.weatherParameters).responseJSON
            { (response:DataResponse<Any>) in
            switch response.result {
                case .success:
                    print("Success!!")
                    
                    let weatherModel = Mapper<WeatherModel>().map(JSONObject: response.result.value)
                    print("Title: \(String(describing: weatherModel?.title))")
                    print("LinK: \(String(describing: weatherModel?.link))")
                    print("Description Text: \(String(describing: weatherModel?.description?.text))")
                    print("Forecasts Count: \(String(describing: weatherModel?.forecasts?.count))")
                    break
                case .failure:
                    print("Failure: \(String(describing: response.error))")
                    break
            }
        }
    }
}

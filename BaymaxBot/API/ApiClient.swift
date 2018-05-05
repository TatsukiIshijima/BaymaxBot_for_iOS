//
//  WetherApi.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import Alamofire
import ObjectMapper
import RxSwift
import RxCocoa

class ApiClient {
    
    private let weatherBaseUrl = "http://weather.livedoor.com/forecast/webservice/json/v1"
    private var weatherParameters = [
        "city": "130010"                // 東京
    ]
    
    private let replAiRegistUrl = "https://api.repl-ai.jp/v1/registration"
    private let replAiTalkUrl = "https://api.repl-ai.jp/v1/dialogue"
    private var replHeaders:HTTPHeaders = [
        "Content-Type": "application/json",
        "x-api-key": ""                             // APIキー
    ]
    private var replGetbotIdParameter = [
        "botId": ""                                 // ボットID
    ]
    private var replTalkParameters: [String: Any] = [
        "appUserId": "",                            // ユーザーID
        "botId": "",                                // ボットID
        "voiceText": "",                            // 発話テキスト
        "initTalkingFlag": true,                    // 初回発話フラグ
        "initTopicId": ""                           // シナリオID
    ]
    
    init() {
        if let apiKey = KeyManager().getValue(key: "apiKey") as? String {
            self.replHeaders["x-api-key"] = apiKey
        }
        if let botId = KeyManager().getValue(key: "botId") as? String {
            self.replGetbotIdParameter["botId"] = botId
            self.replTalkParameters["botId"] = botId
        }
        if let scenarioId = KeyManager().getValue(key: "scenarioId") as? String {
            self.replTalkParameters["initTopicId"] = scenarioId
        }
    }
    
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
    
    func weatherRequestRx(cityCode: String) -> Observable<WeatherModel> {
        return Observable.create { (observer: AnyObserver<WeatherModel>) in
            Alamofire.request(self.weatherBaseUrl, method: .get, parameters: self.weatherParameters).responseJSON
                { (response:DataResponse<Any>) in
                    switch response.result {
                        case .success:
                            let weatherModel = Mapper<WeatherModel>().map(JSONObject: response.result.value)
                            observer.onNext(weatherModel!)
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    
    func replAiInitRequestRx() -> Observable<UserId> {
        return Observable.create { (observer: AnyObserver<UserId>) in
            Alamofire.request(self.replAiRegistUrl, method: .post, parameters: self.replGetbotIdParameter, encoding: JSONEncoding.default, headers: self.replHeaders).responseJSON { (response:DataResponse<Any>) in
                    switch response.result {
                        case .success:
                            let userId = Mapper<UserId>().map(JSONObject: response.result.value)
                            observer.onNext(userId!)
                            observer.onCompleted()
                            break
                        case .failure(let error):
                            observer.onError(error)
                            break
                    }
            }
            return Disposables.create()
        }
    }
    
    func replAiTalkRequestRx(appUserId: String, voiceText: String) -> Observable<ReplModel> {
        return Observable.create { (observer: AnyObserver<ReplModel>) in
            self.replTalkParameters["appUserId"] = appUserId
            self.replTalkParameters["voiceText"] = voiceText
            Alamofire.request(self.replAiTalkUrl, method: .post, parameters: self.replTalkParameters, encoding: JSONEncoding.default,
                              headers: self.replHeaders).responseJSON{ (response: DataResponse<Any>) in
                                switch response.result {
                                    case .success:
                                        let replModel = Mapper<ReplModel>().map(JSONObject: response.result.value)
                                        print(response.result.value ?? "")
                                        observer.onNext(replModel!)
                                        observer.onCompleted()
                                        break
                                    case .failure(let error):
                                        observer.onError(error)
                                        break
                                }
            }
            return Disposables.create()
        }
    }
}

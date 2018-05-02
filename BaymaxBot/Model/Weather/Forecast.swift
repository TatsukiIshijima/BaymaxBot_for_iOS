//
//  forecast.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/05/02.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import ObjectMapper

class Forecast: Mappable {
    
    var date: String?               // 予報日
    var dateLabel: String?          // 予報日（今日、明日、明後日）
    var telop: String?              // 天気（晴れ、曇り、雨）
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        date<-map["date"]
        dateLabel<-map["dateLabel"]
        telop<-map["telop"]
    }
}

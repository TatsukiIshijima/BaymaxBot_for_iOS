//
//  Description.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import ObjectMapper

class Description : Mappable{
    
    var text: String?                       // テキスト
    var publicTime: String?                 // 発行日
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        text<-map["text"]
        publicTime<-map["publicTime"]
    }
}

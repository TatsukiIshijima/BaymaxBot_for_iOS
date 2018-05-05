//
//  SystemText.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/05/05.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import ObjectMapper

class SystemText: Mappable {
    
    var expression: String?             // システムからの返答
    var utterance: String?              // 音声合成用テキスト
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        expression<-map["expression"]
        utterance<-map["utterance"]
    }
}

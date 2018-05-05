//
//  ReplModel.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/05/05.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import ObjectMapper

class ReplModel: Mappable {
    
    var systemText: SystemText?             // システムからの返答一覧
    var serverSendTime: String?             // サーバがレスポンスを送信した時刻
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        systemText<-map["systemText"]
        serverSendTime<-map["serverSendTime"]
    }
}

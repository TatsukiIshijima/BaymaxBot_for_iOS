//
//  UserId.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/05/05.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import ObjectMapper

class UserId: Mappable {
    
    var userId: String?         // ユーザーID
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        userId<-map["appUserId"]
    }
}

//
//  WetherModel.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//
// RxSwift学習用のサンプルモデル
//

import ObjectMapper

class WetherModel: Mappable {
    
    var title: String?                  // タイトル
    var link: String?                   // リンク
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title<-map["title"]
        link<-map["link"]
    }
}


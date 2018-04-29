//
//  WetherModel.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//
// RxSwift学習用のサンプルモデル
//

import Foundation
import Himotoki

struct WetherModel: Himotoki.Decodable {
    let title: String           // タイトル
    let description: String     // 説明
    let today: String           // 今日
    let tomorrow: String        // 明日
    
    static func decode(_ e: Extractor) throws -> WetherModel {
        return try WetherModel(
            title: e <| "title",
            description: e <| "description",
            today: e <| "today",
            tomorrow: e <| "tomorrow")
    }
}

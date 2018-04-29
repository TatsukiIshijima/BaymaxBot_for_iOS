//
//  Api.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/04/29.
//  Copyright © 2018年 石島樹. All rights reserved.
//
//  API Client

import Foundation
import APIKit
import Himotoki

protocol ApiRequest: Request {
    
}

extension ApiRequest {
    var baseUrl: URL {
        return URL(string: "http://weather.livedoor.com")
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard(200..<300).contains(urlResponse.statusCode) else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
}

extension ApiRequest where Response: Decodable {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Self.Response {
        return try decodeValue(object)
    }
}

struct FetchWetherApiRequest: ApiRequest {
    var cityCode: String
    var path: String {
        return "/forecast/webservice/json/v1/\(self.cityCode)"
    }
    typealias Response = [WetherModel]
    
    var method: HTTPMethod {
        return .get
    }
    
    init(cityCode: String) {
        self.cityCode = cityCode
    }
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> FetchRepositoryRequest.Response {
        return try decodeArray(object)
    }
}

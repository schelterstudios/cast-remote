//
//  URLRequest+Service.swift
//  Picture Clue
//
//  Created by Steve Schelter on 10/20/17.
//  Copyright © 2017 Picture Clue LLC. All rights reserved.
//

import Foundation

enum ContentType: String {
    case json = "application/json", form = "application/x-www-form-urlencoded"
}

extension URLRequest {
    
    func setValue(_ value: String, forHTTPHeaderField field: String) -> URLRequest {
        var mself = self
        mself.addValue(value, forHTTPHeaderField: field)
        return mself
    }
    
    func addURLParams(_ params: [String:Any]) -> URLRequest {
        var mself = self
        let urlstr = mself.url!.absoluteString
        let join = urlstr.contains("?") ? "&" : "?"
        let newUrlStr = params.map{"\($0)=\($1)"}.reduce(urlstr+join){[$0, $1].joined(separator: "&")}
        mself.url = URL(string: newUrlStr)
        return mself
    }
    
    func setPostBody(_ params: Any?) -> URLRequest {
        return setPostBody(params, as: .json)
    }
    
    func setPostBody(_ params: Any?, as contentType: ContentType) -> URLRequest {
        var mself = self
        mself.httpMethod = "POST"
        return params.map{ mself.setBody($0, as: contentType) } ?? mself
    }
    
    func setPutBody(_ params: Any?) -> URLRequest {
        return setPutBody(params, as: .json)
    }
    
    func setPutBody(_ params: Any?, as contentType: ContentType) -> URLRequest {
        var mself = self
        mself.httpMethod = "PUT"
        return params.map{ mself.setBody($0, as: contentType) } ?? mself
    }
    
    func setPatchBody(_ params: Any?) -> URLRequest {
        return setPatchBody(params, as: .json)
    }
    
    func setPatchBody(_ params: Any?, as contentType: ContentType) -> URLRequest {
        var mself = self
        mself.httpMethod = "PATCH"
        return params.map{ mself.setBody($0, as: contentType) } ?? mself
    }
    
    func setBody(_ params: Any, as contentType: ContentType) -> URLRequest {
        var mself = self
        
        let body:Data?
        switch(contentType) {
        case .json :
            body = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            break
        case .form :
            let fparams = params as! [String:Any]
            let str = fparams.map{"\($0)=\($1)"}.reduce(""){[$0, $1].joined(separator: "&")}
            body = str.data(using: .utf8)
            break
        }
        
        mself.httpBody = body
        mself.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        return mself
    }
    
    func prepareUpload(_ boundary: String) -> URLRequest {
        var mself = self
        mself.httpMethod = "POST"
        return mself.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    }
    
    func prepareDelete() -> URLRequest {
        var mself = self
        mself.httpMethod = "DELETE"
        return mself
    }
}

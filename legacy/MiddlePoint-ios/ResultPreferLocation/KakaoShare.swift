//
//  KakaoShare.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/08/25.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//


import UIKit
import CoreLocation
import KakaoSDKCommon
import KakaoSDKLink
import KakaoSDKTemplate

struct ShareData: Codable {
    let latitude: Double
    let longitude: Double
    let cafe: String
    let transit: String
    let restaurnt: String
}

class KakaoShare {
    
    static let shared = KakaoShare()
    
    func makeKakoLinkMessageTemplate(shareData: ShareData) {
        /// 카카오로 공유할 데이터들을 템플릿화 시키는 함수
        let text = "친구들과 만날장소를 MiddlePoint를 이용해서 찾아보세요~친구가 공유한 장소를 확인해볼까요?"
        let type = "text"
        let parms = "longitude=\(shareData.longitude)&latitude=\(shareData.latitude)&cafe=\(shareData.cafe)&transit=\(shareData.transit)&restaurnt=\(shareData.restaurnt)"
        let buttonTitle = "바로 확인"
        
        let textTemplateJsonStringData =
            """
                {
                "objectType": "\(type)",
                "text": "\(text)",
                "link": {
                "iosExecutionParams": "\(parms)"
                },
                "buttonTitle": "\(buttonTitle)"
                }
                """.data(using: .utf8)!
        
        
        if let templatable = try? SdkJSONDecoder.custom.decode(TextTemplate.self, from: textTemplateJsonStringData) {
            LinkApi.shared.defaultLink(templatable: templatable) {(linkResult, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("defaultLink() success.")
                    
                    if let linkResult = linkResult {
                        UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func checkKakaoLink(url: URL) {
        //카카오링크가 들어왔을겨우 스킴이 있는지 확인 해서 맞는 URL 인지 확인
        guard url.absoluteString.contains("kakao4cf75446fcd6b49ff2a251e58bdf2400") else {
            return
        }
        
        guard let urlComponet = URLComponents(string: url.absoluteString) else {
            return
        }
        
        //URL 에 붙어온 쿼리 아이템을 파싱해서 앱내에서 사용할수있도록 저장하는 로직
        
        guard let queryItems = urlComponet.queryItems else { return }
        
        guard let longitude: CLLocationDegrees = NumberFormatter().number(from: queryItems.first(where: {$0.name == "longitude"})?.value ?? "0")?.doubleValue,
            let latitude: CLLocationDegrees = NumberFormatter().number(from: queryItems.first(where: {$0.name == "latitude"})?.value ?? "0")?.doubleValue,
            let cafe = queryItems.first(where: {$0.name == "cafe"})?.value,
            let transit = queryItems.first(where: {$0.name == "transit"})?.value,
            let restaurnt = queryItems.first(where: {$0.name == "restaurnt"})?.value else { return }
        
        let preferLocationList: [(title:PreferType, selection: Bool)] = [(title: PreferType.transit, selection: transit == "" ? false : true), (title: .coffee, selection: cafe == "" ? false : true), (title: .restaurant, selection: restaurnt == "" ? false : true)]
        
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController?.children.last else { return}
        
        let resultViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultPreferLocationViewController") as! ResultPreferLocationViewController
        
        resultViewController.centerCoordination = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        resultViewController.preferLocationList = preferLocationList
        
        rootViewController.navigationController?.pushViewController(resultViewController, animated: true)
        
    }
    
}

//
//  AppDelegate.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/05/17.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//
import UIKit

import GooglePlaces
import GoogleMaps
import KakaoSDKCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let apiKey = "AIzaSyBT8VE0fl_bgSw51UQzs-5sKUZAvJcrFs4"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
        
        Thread.sleep(forTimeInterval: 1.0)
        
        KakaoSDKCommon.initSDK(appKey: "4cf75446fcd6b49ff2a251e58bdf2400")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        KakaoShare.shared.checkKakaoLink(url: url)
        
        return true
    }
    
}

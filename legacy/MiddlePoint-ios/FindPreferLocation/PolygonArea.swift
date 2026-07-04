//
//  Poligon.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/06/07.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import CoreLocation

class PolygonArea {
    //다각형의 area를 구하는 함수
    func signedPolygonArea(polygon: [CLLocationCoordinate2D]) -> Double {
        let count = polygon.count
        var area: Double = 0
        
        for i in 0 ..< count {
            // j 값을 count 로 나눈후 값을 사용하기위해 % 를 사용 count 넘어가면 데이터가 없어서 에러가 나기때문에 이런식으로만듬
            let j = (i + 1) % count
            area = area + polygon[i].latitude * polygon[j].longitude
            area = area - polygon[i].longitude * polygon[j].latitude
        }
        
        area = area/2.0
        
        return area
    }
    
    //두점의 중앙값을 만드는 함수
    func centerByTwoSpot(polygon: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let centerX = (polygon[0].latitude + polygon[1].latitude) / 2
        let centerY = (polygon[0].longitude + polygon[1].longitude) / 2
        
        return CLLocationCoordinate2D(latitude: centerX, longitude: centerY)
    }
    
    //다각형의 무개중심을 함수
    func polygonCenter(polygon: [CLLocationCoordinate2D], completion: @escaping (Bool, CLLocationCoordinate2D?) -> Void) {
        if polygon.count < 2 {
            //좌표들의 배열이 2보다 작으면 그냥 끝낸다
            completion(false, nil)
        } else if polygon.count == 2 {

            //좌표들의 배열이 2이면 두배열의 중앙값을 만들어 사용처로 넘긴다.
            //centerByTwoSpot 는 두점의 중앙값을 만드는 함수

            let center = centerByTwoSpot(polygon: polygon)
            completion(true, center)
        } else {
            let count = polygon.count
            var centerX: Double = 0
            var centerY: Double = 0
            var area = signedPolygonArea(polygon: polygon)
            
            for i in 0 ..< count {
                // j 값을 count 로 나눈후 값을 사용하기위해 % 를 사용 count 넘어가면 데이터가 없어서 에러가 나기때문에 이런식으로만듬
                let j = (i + 1) % count
                let factor1 = polygon[i].latitude * polygon[j].longitude - polygon[j].latitude * polygon[i].longitude
                centerX = centerX + (polygon[i].latitude + polygon[j].latitude) * factor1
                centerY = centerY + (polygon[i].longitude + polygon[j].longitude) * factor1
            }
            
            area = area * 6.0
            
            let factor2 = 1.0/area
            centerX = centerX * factor2
            centerY = centerY * factor2
            
            if centerX.isNaN || centerY.isNaN {
                //중앙 xy값중 알수없으면 실패
                completion(false, nil)
            } else {
                //중앙 xy값으로 좌표 값을 생성해서 넘김
                let center = CLLocationCoordinate2D(latitude: centerX, longitude: centerY)
                
                completion(true, center)
            }
        }
    }
}

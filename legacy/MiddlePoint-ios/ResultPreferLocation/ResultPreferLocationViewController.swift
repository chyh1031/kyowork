//
//  ShowPreferLocationViewController.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/06/07.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit

import GoogleMapsBase
import GoogleMaps
import GooglePlaces
import Alamofire

enum CurrentLocationType {
    case eachPlaceRecomand
    case wholePlace
}

class ResultPreferLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var geocoder: GMSGeocoder! // Google API 로 주소 -> 좌표, 좌표 -> 주소 로 바꾸기위한 모듈
    var searchAddressModel: SearchAddressModel? // 나의 위치 정보를 담을 변수
    var centerCoordination: CLLocationCoordinate2D?
    var marker: GMSMarker!
    var placeClient: GMSPlacesClient!
    var place: GMSPlace!
    var preferLocationList: [(title:PreferType, selection: Bool)]?
    let locationManager = CLLocationManager()
    let placeCardView = PlaceCardView()
    var placeCardViewBottomConstraint: NSLayoutConstraint!
    
    var currentWholeData: [PlaceDataResults] = []
    var currentTransitData: [PlaceDataResults] = []
    var currentRestaurntData: [PlaceDataResults] = []
    var currentCafeData: [PlaceDataResults] = []
    
    var searchRadius: Double = 1000
    
    var currentLocationType: CurrentLocationType = .wholePlace
    
    @IBOutlet weak var reconmandButton: UIButton!
    
    @IBAction func recomandButtonDidTap(_ sender: Any) {
        closePlaceCardView()
        
        if currentLocationType == .eachPlaceRecomand {
            currentLocationType = .wholePlace
            reconmandButton.setTitle("순위 추천 보기", for: .normal)
        } else {
            currentLocationType = .eachPlaceRecomand
            reconmandButton.setTitle("전체 보기", for: .normal)
        }
        
        //지도 초기화
        mapView.clear()
        
        //범위원, 카메라 위치를 선택된 마커로 다시 세팅
        setMapCircle()
        setMapCamera(position: centerCoordination)
        
        var transitData = currentTransitData
        var cafeData = currentCafeData
        var restaurntData = currentRestaurntData
        
        switch currentLocationType {
    
        case .eachPlaceRecomand:
            transitData = currentTransitData.suffix(3)
            cafeData = currentCafeData.suffix(3)
            restaurntData = currentRestaurntData.suffix(3)
        default :
            break
        }
       
        ///데이터들을 다시 색에 맞춰서 세팅 , 그중 세팅된 마커의 데이터를 가지고 있다면 색을 변경하고 그위치로 카메라를 위치시킨다.
        
        for data in transitData {
            let markerColor = UIColor.green
            
            guard let location = data.geometry?.location else { return }
            guard let name = data.name else { return }
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            icon.image = UIImage(named: "icon")
            icon.tintColor = markerColor
            
            marker.snippet = name
            marker.iconView = icon
            marker.map = self.mapView
        }
        
        for data in cafeData {
            let markerColor = UIColor.brown
            
            guard let location = data.geometry?.location else { return }
            guard let name = data.name else { return }
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            icon.image = UIImage(named: "icon")
            icon.tintColor = markerColor
            
            marker.snippet = name
            marker.iconView = icon
            marker.map = self.mapView
        }
        
        for data in restaurntData {
            let markerColor = UIColor.red
            
            guard let location = data.geometry?.location else { return }
            guard let name = data.name else { return }
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            icon.image = UIImage(named: "icon")
            icon.tintColor = markerColor
            
            marker.snippet = name
            marker.iconView = icon
            marker.map = self.mapView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        setPlaceCardView()
        setNavigationBarItem()

        guard let centerCoordination = centerCoordination else  { return }
        //preferLocationList 의 선호장소 의 선택 유뮤에 따라서 장소를 검색 시작
        
        preferLocationList?.forEach {
            if $0.selection == true {
                
                switch $0.title {
                // title 이 coffee일경우 커피숍 검색
                case .coffee:
                    self.getNearPlaces(type: "cafe", centerLocation: centerCoordination)
                // title 이 restaurant일경우 레스토랑 검색
                case .restaurant:
                    self.getNearPlaces(type: "restaurant", centerLocation: centerCoordination)
                default:
                    // title 이 transit일경우 버스와 지하철을 검색
                    self.getNearPlaces(type: "bus_station", centerLocation: centerCoordination)
                    self.getNearPlaces(type: "subway_station", centerLocation: centerCoordination)
                }
            }
        }
    }
    
    func setNavigationBarItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "공유하기", style: .plain, target: self, action: #selector(shareButtonDidTapped))
    }
    
    @objc func shareButtonDidTapped() {
        guard let centerCoordination = centerCoordination else { return }
        KakaoShare.shared.makeKakoLinkMessageTemplate(shareData: ShareData(latitude: centerCoordination.latitude, longitude: centerCoordination.longitude, cafe: preferLocationList?[1].selection == true ? "cafe" : "", transit: preferLocationList?[0].selection == true ? "transit" : "", restaurnt: preferLocationList?[2].selection == true ? "restaurnt" : ""))
    }
    
    func setMapView() {
        setMapCircle()
        setMapCamera(position: centerCoordination)
        
        self.mapView.delegate = self
        
        
    }
    
    func setMapCircle() {
        guard let centerCoordination = centerCoordination else  { return }
        
        let marker = GMSMarker(position: centerCoordination)
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        
        icon.image = UIImage(named: "icon")
        icon.tintColor = UIColor(red: 102/244, green: 65/244, blue: 241/244, alpha: 1)
        
        marker.iconView = icon
        marker.map = self.mapView
        
        let circle = GMSCircle(position: centerCoordination, radius: searchRadius)
        circle.fillColor = UIColor(red: 102/244, green: 65/244, blue: 241/244, alpha: 0.2)
        circle.map = mapView;
    }
    
    func setMapCamera(position: CLLocationCoordinate2D?, zoom: Float = 14) {
        guard let centerCoordination = position else  { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: centerCoordination.latitude, longitude: centerCoordination.longitude, zoom: zoom)
        mapView.camera = camera
        
    }
    
    func setPlaceCardView() {
        view.addSubview(placeCardView)
        placeCardView.delegate = self
        placeCardView.translatesAutoresizingMaskIntoConstraints = false
        placeCardView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        placeCardView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        placeCardViewBottomConstraint = placeCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 250)
        placeCardViewBottomConstraint.isActive = true
        placeCardView.layer.cornerRadius = 45
    }
    
    
    func getNearPlaces(type: String, centerLocation: CLLocationCoordinate2D) {
        guard let url = URL(string:
                                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(centerLocation.latitude),\(centerLocation.longitude)&radius=\(searchRadius)&type=\(type)&key=AIzaSyCoIL-hzWRe6fnwdCNMIVWvBPteQxI48nc") else { return }
        // 네트워크 라이브러리인 Alamofire 를 사용해서 url로 리퀘스트 해서 리스폰스를 json으로 받음
        AF.request(url, method: .get).validate().responseJSON { [weak self] response in
            
            guard let `self` = self else { return }
            
            do {
                // result json 을 앱에서 사용할수있는 데이터 구조체인 PlaceData으로 디코딩함
                let result = try JSONDecoder().decode(PlaceData.self, from: response.data!)
                
                //placeData 의 results 가 값이 비어있으면 끝냄 아니면 데이터를 처리함
                guard let placeData = result.results else { return }
                //기본 마커 값 검은색으로 설정
                
                self.setMapMarker(type: type, placeData: placeData)
            }
            catch {
                return
            }
        }
        
    }
    
    func setMapMarker(type: String, placeData: [PlaceDataResults]) {
        var markerColor: UIColor = UIColor.black
        
        if type == "restaurant" {
            //레스토랑 데이터가 있을경우 저장하고 마커를 빨간색으로 변경
            currentRestaurntData = placeData
            
            //레스토랑 데이터의 rating
            currentRestaurntData.sort { $0.rating ?? 0 < $1.rating ?? 0}
            
            markerColor = UIColor.red
        } else if type == "cafe" {
            //카페 데이터가 있을경우 저장하고 마커를 갈색으로 변경
            self.currentCafeData = placeData
            
            currentCafeData.sort { $0.rating ?? 0 < $1.rating ?? 0}
            
            markerColor = UIColor.brown
        } else {
            //버스 지하철 데이터가 있을경우 저장하고 마커를 초록색으로 변경
            if self.currentTransitData.isEmpty == false {
                currentTransitData.append(contentsOf: placeData)
            } else {
                currentTransitData = placeData
            }
            
            currentTransitData.sort { $0.rating ?? 0 < $1.rating ?? 0}
            
            markerColor = UIColor.green
        }
        
        for result in placeData {
            //받아온 데이터 만큼 지도에 마커를 찍어줌
            guard let location = result.geometry?.location else { return }
            guard let name = result.name else { return }
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            icon.image = UIImage(named: "icon")
            icon.tintColor = markerColor
            
            marker.snippet = name
            marker.iconView = icon
            marker.map = self.mapView
        }
        
        currentWholeData.append(contentsOf: placeData)
        
        print("placeData: \(placeData)")
    }
    
}

extension ResultPreferLocationViewController: PlaceCardViewDelegate {
    func closePlaceCardView() {
        /// 카드뷰를 닫아준다 Constraint 값 변경으로 내림
        placeCardViewBottomConstraint.constant = 250
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ResultPreferLocationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard marker.position != centerCoordination else {
            closePlaceCardView()
            
            return false
        }
        
        ///선택한 마커의 필요한 데이터 저장
        let selectedMarkerSnipet = marker.snippet
        let selectedMarkerPosition = marker.position
        let selectedMarkerColor = UIColor(red: 102/244, green: 65/244, blue: 241/244, alpha: 1)
        
        /// 카드뷰를 열어준다  Constraint 값 변경으로 올림
        if placeCardViewBottomConstraint.constant == 250 {
            placeCardViewBottomConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        var zoom = mapView.camera.zoom
        if mapView.camera.zoom <= 14 {
            zoom = 15
        }
        //지도 초기화
        mapView.clear()
        
        //범위원, 카메라 위치를 선택된 마커로 다시 세팅
        setMapCircle()
        setMapCamera(position: selectedMarkerPosition, zoom: zoom)
        
        var transitData = currentTransitData
        var cafeData = currentCafeData
        var restaurntData = currentRestaurntData
        
        switch currentLocationType {
    
        case .eachPlaceRecomand:
            transitData = currentTransitData.suffix(3)
            cafeData = currentCafeData.suffix(3)
            restaurntData = currentRestaurntData.suffix(3)
        default :
            break
        }
       
        ///데이터들을 다시 색에 맞춰서 세팅 , 그중 세팅된 마커의 데이터를 가지고 있다면 색을 변경하고 그위치로 카메라를 위치시킨다
        
        for data in transitData {
            let markerColor = UIColor.green
            
            guard let location = data.geometry?.location else { return false }
            guard let name = data.name else { return false }
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            icon.image = UIImage(named: "icon")
            
            marker.snippet = name
            
            ///선택된 마커라면 색을 변경
            if marker.position == selectedMarkerPosition {
                icon.tintColor = selectedMarkerColor
            } else {
                icon.tintColor = markerColor
            }
            
            marker.iconView = icon
            marker.map = self.mapView
            
             ///선택된 마커라면 장소 데이터를 카드뷰에 보여줌
            if data.name == selectedMarkerSnipet {
                placeCardView.setPlaceData(data: data)
            }
        }
        
        for data in cafeData {
            let markerColor = UIColor.brown
            
            guard let location = data.geometry?.location else { return false }
            guard let name = data.name else { return false }
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            icon.image = UIImage(named: "icon")
            
            marker.snippet = name
            
             ///선택된 마커라면 색을 변경
            if marker.position == selectedMarkerPosition {
                icon.tintColor = selectedMarkerColor
            } else {
                icon.tintColor = markerColor
            }
            
            marker.iconView = icon
            marker.map = self.mapView
            
            ///선택된 마커라면 장소 데이터를 카드뷰에 보여줌
            if data.name == selectedMarkerSnipet {
                placeCardView.setPlaceData(data: data)
            }
        }
        
        for data in restaurntData {
            let markerColor = UIColor.red
            
            guard let location = data.geometry?.location else { return false }
            guard let name = data.name else { return false }
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            icon.image = UIImage(named: "icon")
            
            marker.snippet = name
            
            ///선택된 마커라면 색을 변경
            if marker.position == selectedMarkerPosition {
                icon.tintColor = selectedMarkerColor
            } else {
                icon.tintColor = markerColor
            }
            
            marker.iconView = icon
            marker.map = self.mapView
            
            ///선택된 마커라면 장소 데이터를 카드뷰에 보여줌
            if data.name == selectedMarkerSnipet {
                placeCardView.setPlaceData(data: data)
            }
        }
        
        return true
    }
}

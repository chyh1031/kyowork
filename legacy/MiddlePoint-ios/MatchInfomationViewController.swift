//
//  MatchInfomationViewController.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/05/17.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class FindAddressViewController: UIViewController {
    var geocoder: GMSGeocoder? // Google API 로 주소 -> 좌표, 좌표 -> 주소 로 바꾸기위한 모듈
    var locationManager: CLLocationManager! // 디바이스 현위치 좌표를 알아오기위한 모듈
    var peopleCountArray: [Int] = [1,2,3,4,5,6,7,8,9,10] // 만날 친구의 명수를 담은 배열
    var toolBar = UIToolbar() // 만날 친구를 선택할 PickerView 에 달릴 툴바
    var picker  = UIPickerView()// 만날 친구를 선택 하는 기능의 PickerView
    var myCoordination: CLLocationCoordinate2D? // 나의 위치 정보를 담을 변수
    var friendsCoordinations: [CLLocationCoordinate2D] = [] // 친구들의 위치정보를 담을 배열 변수
    var myAddress: String = "" // 내 주소를 담을 변수
    var friendsAddress: [String] = [] // 친구들의 주소를 담을 배열 변수
    var selectedRow: Int = 0 // 친구들 위치정보를 찾기위해 선택한 셀의 index 변수
    var currentPeopleCount = 0 {
        didSet {
            settingPeopleAddressData()
            friendsAddressTableView.reloadData()
            changeYCenterConstraint(currentPeopleCount: currentPeopleCount)
        }
    } // 만날 친구들의 명수 변수
    
    @IBOutlet weak var ycenterConstraint: NSLayoutConstraint! // 중앙 정렬 위치 값
    @IBOutlet weak var peopleCountLabel: UILabel! // 친구들 명수를 보여줄 라벨
    @IBOutlet weak var myAddressLabel: UILabel! // 나의 위치를 보여줄 라벨
    @IBOutlet weak var friendsAddressTableView: UITableView! // 친구들의 정보를 보여줄 테이블 뷰
    @IBOutlet weak var nextButton: UIButton! // 다음페이지로 갈 버튼
    @IBOutlet weak var resetCurrentLocationButton: UIBarButtonItem! // 현재 나의 위치를 초기화 하는 버튼
    
    override func viewDidLoad() {
        // 현재 화면이 로드가 된후에 불리는 함수
        // 이곳에서 바로 위치정보를 설정 하고
        // 친구선택을 위한 pickerView 를 설정한다.
        // 친구들의 데이터를 보여줄 테이블뷰 도 설정.
        super.viewDidLoad()
        friendsAddressTableView.delegate = self
        friendsAddressTableView.dataSource = self
        geocoder = GMSGeocoder()
        settingLocationManager()
        settingPeopleCountPickerView()
    }
    
    func changeYCenterConstraint(currentPeopleCount: Int) {
        // 친구 선택을 했을 경우 애니메이션을 줘서 화면을 더 잘사용하도록 변경
        
        if currentPeopleCount == 0 {
            // 친구가 선택되어있지 않을경우 다음 버튼을 숨기고 가운데로 보여준다.
            ycenterConstraint.constant = 0
            UIView.animate(withDuration: 0.7) {
                self.view.layoutIfNeeded()
            }
            nextButton.isHidden = true
            
            return
        }
        
        if ycenterConstraint.constant == 0 {
            // 중앙 정렬 위치해 있다면 위로 올려준다.
            ycenterConstraint.constant = -(view.frame.height/4)
            UIView.animate(withDuration: 0.7) {
                self.view.layoutIfNeeded()
            }
            nextButton.isHidden = false
        }
    }
    
    func settingLocationManager() {
        // 디바이스 위치정보를 가져오기위해 세팅하는 함수
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func getCurrentLocationCoordinate() {
        // 디바이스 위치정보중 위도 경도를 가져와서 주소로 변환해주는 함수
        myCoordination = locationManager.location?.coordinate
        
        guard let coordination = myCoordination else { return }
        
        geocoder?.reverseGeocodeCoordinate(coordination) { response, error in
            
            if error != nil {
                // 위도경도로 주소를 불러왔는데 Error 가 온다면 텍스트 내용과 색을 변경
                self.myAddressLabel.text = "위치를 찾지 못했습니다.\n다시 받아와주세요."
               
                return
            }
            
            if let location = response?.firstResult() {
                var address = ""
                
                guard let lines = location.lines else {
                     // 위도경도로 주소를 불러왔는데 정보가 없다면 텍스트 내용과 색을 변경
                    self.myAddressLabel.text = "위치를 찾지 못했습니다.\n다시 받아와주세요."
                   
                    return
                }
                address = lines[0]
                address = address.trimmingCharacters(in: .whitespacesAndNewlines)
                self.myAddressLabel.text = address
                self.myAddress = address
                self.myAddressLabel.textColor = .black
                
                return
            }
        }
    }
    
    func settingPeopleCountPickerView() {
        // 인원 선택을 위한 pickerView를 구성하는 함수
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "선택완료", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        toolBar.tintColor = UIColor(red: 102/244, green: 65/244, blue: 241/244, alpha: 1)
    }
    
    @objc func onDoneButtonTapped() {
        //picker view toolbar 의 선택완료 버튼을 눌럿을경우 실행하는 함수
        //툴바를 화면에서 지워줌
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    func settingPeopleAddressData() {
        if friendsAddress.count < currentPeopleCount {
            // 친구의 명수가 추가된경우 추가된 명수 만큼 배열을 추가한다.
            var addCount = currentPeopleCount - friendsAddress.count
            
            while addCount != 0 {
                friendsAddress.append("")
                addCount = addCount - 1
            }
            
        } else if friendsAddress.count > currentPeopleCount {
             // 친구의 명수가 빠졋을경우 빠진 명수 만큼 배열을 추가한다.
            var deleteCount = friendsAddress.count - currentPeopleCount
            
            while deleteCount != 0 {
                friendsAddress.removeLast()
                deleteCount = deleteCount - 1
            }
        }
    }
    
    @IBAction func resetButtonDidTap(_ sender: UIBarButtonItem) {
        // 초기화 버튼을 눌렀을경우 모든 데이터를 초기값으로 세팅한다.
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        selectedRow = 0
        currentPeopleCount = 0
        myCoordination = nil
        myAddress = ""
        friendsAddress = []
        friendsCoordinations = []
        peopleCountLabel.textColor = .lightGray
        peopleCountLabel.text = "만나는 친구가 몇명이신가요?"
        resetCurrentLocationButtonDidTap(resetCurrentLocationButton)
        settingPeopleCountPickerView()
    }
    
    @IBAction func resetCurrentLocationButtonDidTap(_ sender: UIBarButtonItem) {
        //현위치 주소를 다시받아오는 버튼을 눌럿을경우 실행하는 함수
        myAddressLabel.textColor = .lightGray
        myAddressLabel.text = "내 현위치 다시 검색중 .."
        getCurrentLocationCoordinate()
    }
    
    @IBAction func peopleCountButtonDidTap(_ sender: Any) {
        //인원이 몇명이신가요 버튼을 눌렀을 경우 실행하는 함수
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
    }
    
    @IBAction func nextButtonDidtap(_ sender: Any) {
        if friendsCoordinations.count == currentPeopleCount {
            //선택한 친구들 명수와 친구들 위치 정보 개수가 같을경우에만 다음페이지로 넘긴다
        } else {
            // 아닐 경우 Alert를 띄운다.
            let alert = UIAlertController(title: "", message: "친구들의 위치정보를 확인해주세요.",preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension FindAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 테이블 뷰가 리로드 될때마다 불림
        // 선택한 친구 명수 만큼 테이블뷰 셀 개수를 구성한다.
        return currentPeopleCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 셀마다 들어갈 정보들을 로드한다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendAddressTableViewCell") as! FriendAddressTableViewCell
        cell.load(address: friendsAddress[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀을 클릭했을경우 위치정보 검색 화면을 띄운다.
        selectedRow = indexPath.row
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        filter.country = "KR"
        filter.origin = locationManager.location
        //한국의 지오코드 정보를 사용하기 위한 세팅 
        autocompleteController.autocompleteFilter = filter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

extension FindAddressViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // 구글 위치정보 검색이 완료 되었을때 선택한 주소 이름을 가져옴
        // 가져온 주소로 위도 경도 값을 가져와서 저장함
        guard let placeName = place.name else { return }
        friendsAddress[selectedRow] = placeName
        
        CLGeocoder().geocodeAddressString(placeName) { placeMarks, error in
            if error != nil {
                print("에러 발생: 에러")
                self.friendsAddress[self.selectedRow] = "위치를 찾지 못했습니다.\n다시 받아와주세요."
                self.friendsAddressTableView.reloadData()
                return
            }
            guard let coordinate = placeMarks?[0].location?.coordinate else {
                print("에러 발생: 데이터 없음")
                self.friendsAddress[self.selectedRow] = "위치를 찾지 못했습니다.\n다시 받아와주세요."
                self.friendsAddressTableView.reloadData()
                return
                
            }
            self.friendsCoordinations.append(coordinate)
        }
        
        friendsAddressTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // 주소를 가져오다 에러 발생시 이 로직을 탐
        // 위치정보를 찾지 못했다는것을 알려줌
        friendsAddress[selectedRow] = "위치를 찾지 못했습니다.\n다시 받아와주세요."
        friendsAddressTableView.reloadData()
        print("Error: ", error.localizedDescription)
    }
    
   
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        //취소했을경우
        friendsAddressTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}

extension FindAddressViewController: CLLocationManagerDelegate {
    //디바이스 현위치 좌표를 알아오기위한 모듈 을 사용했을경우 반환받는 정보를 처리하는 함수
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //권한설정에 따라설 분기
        if status == CLAuthorizationStatus.denied {
            //위치권한 거부되있을 경우
        } else if status == CLAuthorizationStatus.authorizedAlways{
            //위치권한 항상
            getCurrentLocationCoordinate()
        } else if status == CLAuthorizationStatus.authorizedWhenInUse{
            //앱실행중일시
            getCurrentLocationCoordinate()
        }
    }
}

extension FindAddressViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //pickerView 세팅 후에 안에 보여주는 데이터를 세팅하는 로직
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //만날 친구의 명수를 담은 배열의 각 데이터를 보여줌 1,2,3,4,5.....
        return String(peopleCountArray[row])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //한줄로 보여주기위한 설정
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //만날 친구의 명수를 담은 배열 개수만큼 설정
        return peopleCountArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 하나를 선택했을경우 그데이터를 라벨에 보여주고 저장함 
        peopleCountLabel.textColor = .black
        peopleCountLabel.text = String(peopleCountArray[row]) + "명"
        currentPeopleCount = peopleCountArray[row]
    }
}

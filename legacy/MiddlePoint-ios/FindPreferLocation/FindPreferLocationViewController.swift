//
//  FindPreferLocationViewController.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/05/22.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import CoreLocation

enum PreferType: String {
    case transit = "지하철, 버스정류장"
    case coffee = "카페"
    case restaurant = "레스토랑"
}

class FindPreferLocationViewController: UIViewController {
    var searchAddressModel: SearchAddressModel? // 나의 위치 정보를 담을 변수
    var centerCoordination: CLLocationCoordinate2D?
    var polygonArea: PolygonArea = PolygonArea()
    var isGetCenter: Bool = false
    var isSelectedCell: Bool = false
    var preferLocationList: [(title:PreferType, selection: Bool)] = [(title: PreferType.transit, selection: false), (title: .coffee, selection: false), (title: .restaurant, selection: false)]
    
    @IBOutlet weak var preferTableView: UITableView!
    @IBOutlet weak var resultButton: UIButton!
    
    @IBAction func resultButtonDidTap(_ sender: Any) {
        if isGetCenter == false {
            getCentCoordination()
        } else {
            if isSelectedCell == false {
                let alert = UIAlertController(title: "", message: "선호장소를 선택해주세요.",preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            } else {
                //중앙값을 가져왔고 그다음 뷰를 보여줍니다,.
                //중앙 값과 주소 모델, 선호장소 리스트를 다음 뷰로 넘깁니다.
                guard let centerCoordination = centerCoordination else { return }
                
                let resultViewController = storyboard?.instantiateViewController(withIdentifier: "ResultPreferLocationViewController") as! ResultPreferLocationViewController
                
                resultViewController.centerCoordination = centerCoordination
                resultViewController.preferLocationList = preferLocationList
                navigationController?.pushViewController(resultViewController, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPreferTableView()
        getCentCoordination()
        
    }
    
    func setPreferTableView() {
        preferTableView.delegate = self
        preferTableView.dataSource = self
    }
    
    func getCentCoordination() {
        //좌표들의 중앙 값을 가져오는걸 시작하는 함수
        
        resultButton.setTitle("중간 위치를 알아오는중..", for: .normal)
        
        //이전뷰에서 검색할 주소 모델 이 넘어오지않앗으면 return
        guard let searchAddressModel = searchAddressModel else { return }
        // 모델에서 친구들 좌표들과 나의 좌표를 가져와서 좌표 배열을 만듬
        var wholeCoordinations =  searchAddressModel.friendsCoordinations
        
        wholeCoordinations.append(searchAddressModel.myCoordination)
        
        //다각형 무게중심을 구하는 클래스에서 중앙값을 구하는 로직을 실행함
        // 전체 좌표 배열 넘김
        polygonArea.polygonCenter(polygon: wholeCoordinations) { success, centerCoordination in
            if success == true {
                guard let centerCoordination = centerCoordination else { return }
                //중앙값을 가져오면  중앙값을 변수로 저장함
                //중앙값을 가져오면 중앙값을 가져왔다는 플래그값을 true로 업데이트
                //버튼 title을 변경
                self.centerCoordination = centerCoordination
                self.isGetCenter = true
                self.resultButton.setTitle("결과 보기", for: .normal)
            } else {
                //중앙값을 가져오지못하면 가져왔다는 플래그값을 false로 업데이트
                //버튼 title을 변경
                self.isGetCenter = false
                self.resultButton.setTitle("중간위치를 다시불러오시겠습니까?", for: .normal)
            }
        }
    }
    
}

extension FindPreferLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferLocationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindPreferLocationTableViewCell", for: indexPath) as! FindPreferLocationTableViewCell
        cell.preferLocationLabel.text = preferLocationList[indexPath.row].title.rawValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //checkmark 가 표시되어있는 셀을 선택했을경우 체크마크를 취소하고 선택되지않았다는 데이터를 주입
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            preferLocationList[indexPath.row].selection = false
        } else {
             // 표시되어있지 않은 셀을 선택했을경우 체크마크를 보여주고 선택되었다는 데이터를 주입
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferLocationList[indexPath.row].selection = true
        }
        

        //하나라도 선택이 되었는지 파악 해서 0보다 이상이면 isSelectedCell의 bool값을 변경 
        let preferTrueCount = preferLocationList.filter { $0.selection == true }.count
        
        if preferTrueCount > 0 {
            isSelectedCell = true
        } else {
            isSelectedCell = false
        }
        
        return indexPath
    }
    
    
}


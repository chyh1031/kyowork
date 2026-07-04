//
//  FriendAddressTableViewCell.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/05/18.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit

class FriendAddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func load(address: String) {
        //받은 주소 문자열에 따라서 라벨을 설정
        if address == "" {
            addressLabel.textColor = .lightGray
            addressLabel.text = "친구의 위치는?"
        } else if address == "위치를 찾지 못했습니다.\n다시 받아와주세요." {
            addressLabel.textColor = .red
            addressLabel.text = address
        } else {
            addressLabel.textColor = .black
            addressLabel.text = address
        }
    }
}

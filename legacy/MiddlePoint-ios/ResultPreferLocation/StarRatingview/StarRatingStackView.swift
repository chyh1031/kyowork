//
//  StarRatingStackView.swift
//
//  Created by 장윤혁 on 2020/08/15.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit

class StarRatingStackView: UIStackView {
    @IBOutlet weak var star1ImageView: UIImageView!
    @IBOutlet weak var star2ImageView: UIImageView!
    @IBOutlet weak var star3ImageView: UIImageView!
    @IBOutlet weak var star4ImageView: UIImageView!
    @IBOutlet weak var star5ImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }



}

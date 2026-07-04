//
//  PlaceCardView.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/08/15.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import Kingfisher

protocol PlaceCardViewDelegate: class {
    func closePlaceCardView()
}

@available(iOS 13.0, *)
class PlaceCardView: UIView {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var webSiteButton: UIButton!
    @IBOutlet weak var starRatingView: StarRatingView!
    
    private let xibName = "PlaceCardView"
    private var placeURL = ""
    weak var delegate: PlaceCardViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        delegate?.closePlaceCardView()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func setPlaceData(data: PlaceDataResults) {
        placeNameLabel.text = data.name
        placeAddressLabel.text = data.vicinity
        placeURL = data.website ?? ""
        starRatingView.rating = Float(data.rating ?? 0)
        
        if placeURL != "" {
            webSiteButton.isHidden = false
        } else {
            webSiteButton.isHidden = true
        }
        
        guard let photo = data.photos else {
            placeImageView.kf.setImage(with: URL(string: ""))
            placeImageView.backgroundColor = .lightGray
            
            return
        }
        
        let height = String(describing: photo[0].height ?? 0)
        let width = String(describing: photo[0].width ?? 0)
        let photoReference = String(describing: photo[0].photo_reference ?? "")
        
        let imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxheight=\(height)&maxwidth=\(width)&photoreference=\(photoReference)&key=AIzaSyCoIL-hzWRe6fnwdCNMIVWvBPteQxI48nc"
        placeImageView.kf.setImage(with: URL(string: imageURL))
        placeImageView.backgroundColor = .clear
    }
}

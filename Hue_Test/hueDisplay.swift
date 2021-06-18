//
//  hueDisplay.swift
//  Hue_Test
//
//  Created by Core B Admin on 1/30/19.
//  Copyright © 2019 UNR Cobre. All rights reserved.
//

import UIKit

@IBDesignable //Show circle on storyboard

class hueDisplay: UIButton {
    @IBInspectable var fillColor: UIColor = UIColor.clear

    //Make it circular
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
    }

}

//Type conversions to/form UIColor and 1x3 double array of 0...1

import Foundation
import UIKit

//Type Conversions
// Double <> CGFloat <> UIColor
func fromUIColor(_ color: UIColor) -> [Double] {
    //Converts UIColor type to Double array
    var fr: CGFloat = 0
    var fb: CGFloat = 0
    var fg: CGFloat = 0
    var fa: CGFloat = 0
    var RGB: [Double] = [0,0,0]
    color.getRed(&fr, green: &fg, blue: &fb, alpha: &fa) //Yes, strange syntax
    RGB[0] = Double(fr)
    RGB[1] = Double(fg)
    RGB[2] = Double(fb)
    return(RGB)
}

func toUIColor(_ arr: [Double]) -> UIColor {
    //Convert a 1x3 Double to UIColor variable
    //Assumed range 0...1 not 0...255
    let r: CGFloat = CGFloat(arr[0])
    let g: CGFloat = CGFloat(arr[1])
    let b: CGFloat = CGFloat(arr[2])
    let col = UIColor(red: r, green: g, blue: b, alpha: 1)
    return col
}

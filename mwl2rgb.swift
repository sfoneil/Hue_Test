//
//  mwl2rgb.swift
//  ColorTester
//
//  Convert from MWLab physiological color space RGB Double triplet.
//  Opposite of rgb2mwl.swift

import Foundation
import simd //For matrix multiplication

//Convert to display space
func mwl2rgb(_ MWL: [Double]) -> [Double] {
    //This is the full wrapper - go from MWL to RGB, completing the intermediate steps
    var RGB: [Double] = [0,0,0]
    var step: [Double] = [0,0,0]
    step = mwl2dkl(MWL)
    step = dkl2xyl(step)
    step = xyl2xyz(step)
    RGB = xyz2rgb(step)
    return RGB
}

func mwl2dkl(_ MWL: [Double]) -> [Double] {
    var DKL: [Double] = [0,0,0]
    DKL[0] = (MWL[0] / 1955) + 0.6568
    DKL[1] = (MWL[1] / 5533) + 0.01825
    DKL[2] = MWL[2]
    return DKL
}

func dkl2xyl(_ DKL: [Double]) -> [Double] {
    var XYZ: [Double] = [0,0,0]
    var XYL: [Double] = [0,0,0]
    XYZ[0] = 2.9448 * DKL[0] - 3.5001 * (1 - DKL[0]) + 13.1745 * DKL[1]
    XYZ[1] = 1 * DKL[0] + 1 * (1 - DKL[0]) + 0 * DKL[1]
    XYZ[2] = 0 * DKL[0] + 0 * (1 - DKL[0]) + 62.1891 * DKL[1]
    XYL[0] = XYZ[0] / (XYZ[0] + XYZ[1] + XYZ[2])
    XYL[1] = XYZ[1] / (XYZ[0] + XYZ[1] + XYZ[2])
    XYL[2] = DKL[2]
    return XYL
}

func xyl2xyz(_ XYL: [Double]) -> [Double] {
    var XYZ: [Double] = [0,0,0]
    XYZ[0] = XYL[0] * (XYL[2] / XYL[1])
    XYZ[1] = XYL[1] * (XYL[2] / XYL[1])
    XYZ[2] = (1 - XYL[0] - XYL[1]) * (XYL[2] / XYL[1])
    return XYZ
}

func xyz2rgb(_ XYZ: [Double]) -> [Double] {
    let convMat = simd_double3x3(rows: [
        simd_double3(0.0739503671361623,    -0.0272066724984184,    0.00193138941064624),
        simd_double3(-0.0336185202003027,    0.0500665175006801,    -0.00608174358625650),
        simd_double3(-0.0112804841617250,    0.00110181009081312,    0.0321569138458227)
        ])//Color conversion matrix
    let colorMat = simd_double3(XYZ)
    let RGB: simd_double3 = colorMat * convMat
    let RGB2: [Double] = [RGB[0],RGB[1],RGB[2]]
    return RGB2
}

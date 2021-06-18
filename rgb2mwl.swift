//
//  rgb2mwl.swift
//  ColorTester
//
//  Convert from RGB Double triplet to MWLab physiological color space.
//  This space moves in axes that represent color and luminance opponent channels.
//  MWL[0] = L - M or "red" vs. "green"
//  MWL[1] = S - (L + M) or "blue" vs. "yellow"
//  MWL[2] = L + M or luminance
//
//  Intermediate steps are:
//  RGB to XYZ
//  XYZ to xyL (or xyY, CIE 1931)
//  xyL to Derrington-Krauskopf-Lennie physiological cone space
//  DKL to Webster's recentering of the space

//
//  Color conversions
//  Order: RGB > XYZ > xyL > DKL > MWL
//  For testing:
//  If rgb =  .75 .6 .4 (tan color)
//  Then:
//  xyz 23.6677 24.5009 15.6513
//  xyl .3709 .3839 24.5009
//  dkl .6720 .0103 24.5009
//  mwl 29.6499 -44.1425 24.5009

import Foundation
import simd //For matrix multiplication

func rgb2mwl (_ RGB: [Double]) -> [Double] {
    //This is the full wrapper - go from RGB to MWL, completing the intermediate steps
    var MWL: [Double] = [0,0,0]
    var step: [Double] = [0,0,0]
    step = rgb2xyz(RGB)
    step = xyz2xyl(step)
    step = xyl2dkl(step)
    MWL = dkl2mwl(step)
    return MWL
}

func rgb2xyz(_ RGB: [Double]) -> [Double] {
    let convMat = simd_double3x3(rows: [
        simd_double3(18.1050000000000,    9.82150000000000,    0.770100000000000),
        simd_double3(12.8750000000000,    26.8750000000000,    4.30950000000000),
        simd_double3(5.91000000000000,    2.52450000000000,    31.2200000000000)
        ]) //Conversion Matrix
    let colorMat = simd_double3(RGB)
    let XYZ: simd_double3 = colorMat * convMat
    let XYZ2: [Double] = [XYZ[0],XYZ[1],XYZ[2]]
    return(XYZ2)
}

func xyz2xyl(_ XYZ: [Double]) -> [Double] {
    var xyl: [Double] = [0,0,0]
    xyl[0] = XYZ[0] / (XYZ[0]+XYZ[1]+XYZ[2])
    xyl[1] = XYZ[1] / (XYZ[0]+XYZ[1]+XYZ[2])
    xyl[2] = XYZ[1]
    return xyl
}

func xyl2dkl(_ xyl: [Double]) -> [Double] {
    var LMS: [Double] = [0,0,0]
    var DKL: [Double] = [0,0,0]
    LMS[0] = 0.15516 * xyl[0] + 0.54308 * xyl[1] - 0.03287 * (1 - xyl[0] - xyl[1]);
    LMS[1] = -0.15516 * xyl[0] + 0.45692 * xyl[1] + 0.03287 * (1 - xyl[0] - xyl[1]);
    LMS[2] = 0 * xyl[0] + 0 * xyl[1] + 0.01608 * (1 - xyl[0] - xyl[1]);
    DKL[0] = LMS[0] / (LMS[0] + LMS[1])
    DKL[1] = LMS[2] / (LMS[0] + LMS[1]);
    DKL[2] = xyl[2];
    return DKL
}

func dkl2mwl(_ DKL: [Double]) -> [Double] {
    var MWL: [Double] = [0,0,0]
    MWL[0] = 1955 * (DKL[0] - 0.6568)
    MWL[1] = 5533 * (DKL[1] - 0.01825)
    MWL[2] = DKL[2]
    return MWL
}

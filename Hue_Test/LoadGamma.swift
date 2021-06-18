//
//  GammaFuncs.swift
//  Hue_Test
//
//  Created by Core B Admin on 4/29/19.
//  Copyright © 2019 UNR Cobre. All rights reserved.
//

import Foundation

func LoadGamma() -> [[Double]] {
    //Load a .csv file to an array containing percentage gamma adjustments
    //measured via i1Pro or similar.
    //Initialize file access
    //let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //let filename = paths[0].appendingPathComponent("gamma.csv")
    let filename = Bundle.main.url(forResource: "gamma", withExtension: "csv")
    
    //Read in old file if exists for append
    var readString: String = ""
    do {
        readString = try String(contentsOf: filename!)
        
    } catch {
        print("Error reading file. May not exist.")
    }
    
    //Slice CSV by line
    let parsedCSV: [[String]] = readString.components(separatedBy: "\n").map{ $0.components(separatedBy: ",")}
    
    //Convert String to Double, there's probably a better way to do this.
    var gamma = [[Double]](repeating: [Double](repeating:0, count: 3), count: 256)
    for j in 0...2 {
        for i in 0...255 {
            
            gamma[i][j] = Double(parsedCSV[i][j])!
        }
    }
    return gamma
}

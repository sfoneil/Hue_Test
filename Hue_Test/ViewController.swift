//Code associated with the experiment screen

import UIKit
import Accelerate //For color correction?

class ViewController: UIViewController {
    
    //Outlets to instruction labels
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblInstr: UILabel!
    @IBOutlet weak var swtGammaSwitch: UISwitch!
    
    //These are sent from text boxes in startView
    var initials: String! //""
    var numReps: Int! //5
    var intStepSize: Int! //4, 10 initially
    var numHues: Int! //36
    var dblBrightness: Double! //1.0
    var contrast: Double! //50.0
    var useGamma: Bool! //False
    
    //Initialize fixed global variables
    var intHueStep: Int = 10 //10 initially, then intStepSize
    let numUnique: Int = 8 //Probably won't ever change?
    //var contrast: Double = 50.0
    let luminance: Double = 100.0
    var hueSize = 50.0 //Size of the circle
    
    //Initialize global counters and such
    var colorOffset: Int = 0 //Hue
    var intColor: Int = 0 //Counter for current color
    var intRep: Int = 0 //Counter for presentation number
    var intTrial: Int = 0 //Counter for total trials
    var numTrials: Int = 0 //Total number of trials, 8 * 5 = 40
    
    //Initialize these blank, will fill in viewDidLoad()
    var strColors = [String]()
    var strInstr = [String]()
    var colorSpot = [Int?]()
    var colorSet = [[Double?]]()
    var colorChosen = [[Int]]()
    var colorShown = [Int]()
    var UIColorSet = [UIColor]()
    var gamma = [[Double]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        UIScreen.main.brightness = CGFloat(dblBrightness)
        numTrials = numUnique * numReps
        //let w = Double(self.view.frame.width)
        
 

        let h = Double(self.view.frame.height)

        
        //Instructions:
        /*
         strColors.append("RED")
         strColors.append("GREEN")
         strColors.append("BLUE")
         strColors.append("YELLOW")
         strColors.append("ORANGE")
         strColors.append("PURPLE")
         strColors.append("BLUE-GREEN")
         strColors.append("YELLOW-GREEN")
         
         strInstr.append("not too orange or purple")
         strInstr.append("not too blue or yellow")
         strInstr.append("not too purple or green")
         strInstr.append("not too orange or green")
         strInstr.append("not too red or yellow")
         strInstr.append("not too blue or red")
         strInstr.append("not too blue or green")
         strInstr.append("not too yellow or green")*/
        readInstructions()
        //Initialize arrays that couldn't be done before due to lack of numHues, numUnique access
        colorSpot = [Int](repeating: 0, count: numHues)
        colorSet = [[Double]](repeating: [Double](repeating:0, count: numHues), count: 3)
        colorChosen = [[Int]](repeating: [Int](repeating: 0, count: numUnique), count: numReps)
        colorShown = [Int](repeating: 0, count: numUnique)
        UIColorSet = [UIColor](repeating: UIColor.lightGray, count: numHues)
        
        hueSize = h / 15.0
        
        //Randomize start
        intColor = Int.random(in: 0...7)
        
        //Mark first color used
        colorShown[intColor] = 1
        
        //Set instruction boxes
        lblColor.text = strColors[intColor]+" #1"
        lblInstr.text = strInstr[intColor]
        lblColor.sizeToFit()
        lblInstr.sizeToFit()
        lblColor.center.x = self.view.center.x
        lblInstr.center.x = self.view.center.x
        
        swtGammaSwitch.isOn = useGamma
        gamma = LoadGamma()
        
        //Create and display first trial
        setColors()
        drawCircles()
    }
    
    
    @IBAction func swtGamma(_ sender: Any) {
        if swtGammaSwitch.isOn == true {
            useGamma = true
        } else {
            useGamma = false
        }
        drawCircles()
    }
    
    @objc func fire() {
        //Timer of 500 ms after click
        //Uses Objective-C functions
        if intTrial >= numTrials - 1 {
            //End of experiment: calculate and save data
            var meanResp = [Double](repeating: 0, count: 8)
            var sdResp = [Double](repeating: 0, count: numUnique)
            var LABResp = [[Double]](repeating: [Double](repeating: 0, count: 8), count: 2)
            for iColor in 0...numUnique - 1 {
                var sumResp: Int = 0
                for iRep in 0...numReps - 1 {
                    sumResp += colorChosen[iRep][iColor]
                }
                meanResp[iColor] = Double(sumResp/(numReps))
                LABResp[0][iColor] = contrast * cos(meanResp[iColor] * Double.pi / 180.0)
                LABResp[1][iColor] = contrast * sin(meanResp[iColor] * Double.pi / 180.0)
            }
            //STANDARD DEVIATION
            if numReps > 2 {
                //Otherwise can't do SD
                for iColor in 0...7 {
                    var sumSqResp: Double = 0
                    for iRep in 1...numReps - 1 {
                        sumSqResp += pow(Double(colorChosen[iRep][iColor]) - Double(meanResp[iColor]),2)
                    }
                    sdResp[iColor] = sqrt(sumSqResp / Double(numReps - 1))
                }
            } else {
                sdResp = [-1, -1, -1, -1, -1, -1, -1, -1]
            }
            //OUTPUT:
            /*Note: to enable iPad's file access, needed to open Info.plist as source code, and then
             inside <dict> need to add:
             <key>UIFileSharingEnabled</key>
             <true/>
             <key>LSSupportsOpeningDocumentsInPlace</key>
             <true/>
             https://www.appcoda.com/files-app-integration/
             */
            
            //Initialize file access
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let filename = paths[0].appendingPathComponent("\(initials ?? "blank") data.csv")
            
            //Read in old file if exists for append
            var readString: String = ""
            do {
                readString = try String(contentsOf: filename)
            } catch {
                print("Error reading file. May not exist.")
            }
            
            //Define output for old string
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .full
            let dateString = dateFormatter.string(from: currentDate)
            var str: String = readString
            
            //Print to multiple lines
            str += "\(initials ?? "blank")    \(dateString)\n"
            str += "Contrast = \(String(describing: contrast))\n"
            str += "Gamma = \(swtGammaSwitch.isOn)\n\n"
            for i in 0...numUnique - 1 {
                str += "\(strColors[i])\n"
                for j in 0...numReps - 1 {
                    str += String(colorChosen[j][i]) + ","
                    //angles.append(String(colorChosen[j][i]))
                }
                str += """
                
                Mean:, \(meanResp[i]),
                SD:, \(sdResp[i]),
                LabA:, \(LABResp[0][i]), LabB:, \(LABResp[1][i])
                
                
                """
            }
            
            //Attempt to write to a text file
            do {
                try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                //try str.append(to: filename, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error writing to file.")
            }
            
            //FULL FILE
            //Read in old file if exists for append
            let fullFile = paths[0].appendingPathComponent("All data.csv")
            var readString2: String = ""
            do {
                readString2 = try String(contentsOf: fullFile)
            } catch {
                print("Error reading file. May not exist.")
            }
            var strFull: String = readString2
            strFull += "\n\(initials ?? "blank")    \(dateString)\n"
            strFull += "Contrast = \(String(describing: contrast))\n"
            strFull += "Gamma = \(swtGammaSwitch.isOn)\n\n"
            for i in 0...numUnique - 1 {
                strFull += "\(strColors[i])\n"
                strFull += """
                Mean:, \(meanResp[i]),
                SD:, \(sdResp[i]),
                LabA:, \(LABResp[0][i]), LabB:, \(LABResp[1][i])

                
                """
            }
            print(strFull)
            //Attempt to write to a text file
            do {
                try strFull.write(to: fullFile, atomically: true, encoding: String.Encoding.utf8)
                //try str.append(to: filename, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error writing to file.")
            }
            
            
            
            print("Experiment done.")
            //Print "QUIT" in center
            //Todo: needs fixing
            
            //Remove hue circles
            for i in 0...numHues - 1 {
                if let found = view.viewWithTag(500 + i) {
                    found.removeFromSuperview()
                }
                
            }
            let w = Double(self.view.frame.width)
            let h = Double(self.view.frame.height)
            let quitButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: w, height: h))
            quitButton.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
            quitButton.tag = 999
            quitButton.backgroundColor = .gray
            //quitButton.isOpaque = true
            quitButton.superview?.bringSubviewToFront(quitButton)
            quitButton.setTitle("EXPERIMENT DONE", for: .normal)
            quitButton.titleLabel?.font = .systemFont(ofSize: 20)
            self.view.addSubview(quitButton)
            exit(0)
        } else {
            //Regular trial
            intRep += 1 //Increment after click
            intTrial += 1
            intHueStep = intStepSize
            if intRep >= numReps {
                intRep = 0
            }
            
            if intRep == 0 {
                intHueStep = 10
                repeat {
                    intColor = Int.random(in: 0...7)
                } while colorShown[intColor] == 1
            }
            //Setup for next trial
            colorShown[intColor] = 1
            lblColor.text = strColors[intColor]+" #\(intRep+1)"
            lblInstr.text = strInstr[intColor]
            lblColor.sizeToFit()
            lblInstr.sizeToFit()
            lblColor.center.x = self.view.center.x
            lblInstr.center.x = self.view.center.x
            
        }
        setColors()
        drawCircles()
    }
    
    @objc func tapButton(_ sender: UIButton) {
        //Objective-C code for when circle is tapped
        let buttonNumber = sender.tag - 500
        colorChosen[intRep][intColor] = colorSpot[buttonNumber]! //Save response
        //Find all buttons, remove
        for i in 0...numHues - 1 {
            if let found = view.viewWithTag(500 + i) {
                found.removeFromSuperview()
            }
        }
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fire), userInfo: nil, repeats: false)
    }
    
    func setColors() {
        //Go through all circles and set their colors based on colorOffset
        if intRep == 0 {
            colorOffset = Int.random(in:0...numHues - 1)
        } else {
            let rnd = Int.random(in: 0...19)
            colorOffset =  colorChosen[0][intColor] - (rnd + 8) * intHueStep
        }
        
        for iColor in 0...numHues - 1 {
            
            //for iColor in stride(from:0, to: numHues, by: step) {
            
            let counter: Double = Double( (iColor + 1) * intHueStep + colorOffset) //Saves ugly code below
            var LAB: [Double] = [0,0,0]
            
            LAB[0] = 100
            LAB[1] = contrast * cos(counter * Double.pi / 180.0)
            LAB[2] = contrast * sin(counter * Double.pi / 180.0)
            
            colorSpot[iColor] = ((iColor + 1) * intHueStep) + colorOffset
            //CIELab to 1931
            let CIE: [Double] = LAB2xyY(LAB)
            var XYZ: [Double] = toGun(CIE)
            var RGB: [Double] = [0,0,0]
            RGB[0] = XYZ[0] * luminance / 0.304
            RGB[1] = XYZ[1] * luminance / 0.628
            RGB[2] = (1.0 - (XYZ[0] + XYZ[1])) * luminance / 0.068
            if useGamma {
                let r = Int(RGB[0])
                let g = Int(RGB[1])
                let b = Int(RGB[2])
                let gammaRGB: [Double] = [gamma[r][0], gamma[g][1], gamma[b][2]]
                UIColorSet[iColor] = toUIColor(gammaRGB)
                //    UIColorSet[iColor] = toUIColor(RGBPct * 255)
            } else {
                let RGBPct: [Double] = [RGB[0]/255.0, RGB[1]/255.0, RGB[2]/255.0]
                UIColorSet[iColor] = toUIColor(RGBPct)
            }
        }
    }
    
    
    func drawCircles() {
        //Loop through and draw buttons, make them colored circles
        //Center of screen, screen on mini is 768x1024
        let midX = Double(self.view.frame.width / 2)
        let midY = Double(self.view.frame.height / 2)
        
        //Arrays of circle locations
        let multiplier = midY * 0.9
        let degSteps = 360.0 / Double(numHues)
        
        for i in 0...numHues - 1 {
            //Draw the buttons.
            let xpos = midX + multiplier * cos(Double(i + 1) * degSteps * Double.pi / 180.0) - (hueSize / 2)
            let ypos = midY - multiplier * sin(Double(i + 1) * degSteps * Double.pi / 180.0) - (hueSize / 2)
            let button = hueDisplay(frame: CGRect(x: xpos, y: ypos, width: hueSize, height: hueSize))
            button.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside) //Allow buttons to be tapped
            button.tag = 500 + i //High identifiers for new buttons
            button.backgroundColor = .clear
            button.setTitle("", for: .normal)
            self.view.addSubview(button)
            button.fillColor = UIColorSet[i]
        }
    }
    
    func xyY2LAB(_ cie:[Double]) -> [Double] {
        //Convert xyY/CIE 1931 to LAB space
        //Not actually used in this program!
        let whitePoint:[Double] = [18.07, 18.42, 21.8] //Illuminant C
        var XYZ: [Double] = xyl2xyz(cie) //Get XYZ
        var LAB: [Double] = [0,0,0]
        LAB[0] = 116 * (whitePoint[1] / XYZ[1]) - 16
        LAB[1] = 500 * (pow((whitePoint[0] / XYZ[0]), 1.0/3.0) - pow((whitePoint[1] / XYZ[1]), 1.0/3.0)) //Have to use pow not ^ and force exponent into double because Swift is weird
        LAB[2] = 200 * (pow((whitePoint[1] / XYZ[1]), 1.0/3.0) - pow((whitePoint[2] / XYZ[2]), 1.0/3.0))
        
        if (whitePoint[0] / XYZ[0] <= 0.008856) || (whitePoint[1] / XYZ[1] <= 0.008856) || (whitePoint[2] / XYZ[2] <= 0.008856) {
            LAB[0] = 903.3 * (whitePoint[1] / XYZ[1])
            LAB[1] = 500 * ((7.87 * (XYZ[0] / whitePoint[0]) + 16 / 116) - (7.87 * (whitePoint[1] / XYZ[1]) + 16 / 116))
            LAB[2] = 200 * ((7.87 * (XYZ[1] / whitePoint[1]) + 16 / 116) - (7.87 * (whitePoint[2] / XYZ[2]) + 16 / 116))
        }
        return LAB
    }
    
    func LAB2xyY(_ LAB: [Double]) -> [Double] {
        //Convert LAB space to xyY/CIE 1931
        let whitePoint: [Double] = [18.07, 18.42, 21.80] //IllumC
        let fY: Double = (LAB[0] + 16) / 116
        let fX: Double = fY + LAB[1] / 500
        let fZ: Double = fY - LAB[2] / 200
        let gamma: Double = 6.0/29.0
        var CIE: [Double] = [0,0,0]
        
        if fY > gamma {
            CIE[1] = whitePoint[1] * pow(fY, 3)
        } else {
            CIE[1] = (fY - 16 / 116) * 3 * pow(gamma, 2) * whitePoint[1]
        }
        
        if fX > gamma {
            CIE[0] = whitePoint[0] * pow(fX, 3)
        } else {
            CIE[0] = (fX - 16 / 116) * 3 * pow(gamma, 2) * whitePoint[0]
        }
        
        if fZ > gamma {
            CIE[2] = whitePoint[2] * pow(fZ, 3)
        } else {
            CIE[2] = (fZ - 16 / 116) * 3 * pow(gamma, 2) * whitePoint[2]
        }
        
        var XY: [Double] = [0,0]
        XY[0] = CIE[0] / (CIE[0] + CIE[1] + CIE[2])
        XY[1] = CIE[1] / (CIE[0] + CIE[1] + CIE[2])
        return XY
    }
    
    func toGun(_ CIE: [Double]) -> [Double] {
        //Convert CIE to RGB gun output
        let xR = 0.619
        let yR = 0.344
        let xG = 0.281
        let yG = 0.607
        let xB = 0.150
        let yB = 0.063
        let temp1: Double = (CIE[0] - xB) * (yR - yB) - (CIE[1] - yB) * (xR  - xB)
        let temp2: Double = (xG - xB) * (yR - yB) - (yG - yB) * (xR - xB)
        let temp3: Double = temp1 / temp2
        let temp4: Double = ((CIE[0] - xB) - temp3 * (xG - xB)) / (xR - xB)
        let temp5: Double = 1 - temp3 - temp4
        let temp6: Double = temp4 * yR + temp3 * yG + temp5 * yB
        var XYZ: [Double] = [0,0,0]
        XYZ[0] = temp4 * yR / temp6
        XYZ[1] = temp3 * yG / temp6
        XYZ[2] = 1 - (XYZ[0] + XYZ[1])
        return XYZ
    }
    
    func readInstructions() {
        //Reads in a text file for conditions and instructions. Format is 8 lines of colors ("PURPLE") followed by
        //another 8 lines for instructions ("not too blue or red") such that lines N and N+8 represent the same condition.
        //The text file can be edited to change conditions, instructions, or language.
        let filename = Bundle.main.url(forResource: "Instructions", withExtension: "txt")
        
        var readString: String = ""
        do {
            readString = try String(contentsOf: filename!)
        } catch {
            print("Error reading file. May not exist.")
        }
        
        //Slice TXT by line into 16 element vector
        let parsedFile: [String] = readString.components(separatedBy: "\n") //.map{ $0.components(separatedBy: ",")}
        
        for i in 0...7 {
            strColors.append(parsedFile[i])
            strInstr.append(parsedFile[i+8])
        }
    }
} //View Controller

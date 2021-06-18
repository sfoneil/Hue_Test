//Code associated with the color testing and calibration screen

import UIKit

class colorView: UIViewController {
    
    @IBOutlet var txtChangeColor: [UITextField]!
    @IBOutlet var sldSliderValue: [UISlider]!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet var stpSteppers: [UIStepper]!
    @IBOutlet weak var swtGamma: UISwitch!
    @IBOutlet weak var txtNumSteps: UITextField!
    
    var dblBrightness: Double! //From segue
    var gamma = [[Double]]()
    
    @IBAction func sliderIsMoved(_ sender: Any) {
        //Update text box when slider is changed
        //  let fixed = roundf(sender.value / 8.0) * 8.0
        //   sender.setValue(fixed, animated: true)
        for i in 0...2 {
            txtChangeColor[i].text = String(sldSliderValue[i].value * 255)
            stpSteppers[i].value = Double(sldSliderValue[i].value)
            updateColor()
            //todo: make stepper rounded slider 0.03125
        }
        
    }
    @IBAction func swtSwitchChanged(_ sender: Any) {
        updateColor()
    }
    
    @IBAction func txtChangeNumSteps(_ sender: Any) {
        let numSteps = Double(txtNumSteps.text!)
        for i in 0...2 {
            stpSteppers[i].stepValue = 1.0 / numSteps!
        }
    }
    
    @IBAction func stepperChange(_ sender: UIStepper) {
        //When stepper changed, increase slider by discrete value, change text
        for i in 0...2 {
            sldSliderValue[i].value = Float(stpSteppers[i].value)
            txtChangeColor[i].text = String(sldSliderValue[i].value * 255)
            updateColor()
        }
    }
    
    @IBAction func txtTextIsChanged(_ sender: Any) {
        //Update sliders when text is changed
        for i in 0...2 {
            sldSliderValue[i].value = Float(txtChangeColor[i].text!)! / 255
        }
        updateColor()
    }
    
    func updateColor() {
        //Change background color based on slider values.
        //Doesn't use text box values, would require conversion 0...1 > 0...255
        var bkgd: [Double]
        if swtGamma.isOn == true {
            let r: Int = Int(round(Double(sldSliderValue[0].value) * 255))
            let g: Int = Int(round(Double(sldSliderValue[1].value) * 255))
            let b: Int = Int(round(Double(sldSliderValue[2].value) * 255))
            bkgd = [gamma[r][0], gamma[g][1], gamma[b][2]]
        } else {
            bkgd = [Double(sldSliderValue[0].value), Double(sldSliderValue[1].value), Double(sldSliderValue[2].value)]
        }
        imgBackground.backgroundColor = toUIColor(bkgd)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gamma = LoadGamma()
        UIScreen.main.brightness = CGFloat(dblBrightness)
        txtChangeColor[0].keyboardType = .numberPad
        txtChangeColor[1].keyboardType = .numberPad
        txtChangeColor[2].keyboardType = .numberPad
        txtNumSteps.keyboardType = .numberPad
        updateColor()
    }
}

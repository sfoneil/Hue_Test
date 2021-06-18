//Code associated with the starting screen
import UIKit
//Todo: fix numHues, not working properly
class startView: UIViewController {
    @IBOutlet weak var txtInitials: UITextField!
    @IBOutlet weak var txtReps: UITextField!
    @IBOutlet weak var txtStepSize: UITextField!
    @IBOutlet weak var txtNumCircles: UITextField!
    @IBOutlet weak var swtGamma: UISwitch!
    @IBOutlet weak var txtBrightness: UITextField!
    @IBOutlet weak var txtContrast: UITextField!
    
    //let originalBrightness = UIScreen.main.brightness //Save desktop brightness

    
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {
        //Return to the start, doesn't need code in it.
    }
    
    
    ///***************Navigation***************
    @IBAction func btnStart(_ sender: Any) {
        //Go to experiment
        performSegue(withIdentifier: "startSegue", sender: self)
    }
    
    @IBAction func btnColorTest(_ sender: Any) {
        //Go to color testing
        performSegue(withIdentifier: "colorSegue", sender: self)
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        //Before segue, send important variables. Variables need
        //to be redeclared in other view controller.
        //let svc = segue.destination as! ViewController
        if (segue.identifier == "startSegue") {
            let svc = segue.destination as! ViewController
            svc.initials = String(txtInitials.text!)
            svc.numReps = Int(txtReps.text!)
            svc.intStepSize = Int(txtStepSize.text!)
            svc.numHues = Int(txtNumCircles.text!)
            svc.dblBrightness = Double(txtBrightness.text!)
            svc.contrast = Double(txtContrast.text!)
            svc.useGamma = swtGamma.isOn
            
       //     let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "exp") //From "Storyboard ID", "Completion ID"
       //      VC1.modalPresentationStyle = .fullScreen
        //     self.present(VC1, animated:true, completion: nil)
            
            
        } else if (segue.identifier == "colorSegue" ) {
            let svc = segue.destination as! colorView
            svc.dblBrightness = Double(txtBrightness.text!)
        }
    }
    
    override func viewDidLoad() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print(documentsDirectory)
        super.viewDidLoad()
        //UIScreen.main.brightness = CGFloat(0.5)
        //Don't need full keyboard
        txtReps.keyboardType = .numberPad
        txtStepSize.keyboardType = .numberPad
        txtNumCircles.keyboardType = .numberPad
        txtBrightness.keyboardType = .decimalPad
    }
    
}

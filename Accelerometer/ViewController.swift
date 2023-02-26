//
//  ViewController.swift
//  Accelerometer
//
//  Created by Andrea Pozzoni on 09/02/23.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    
    //start the services that report movement detected by the device's onboard sensors
    var motionManager = CMMotionManager()
    
    //devicemotion event is fired at a regular interval and indicates
    //the amount of physical force of acceleration the device is receiving
    var deviceMotion = CMDeviceMotion()
    
    //Layer where to draft Bezier lines
    var shape: CAShapeLayer?

    // image of the acceletor disk
    let accelerometerDiskImage = UIImage(named: "AccelerometerDisk.png")
    let myImageView:UIImageView = UIImageView()
    
    // Initialaze the variable to store position and spec's of the center of the circles that will be drafted
    // generic position, radius and specs of a bullet indicating the current acceleration
    var posX : Int = 0
    var posY : Int = 0
    var radiusCircle : Int = 0                  // the diameter of a circle
    var scaledCircleRadius : CGFloat = 0.0      // the scaled radius depending on the scale
    
    // other specs of the circles design
    var circleThickness : CGFloat = 0.0
    var lineColor = UIColor.blue.cgColor
    var fillColor = UIColor.systemGray2.cgColor

    
    //radius and center of the accelerometer
    var rCircle : Int = 0
    var centerAccX : Int = 0
    var centerAccY : Int = 0
    
    // variables to store min and max acceleration
    var maxx : CGFloat = 0.0
    var maxy : CGFloat = 0.0
    var maxz : CGFloat = 0.0
    var minx : CGFloat = 0.0
    var miny : CGFloat = 0.0
    var minz : CGFloat = 0.0
    
    
    
    // Show minimum's on screen
    @IBOutlet weak var labelx: UILabel!
    @IBOutlet weak var labely: UILabel!
    @IBOutlet weak var labelz: UILabel!
    
    // Show maximum's on screen
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelY: UILabel!
    @IBOutlet weak var labelZ: UILabel!
    
    
    
    // reset button
    @IBOutlet weak var resetMinMax: UIButton!
    
    // scale stepper (external circle = 1 (4g)  to 4 (1g)
    @IBOutlet weak var scaleStepper: UIStepper!
    
    // show the scale chosen
    @IBOutlet weak var gShow: UILabel!
    
    // track or single : single spoct with the current acceleration or show all till reset
    
    @IBOutlet weak var showAllBulletsOrCurrentOne: UISwitch!
    
    @IBOutlet weak var bulletSingleOrAll: UILabel!
    
    
    //  THIS IS FOR TESTING PURPOSES ONLY
    // change to "Y" if you want to test the app with randomized acceleration data. It works also with simulators
    var test = "N"
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //the screen to remains on when in use while driving a car for example.
        UIApplication.shared.isIdleTimerDisabled = true
   
        // enlarge the stepper
        scaleStepper.transform = scaleStepper.transform.scaledBy(x: 1.5, y: 1.5)
        
        // initialize stepper to 0 (most sensitive) and scale max to 0.5g
        scaleStepper.value = 0   // set stepper to most sensitive scale
        gShow.text = "0.5g" // show the scale close to the outside circle
        scaledCircleRadius = 700
        
        // RADIUS AND CENTER OF THE ACCELEROMETER
        rCircle = Int(view.frame.height / 2.0 - 70 - 170)
        centerAccX = Int(view.frame.midX)
        centerAccY = Int(view.frame.midY + 170)
        
        // image of the accelerometer
        view.backgroundColor = .black
        myImageView.contentMode = UIView.ContentMode.scaleAspectFit
        myImageView.frame.size.width = CGFloat(rCircle * 2 + 10)
        myImageView.frame.size.height = CGFloat(rCircle * 2 + 10)
        myImageView.center = CGPoint(x: centerAccX, y: centerAccY)
        myImageView.image = accelerometerDiskImage

        
        // place the image in position
        accelerometerDisc()  // design the accelerometer circle
        
        if (test == "Y") {
            // just start the timer - @objc func timerAction() will take care of the required simulation actions
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        } else {
            // START TRACKING THE ACCELERATIONS OF THE DEVICE
            motionManager.deviceMotionUpdateInterval = 0.2
            devMotion()
        }

    }
    
    
    // used only for testing
    @objc func timerAction() {
        if (test == "Y") {

            let i = 1.0   // change as you wish during testing
            let x = Double.random(in: -i..<i)
            let y = Double.random(in: -i..<i)
            let z = Double.random(in: -i..<i)
 
            /*
            let x = 1.0
            let y = 0.0
            let z = 0.0
            */
            
            print("testing \n x= \(x)   \n y=\(y)   \n z=\(z)")
            
            if x < self.minx {
                self.minx = x
                self.labelx.text = String(round(self.minx * 100) / 100)
            }
            if y < self.miny {
                self.miny = y
                self.labely.text = String(round(self.miny * 100) / 100)
                
            }
            if z < self.minz {
                self.minz = z
                self.labelz.text = String(round(self.minz * 100) / 100)
            }
            
            if x > self.maxx {
                self.maxx = x
                self.labelX.text = String(round(self.maxx * 100) / 100)
            }
            if y > self.maxy {
                self.maxy = y
                self.labelY.text = String(round(self.maxy * 100) / 100)
            }
            if z > self.maxz {
                self.maxz = z
                self.labelZ.text = String(round(self.maxz * 100) / 100)
            }
            
            // place the bullet on the screen
            let test = pow((x * scaledCircleRadius), 2.0) + pow((z * scaledCircleRadius), 2.0)
            let r2 = pow(Double(rCircle),2.0)
            if (test < r2 ) {
                // Generate the Bullet of the current acceleration and place it in the
                // right position in the accelerometer circle
                posX = centerAccX + Int(x * scaledCircleRadius)
                posY = centerAccY + Int(z * scaledCircleRadius)
                radiusCircle = 5
                circleThickness = 6
                createCircle()
            }
        }
    }
    
    @IBAction func resetMinMax(_ sender: Any) {
        
        // clear stored min and max acceleration
        maxx = 0.0
        maxy = 0.0
        maxz = 0.0
        minx = 0.0
        miny = 0.0
        minz = 0.0
        
        // clean the acceleromer by reloading the base image
        accelerometerDisc()
        
    }
    
    @IBAction func stepperChanged(_ sender: Any) {
        
        // Calculate the scale based on stepper value
        switch scaleStepper.value {
            
        case 0:
            scaledCircleRadius = Double(rCircle - 5) * 2.0
            gShow.text = "0.5g" // to show the scale close to the outside circle
        case 1:
            scaledCircleRadius = Double((rCircle - 5) )
            gShow.text = "1g"
            
        case 2:
            scaledCircleRadius = Double((rCircle - 5) / 2)
            gShow.text = "2g"
            
        case 3:
            scaledCircleRadius = Double((rCircle - 5) / 3)
            gShow.text = "3g"
            
        case 4:
            scaledCircleRadius = Double((rCircle - 5) / 4)
            gShow.text = "4g"
            
        default:
            scaledCircleRadius = Double(rCircle - 5) * 2
            gShow.text = "0.5g"
        }
    }
    
    // devMotion(): RETURNS THE EVENTS OF ACCELERATION OF THE DEVICE
    //      +x -> screen left to right
    //      +y -> screen bottom to top
    //      +z -> screen front to back
    //
    //
    // keeping the phone vertical and perpendiculat to the motion vector
    //     -left< x > +right (like you turn to right)
    //     -front <z> back (like you brake)
    //
    func devMotion () {
        //Read phone position in the space. The phone should be square to the motion
        // other angles need to be corrected by the sin of the angle with horizon
        //let rollY = degrees(radians: motion.attitude.roll)
        //let yawZ = degrees(radians: motion.attitude.yaw)
        //let pitchX = degrees(radians: motion.attitude.pitch)
        //print("Pitch: \(Int(pitchX))  Roll: \(Int(rollY))  Yaw: \(Int(yawZ))")
        // the reading are NOT ABSOLUTE hence no correction are in place

        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (motion: CMDeviceMotion?, error: Error?) in
            if let error = error {
                print("ERROR : \(error.localizedDescription)")
                exit(0)
            }
            
            if let acceleration = motion?.userAcceleration {
                /*  Keeping the phone in front of you and square to the direction of the motion
                 x is acceleration left to right, z back to front and y down to up
                 used s accelerometer in a car, y is meaningful and only x and z are shown
                 */
                
                // Read Acceleration
                let x = acceleration.x
                let y = acceleration.y
                let z = acceleration.z
            
                
                if x < self.minx {
                    self.minx = x
                    self.labelx.text = String(round(self.minx * 100) / 100)
                }
                if y < self.miny {
                    self.miny = y
                    self.labely.text = String(round(self.miny * 100) / 100)
                    
                }
                if z < self.minz {
                    self.minz = z
                    self.labelz.text = String(round(self.minz * 100) / 100)
                }
                
                if x > self.maxx {
                    self.maxx = x
                    self.labelX.text = String(round(self.maxx * 100) / 100)
                }
                if y > self.maxy {
                    self.maxy = y
                    self.labelY.text = String(round(self.maxy * 100) / 100)
                }
                if z > self.maxz {
                    self.maxz = z
                    self.labelZ.text = String(round(self.maxz * 100) / 100)
                }
                
                // place the bullet of the current acceleration data on the screen
                placeBullet(aX: x,aY: y,aZ: z)
            }
        }
        
        //
        // This function set the parameters to design the bullet in position
        //
        func placeBullet (aX: Double, aY: Double, aZ: Double) {
            // If the single Bullet has been chosen, clean (i.e rebuild) the accelerometer circle and show in label
            if showAllBulletsOrCurrentOne.isOn {
                bulletSingleOrAll.text = "Current"
                accelerometerDisc()
            }else
            {bulletSingleOrAll.text = "History"}
            
            
            // check that the Bullet is within the accelerometric circle
            // if yes createCircle, else do not don't diplay it
            // formula of a circle given the center and the radius   --->  (x - α)2 + (y- β)2 = r2
            // the formula is split because a single one is too complex for the compiler
            let test = pow((aX * scaledCircleRadius - 20), 2.0) + pow((aZ * scaledCircleRadius - 20), 2.0)
            let r2 = pow(Double(rCircle),2.0)
            if (test < r2 ) {
                // Generate the Bullet of the current acceleration and place it in the
                // right position in the accelerometer circle
                posX = centerAccX + Int(aX * scaledCircleRadius)
                posY = centerAccY + Int(aZ * scaledCircleRadius)
                radiusCircle = 5
                circleThickness = 6
                createCircle()
            } else
            {
                print("outside position)")
                print ("centX-Y=\(centerAccX)/\(centerAccY)  posX=\(posX) posY=\(posY) test=\(test) r2=\(r2)")
            }
        }
        
    }
    
    // DESIGN CIRCLES
    //
    // this function draw a circle with the correct specs (radius, thickness, position, color etc.)
    // it is used for creating the accelerometer disc as well as for the bullets
    private func createCircle() {
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: CGPoint(x: posX, y: posY) , radius: Double(radiusCircle), startAngle: 0, endAngle: 6.289, clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = circleThickness
        shapeLayer.strokeColor = lineColor
        shapeLayer.fillColor = fillColor
        self.view.layer.addSublayer(shapeLayer)
    }
    //
    //  DESIGN THE ACCELLEROMETER CIRCLES AND CROSS
    //
    func accelerometerDisc () {
        
        // redesign the image to clean out all bullets
        view.addSubview(myImageView)
        
        
        /* DESIGN THE ACCELEROMETER DISC
        // this function works fine but it has been replaced by an image
        // because the contruction consumes a lot of memory and the app get stuck after a few minutes of work
         
        // external circle (stepper 4 = 1g)
        posX = centerAccX
        posY = centerAccY
        radiusCircle = rCircle+5
        circleThickness = 6.0
        createCircle()
        
        // mid-ext circle (stepper 3 = 1g)
        radiusCircle = Int(rCircle * 100 / 133)      // 1.33
        circleThickness = 1.0
        createCircle()
        
        // mid-int circle  (stepper 2 = 1g)
        radiusCircle = Int(rCircle * 100 / 195)    //  1.95
        circleThickness = 1.0
        createCircle()
        
        // internal circle (stepper 1 = 1g)
        radiusCircle = Int(rCircle * 100 / 385)    //  3.85
        circleThickness = 1.0
        createCircle()
        
        // DESIGN THE CROSS OF THE ACCELLEROMETER
        // Initializes the layer that will be drawn with the cross
        // Sets the center point of the layer in the middle of the circle
        // Sets the filling color the path of the cross should be rendered with
        // Start the bezier path object
        let bezierPath = UIBezierPath()
        let shapeLayer = CAShapeLayer()
        let offsetedPosition = CGPoint(x: centerAccX, y: centerAccY)
        shapeLayer.position = offsetedPosition
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.lineWidth = 1.0
        
        bezierPath.move(to: .zero)
        bezierPath.addLine(to: CGPoint(x: -1, y: -1))
        bezierPath.addLine(to: CGPoint(x: -1, y: rCircle))
        bezierPath.addLine(to: CGPoint(x: 1, y: rCircle))
        bezierPath.addLine(to: CGPoint(x: 1, y: -rCircle))
        bezierPath.addLine(to: CGPoint(x: -1, y: -rCircle))
        
        bezierPath.addLine(to: CGPoint(x: -1, y: -1))
        bezierPath.addLine(to: CGPoint(x: rCircle, y: -1))
        bezierPath.addLine(to: CGPoint(x: rCircle, y: +1))
        bezierPath.addLine(to: CGPoint(x: -rCircle, y: +1))
        bezierPath.addLine(to: CGPoint(x: -rCircle, y: -1))
        
        // Finishes the path of the cross
        bezierPath.close()
        
        
        // Uses core graphics to save the path as a snapshot
        //      (as far as I understood)
        shapeLayer.path = bezierPath.cgPath
        
        // Adds to the view
        // And save it in an attribute so you can to update/delete it
        self.view.layer.addSublayer(shapeLayer)
        */
    }
}  // end of class


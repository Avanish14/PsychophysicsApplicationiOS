//
//  ClickerViewController.swift
//  Psycho
//
//  Created by Avanish Mishra on 6/21/16.
//  Copyright © 2016 Avanish. All rights reserved.
//

import UIKit
import FayeSwift
import AudioToolbox

class ClickerViewController: UIViewController, FayeClientDelegate {

    var currentAnswer: Int? //stores answer depending on button that user chose
    var timerCounter: Int = 20 //seconds that the clicker screen will be prompted for
    var timer = NSTimer()
    var answers = [Int]()
    var segmentNumber = 1
    var timerDone = false
    var alert: UIAlertController?
    var client:FayeClient = FayeClient(aFayeURLString: "ws://192.168.206.140:5222/faye", channel: "/psycho") //ws://192.168.206.140:5222/faye

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBAction func markOne(sender: UIButton) {
        resetColor()
        currentAnswer = 1
        sender.backgroundColor = UIColor.orangeColor()
    }
    @IBAction func markTwo(sender: UIButton) {
        resetColor()
        currentAnswer = 2
        sender.backgroundColor = UIColor.orangeColor()
    }
    @IBAction func markThree(sender: UIButton) {
        resetColor()
        currentAnswer = 3
        sender.backgroundColor = UIColor.orangeColor()
    }
    @IBAction func markFour(sender: UIButton) {
        resetColor()
        currentAnswer = 4
        sender.backgroundColor = UIColor.orangeColor()
    }
    @IBAction func quitToMainMenu(sender: UIBarButtonItem) {
        if (timerCounter > 1) {
            alert = UIAlertController(title: "Alert", message: "This will end the study. Are you sure you want to proceed?",preferredStyle: UIAlertControllerStyle.Alert)
            alert!.addAction(UIAlertAction(title: "Yes", style:UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                self.handlingAnswersForAbruptDC(false)
                self.quitToMain(false)
            }))
            alert!.addAction(UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                if self.timerDone {
                    self.changeScene()
                }
            }))
            self.presentViewController(alert!,animated: true, completion: nil)
        }
    }
    
    @IBAction func viewRankingSystem(sender: UIBarButtonItem) {
        if timerCounter > 2 {
            alert = UIAlertController(title: "Ranking System", message: "",preferredStyle: UIAlertControllerStyle.Alert)
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.Left
            
            let message = NSMutableAttributedString(
                string: "1: Unacceptable\nCannot watch anymore/Cannot bear to sit through this quality\n\n2: Satisfactory\nCan sit through the video at this quality, but it might be annoying\n\n3: Good\nCan definitely sit through the video, but the quality does detract a bit of enjoyment.\n\n4: Excellent\nNo complaints.",
                attributes: [
                    NSParagraphStyleAttributeName: style,
                    NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
                    NSForegroundColorAttributeName : UIColor.blackColor()
                ]
            )
            alert!.setValue(message, forKey: "attributedMessage")
            
            alert!.addAction(UIAlertAction(title: "Okay", style:UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                if self.timerDone {
                    self.changeScene()
                }
            }))
            self.presentViewController(alert!,animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if timeLabel != nil {
            let minute = timerCounter/60
            let second = timerCounter % 60
            if (second > 9) {
                timeLabel.text = "\(minute):\(second)"
            }
            else {
                timeLabel.text = "\(minute):0\(second)"
            }
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetColor() {
        if let answer = currentAnswer {
            switch answer {
            case 1: buttonOne.backgroundColor = UIColor.init(red: 102.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            case 2: buttonTwo.backgroundColor = UIColor.init(red: 102.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            case 3: buttonThree.backgroundColor = UIColor.init(red: 102.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            case 4: buttonFour.backgroundColor = UIColor.init(red: 102.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            default: break
            }
        }
    }
    func updateTimeLabel() {
        timerCounter-=1
        if (timerCounter < 1) {
            timer.invalidate()
            timerDone = true
            if currentAnswer == nil {
                currentAnswer = 0
            }
            answers.append(currentAnswer!)
            sendAnAnswer(client, answer: currentAnswer!)
            if let alertExists = alert {
                alertExists.dismissViewControllerAnimated(true, completion: nil)
            }
            changeScene()
        }
        else {
            if timeLabel != nil {
                let minute = timerCounter/60
                let second = timerCounter % 60
                if (second > 9) {
                    timeLabel.text = "\(minute):\(second)"
                }
                else {
                    timeLabel.text = "\(minute):0\(second)"
                }
            }

        }
    }
    func handlingAnswersForAbruptDC(accident: Bool) {//accident - true - disconnected from server  false - quit manually 
        if currentAnswer == nil {
            currentAnswer = 0
        }
        if !(accident) {
            sendAnAnswer(self.client, answer: self.currentAnswer!)
        }
        answers.append(self.currentAnswer!)
        while answers.count < 30{
            answers.append(0)
        }
    }
    func changeScene() {
        if segmentNumber < 30 {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Temp") as! IdleViewController
            vc.answers = answers
            vc.segmentNumber = segmentNumber + 1
            vc.client = client
            vc.client.delegate = vc
            presentViewController(vc, animated: true, completion: nil)
        }
        else {
            quitToMain(false)
        }
    }
    func quitToMain(accident: Bool) { //accident - true - disconnected from server  false - quit manually or experiment completed (30 answers)
        timer.invalidate()
        let nvc = self.storyboard?.instantiateViewControllerWithIdentifier("main") as! UINavigationController
        let vc = nvc.topViewController as! ViewController
        vc.answers = answers
        if (accident) {
            vc.disconnectedFromIdle = true
        }
        else {
            vc.experimentCompleted = true
        }
        vc.client = client
        vc.client.delegate = vc
        presentViewController(nvc, animated: true, completion: nil)
    }

    // MARK:
    // MARK: FayeClientDelegate
    
    func disconnectedFromServer(client: FayeClient) {
        print("Disconnected from Faye server from Clicker")
        if let alertExists = alert {
            alertExists.dismissViewControllerAnimated(true, completion: nil)
        }
        handlingAnswersForAbruptDC(true)
        quitToMain(true)
    }
    
    func didSubscribeToChannel(client: FayeClient, channel: String) {
        print("Subscribed to channel: \(channel) from Clicker")
        alert = UIAlertController(title: "Connected!", message: "",preferredStyle: UIAlertControllerStyle.Alert)
        alert!.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert!,animated: true, completion: nil)
        if let id = client.fayeClientId {
            client.sendMessage(["\(id)":"iPhone connected to channel: \(channel) from Clicker" as AnyObject],channel: channel)
        }
        else {
            client.sendMessage(["\(client.fayeClientId)":"iPhone connected to channel: \(channel) from Clicker" as AnyObject],channel: channel)
        }
    }
    
    func didUnsubscribeFromChannel(client: FayeClient, channel: String) {
        print("Unsubscribed from channel \(channel) from Clicker")
    }
    
    func subscriptionFailedWithError(client: FayeClient, error: String) {
        print("Subscription failed from Clicker")
    }
    
    func messageReceived(client: FayeClient, messageDict: NSDictionary, channel: String) {
        let text: String? = messageDict["text"] as? String
        print("Received message: \(text) from Clicker")
    }
    
    func sendAnAnswer(client: FayeClient, answer: Int) { //sends answer to server
        if let id = client.fayeClientId {
            client.sendMessage(["\(id)":"\(answer)" as AnyObject],channel: "/psycho")
        }
        else {
            client.sendMessage(["\(client.fayeClientId)":"\(answer)" as AnyObject],channel: "/psycho")
        }
    }
}
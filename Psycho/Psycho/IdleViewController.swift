//
//  IdleViewController.swift
//  Psycho
//
//  Created by Avanish Mishra on 6/21/16.
//  Copyright © 2016 Avanish. All rights reserved.
//

import UIKit
import FayeSwift

class IdleViewController: UIViewController, FayeClientDelegate{
    
    var activityIcon = UIActivityIndicatorView()
    var timerCounter: Int = 5000 //set to 100
    var timer = NSTimer()
    var answers = [Int]()
    var segmentNumber = 1
    var alert: UIAlertController?
    var channelName:String = "/psycho"
    var client:FayeClient = FayeClient(aFayeURLString: "ws://192.168.206.140:5222/faye", channel: "/psycho") //ws://192.168.206.140:5222/faye

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIcon = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIcon.color = UIColor.blackColor()
        activityIcon.center = self.view.center
        activityIcon.startAnimating()
        self.view.addSubview(activityIcon)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeToClicker() {
        timer.invalidate()
        activityIcon.stopAnimating()
        let nvc = self.storyboard?.instantiateViewControllerWithIdentifier("clickerNav") as! UINavigationController
        let cvc = nvc.topViewController as! ClickerViewController
        print("\(answers)changeToClicker")
        cvc.answers = answers
        cvc.segmentNumber = segmentNumber
        cvc.client = client
        cvc.client.delegate = cvc
        var tvc: UIViewController?
        if var topvc = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedvc = topvc.presentedViewController {
                topvc = presentedvc
            }
            tvc = topvc
        }
        tvc!.presentViewController(nvc, animated: true, completion: nil)
    }
    
    // MARK:
    // MARK: FayeClientDelegate
    
    func disconnectedFromServer(client: FayeClient) {
        print("Disconnected from Faye server from Idle")
        let nvc = self.storyboard?.instantiateViewControllerWithIdentifier("main") as! UINavigationController
        let vc = nvc.topViewController as! ViewController
        while answers.count < 30{
            answers.append(0)
        }
        vc.answers = answers
        vc.client = client
        vc.disconnectedFromIdle = true
        vc.client.delegate = vc
        presentViewController(nvc, animated: true, completion: nil)
    }
    
    func didSubscribeToChannel(client: FayeClient, channel: String) {
        print("Subscribed to channel: \(channel) from Idle")
        alert = UIAlertController(title: "Connected!", message: "",preferredStyle: UIAlertControllerStyle.Alert)
        alert!.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert!,animated: true, completion: nil)
        if let id = client.fayeClientId {
            client.sendMessage(["\(id)":"iPhone connected to channel: \(channel) from Idle" as AnyObject],channel: channel)

        }
        else {
            client.sendMessage(["\(client.fayeClientId)":"iPhone connected to channel: \(channel) from Idle" as AnyObject],channel: channel)
        }
    }
    
    func didUnsubscribeFromChannel(client: FayeClient, channel: String) {
        print("Unsubscribed from channel \(channel) from Idle")
    }
    
    func subscriptionFailedWithError(client: FayeClient, error: String) {
        print("Subscription failed from Idle")
    }
    
    func messageReceived(client: FayeClient, messageDict: NSDictionary, channel: String) {
        let text: String? = messageDict["text"] as? String
        if text != nil {
            print("Received message: \(text!) from Idle")
        }
        else {
            print("Received message: \(text) from Idle")
        }
        if let msg = text {
            if let alertExists = alert {
                sleep(1)
                alertExists.dismissViewControllerAnimated(true, completion: nil)
            }
            if (msg.containsString("switch")){
                changeToClicker()
            }
        }
    }
}
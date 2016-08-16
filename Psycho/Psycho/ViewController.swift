//
//  ViewController.swift
//  Psycho
//
//  Created by Avanish Mishra on 6/13/16.
//  Copyright © 2016 Avanish. All rights reserved.
//

import UIKit
import FayeSwift

class ViewController: UIViewController, UITextFieldDelegate, FayeClientDelegate {
    
    var answers = [Int]()
    var experimentCompleted = false
    var disconnectedFromIdle = false
    var alert: UIAlertController?
    var channelName: String = "/psycho"
    var client:FayeClient = FayeClient(aFayeURLString: "ws://192.168.206.140:5222/faye", channel: "/psycho")
    
    @IBAction func connectToServer(sender: UIButton) {
        if client.isSubscribedToChannel(channelName){
            alert = UIAlertController(title: "Alert", message: "You are already connected to a server. Please restart the application if you wish to connect to a different server.",preferredStyle: UIAlertControllerStyle.Alert)
            alert!.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert!,animated: true, completion: nil)
        }
        else {
          alert = UIAlertController(title: "Connection", message: "Please enter the IP Address and port of the server.",preferredStyle: UIAlertControllerStyle.Alert)
            alert!.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "IP Address"
            })
            alert!.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Port"
            })
            alert!.addAction(UIAlertAction(title: "Send", style:UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                let textFieldOne = self.alert!.textFields![0]
                let textFieldTwo = self.alert!.textFields![1]
                let addr = textFieldOne.text!
                let port = (textFieldTwo.text! as NSString).integerValue
                self.startConnection(addr, port: port)
            }))
            alert!.addAction(UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert!,animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if experimentCompleted {
            let alert = UIAlertController(title: "Thank you!", message: "The experiment data you have collected is located in \"Data\". Closing the application will erase the data collected.",preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert,animated: true, completion: nil)
        }
        else if disconnectedFromIdle {
            let alert = UIAlertController(title: "Disconnected from server.", message: "The experiment data you have collected so far is located in \"Data\". Closing the application will erase the data collected.",preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert,animated: true, completion: nil)
            client.unsubscribeFromChannel(channelName)
            client.disconnectFromServer()
        }
    }
    
    func startConnection(addr: String, port: Int){
        client.fayeURLString = "ws://\(addr):\(port)/faye"
        client = FayeClient(aFayeURLString: client.fayeURLString, channel: channelName)
        client.delegate = self
        client.connectToServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="showData" {
            let tvc = segue.destinationViewController as! DataTableViewController
            tvc.answers=answers
        }
    }
    
    // MARK:
    // MARK: FayeClientDelegate
    
    func connectedtoser(client: FayeClient) {
        print("Connected to Faye server")
    }
    
    func connectionFailed(client: FayeClient) {
        print("Failed to connect to Faye server!")
        alert = UIAlertController(title: "Failed to connect.", message: "",preferredStyle: UIAlertControllerStyle.Alert)
        alert!.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert!,animated: true, completion: nil)
    }
    
    func disconnectedFromServer(client: FayeClient) {
        client.unsubscribeFromChannel(channelName)
        client.disconnectFromServer()
        print("Disconnected from Faye server")
        alert = UIAlertController(title: "Disconnected from server.", message: "",preferredStyle: UIAlertControllerStyle.Alert)
        alert!.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
        var tvc: UIViewController?
        if var topvc = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedvc = topvc.presentedViewController {
                topvc = presentedvc
            }
            tvc = topvc
        }
        tvc!.presentViewController(alert!,animated: true, completion: nil)
    }
    
    func didSubscribeToChannel(client: FayeClient, channel: String) {
        print("Subscribed to channel: \(channel)")
        alert = UIAlertController(title: "Connected!", message: "",preferredStyle: UIAlertControllerStyle.Alert)
        alert!.addAction(UIAlertAction(title: "OK", style:UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert!,animated: true, completion: nil)
        if let id = client.fayeClientId{
            client.sendMessage(["\(id)":"iPhone connected to channel: \(channel)" as AnyObject],channel: channel)
        }
        else {
            client.sendMessage(["\(client.fayeClientId)":"iPhone connected to channel: \(channel)" as AnyObject],channel: channel)
        }
    }
    
    func didUnsubscribeFromChannel(client: FayeClient, channel: String) {
        print("Unsubscribed from channel \(channel)")
    }
    
    func subscriptionFailedWithError(client: FayeClient, error: String) {
        print("Subscription failed")
    }
    
    func messageReceived(client: FayeClient, messageDict: NSDictionary, channel: String) {
        let text: String? = messageDict["text"] as? String
        if text != nil {
            print("Received message: \(text!)")
        }
        else {
            print("Received message: \(text)")
        }
        if var msg = text {
            msg = msg.lowercaseString
            print(msg)
            if let alertExists = alert {
                sleep(1)
                alertExists.dismissViewControllerAnimated(true, completion: nil)
            }
            if (msg.containsString("start")) { //switches to Idle Screen
                let isMainPresented: Bool? = self.presentedViewController?.isKindOfClass(ViewController)
                if (isMainPresented == nil || isMainPresented == true){
                    let ivc = self.storyboard?.instantiateViewControllerWithIdentifier("Temp") as! IdleViewController
                    ivc.client = client
                    ivc.client.delegate = ivc
                    presentViewController(ivc, animated: true, completion: nil)
                }
                else {
                    let isAlertPresented = self.presentedViewController?.isKindOfClass(UIAlertController)
                    if let question = isAlertPresented {
                        if question == true {
                            print("alert is still open")
                        }
                    }
                    print("The main menu is not presented when received Start message")
                }
            }
        }
    }
}
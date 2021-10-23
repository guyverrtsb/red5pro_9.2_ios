//
//  BandwidthDetectionTest.swift
//  R5ProTestbed
//
//  Created by Kyle Kellogg on 7/25/17.
//  Copyright © 2015 Infrared5, Inc. All rights reserved.
// 
//  The accompanying code comprising examples for use solely in conjunction with Red5 Pro (the "Example Code") 
//  is  licensed  to  you  by  Infrared5  Inc.  in  consideration  of  your  agreement  to  the  following  
//  license terms  and  conditions.  Access,  use,  modification,  or  redistribution  of  the  accompanying  
//  code  constitutes your acceptance of the following license terms and conditions.
//  
//  Permission is hereby granted, free of charge, to you to use the Example Code and associated documentation 
//  files (collectively, the "Software") without restriction, including without limitation the rights to use, 
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//  
//  The Software shall be used solely in conjunction with Red5 Pro. Red5 Pro is licensed under a separate end 
//  user  license  agreement  (the  "EULA"),  which  must  be  executed  with  Infrared5,  Inc.   
//  An  example  of  the EULA can be found on our website at: https://account.red5pro.com/assets/LICENSE.txt.
// 
//  The above copyright notice and this license shall be included in all copies or portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  INCLUDING  BUT  
//  NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY, FITNESS  FOR  A  PARTICULAR  PURPOSE  AND  
//  NONINFRINGEMENT.   IN  NO  EVENT  SHALL INFRARED5, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//  WHETHER IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION 
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit
import R5Streaming

@objc(BandwidthDetectionTest)
class BandwidthDetectionTest: BaseTest {

    var current_rotation = 0;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let detection = R5BandwidthDetection()
        let config = getConfig()
        
        let minBitrate = Int32(Testbed.getParameter(param: "bitrate") as! Int)
        
        print("Checking speeds... need to be equal to or above \(minBitrate)")
        detection.checkSpeeds(config.host, forSeconds: 2.5, withSuccess: { (response) in
            let responseDict = response! as NSDictionary
            let download = Int32(responseDict.object(forKey: "download") as! Int)
            let upload = Int32(responseDict.object(forKey: "upload") as! Int)
            print("Download speed is \(download)Kbps\nUpload speed is \(upload)Kbps\n")
            
            if (download >= minBitrate && upload > minBitrate) {
                self.beginStream(config: config)
            } else {
                print("Your bandwidth is too low to stream!\n");
            }
        }) { (error) in
            print("There was an error checking your speeds! \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func beginStream(config: R5Configuration) {
        setupDefaultR5VideoViewController()
        
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
    }

    func updateOrientation(value: Int) {
        if current_rotation == value {
            return
        }

        current_rotation = value
        currentView?.view.layer.transform = CATransform3DMakeRotation(CGFloat(value), 0.0, 0.0, 0.0);
    }

    @objc func onMetaData(data : String) {
        let props = data.characters.split(separator: ";").map(String.init)
        props.forEach { (value: String) in
            let kv = value.characters.split(separator: "=").map(String.init)
            if (kv[0] == "orientation") {
                updateOrientation(value: Int(kv[1])!)
            }
        }
    }

}


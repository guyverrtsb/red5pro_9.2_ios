//
//  PublishStreamImageTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
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

@objc(PublishPauseTest)
class PublishPauseTest: BaseTest {

    var audioBtn: UIButton? = nil
    var videoBtn: UIButton? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        
        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection: connection!)
        // show preview and debug info
        
        self.currentView!.attach(publishStream!)
        
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: getPublishRecordType ())
        

        let screenSize = UIScreen.main.bounds.size
        
        audioBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height - 40, width: 50, height: 40))
        audioBtn?.backgroundColor = UIColor.darkGray
        audioBtn?.setTitle("audio", for: UIControl.State.normal)
        view.addSubview(audioBtn!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(PublishPauseTest.pauseAudio))
        audioBtn?.addGestureRecognizer(tap)
        
        videoBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 120, y: screenSize.height - 40, width: 50, height: 40))
        videoBtn?.backgroundColor = UIColor.darkGray
        videoBtn?.setTitle("video", for: UIControl.State.normal)
        view.addSubview(videoBtn!)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(PublishPauseTest.pauseVideo))
        videoBtn?.addGestureRecognizer(tap2)
        
    }
    
    @objc func pauseAudio() {
        
        let hasAudio = !(self.publishStream?.pauseAudio)!;
        self.publishStream?.pauseAudio = hasAudio;
        ALToastView.toast(in: self.view, withText:"Pausing Audio")
        
    }
    
    @objc func pauseVideo() {
        
        let hasVideo = !(self.publishStream?.pauseVideo)!;
        self.publishStream?.pauseVideo = hasVideo;
        ALToastView.toast(in: self.view, withText:"Pausing Video")
        
    }

    @objc func handleSingleTap(recognizer : UITapGestureRecognizer) {

        let hasAudio = !(self.publishStream?.pauseAudio)!;
        let hasVideo = !(self.publishStream?.pauseVideo)!;
        
        if(hasAudio && hasVideo){
            self.publishStream?.pauseAudio = true
            self.publishStream?.pauseVideo = false
             ALToastView.toast(in: self.view, withText:"Pausing Audio")
            
        }else if(hasVideo && !hasAudio){
            self.publishStream?.pauseVideo = true
            self.publishStream?.pauseAudio = false
            ALToastView.toast(in: self.view, withText:"Pausing Video")
        }else if(!hasVideo && hasAudio){
            self.publishStream?.pauseVideo = true
            self.publishStream?.pauseAudio = true
            ALToastView.toast(in: self.view, withText:"Pausing Audio/Video")
        }else{
            self.publishStream?.pauseVideo = false
            self.publishStream?.pauseAudio = false
            ALToastView.toast(in: self.view, withText:"Resuming Audio/Video")
        }
   
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        if (Int(statusCode) == Int(r5_status_buffer_flush_start.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushStart")))
        }
        else if (Int(statusCode) == Int(r5_status_buffer_flush_empty.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushComplete")))
        }
    }


}
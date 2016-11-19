//
//  Core.swift
//  Novis Obliviate
//
//  Created by Martin Hartt on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import Foundation
import AFNetworking
import Zip

class Core {

  var sharedInstance: Core = Core()
  
  var microphoneRecorder: Recorder?
  var accelorometerRecorder: Recorder?
  
  private init() {
    microphoneRecorder = MicrophoneRecorder()
  }
  
  func start() {
    microphoneRecorder?.start()
    accelorometerRecorder?.start()
  }
  
  func stop() {
    guard
      let accelorometerURL = microphoneRecorder?.stop(),
      let microphoneURL = accelorometerRecorder?.stop()
      else { return }
    
    sendData(accelerometorDataURL: accelorometerURL, microphoneDataURL: microphoneURL)
  }
  
  func sendData(accelerometorDataURL: URL, microphoneDataURL: URL) {
    let zipFilePath = try? Zip.quickZipFiles([
      accelerometorDataURL,
      microphoneDataURL
      ], fileName: "archive_\(NSDate().timeIntervalSince1970)")
    
    let manager = AFHTTPSessionManager()
    
    let url = "http://localhost:9000/api/content"
    
    let params = [
      "familyId":"10000",
      "contentBody" : "Some body content for the test application",
      "name" : "the name/title",
      "typeOfContent":"photo"
    ]
    
    
    manager.post(url, parameters: params, constructingBodyWith: { (data: AFMultipartFormData) in
                  let res = try? data.appendPart(withFileURL: zipFilePath!, name: "combinedZip")
      print("was file added properly to the body? \(res)")
    }, success: { operation, responseObject in
      print("Yes thies was a success")
    }, failure: { operation, error in
      print("We got an error here.. \(error.localizedDescription)")
    })
  }
  
}
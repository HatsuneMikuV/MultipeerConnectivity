//
//  ViewController.swift
//  Socket
//
//  Created by mbp13 on 2020/7/28.
//  Copyright © 2020 Anglemiku. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let K_Receive_Success = "K_Receive_Success"
let K_Receive_Fail = "K_Receive_Fail"

let K_Send_Done = "K_Send_Done"


class ViewController: UIViewController {
  
  @IBOutlet weak var sendText: UITextField!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var label: UILabel!
  
  var data : Data?
  
  
  var myPeerID : MCPeerID?
  var mySession : MCSession?
  var browserVC : MCBrowserViewController?
  var advertiser : MCAdvertiserAssistant?
  
  var dataArray:[Data] = []
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    self.myPeerID = MCPeerID.init(displayName: UIDevice.current.name)
    
    self.mySession = MCSession.init(peer: self.myPeerID!, securityIdentity: nil, encryptionPreference: .optional)
    self.mySession?.delegate = self
    
    self.browserVC = MCBrowserViewController.init(serviceType: "Chat", session: self.mySession!)
    self.browserVC?.delegate = self
    
    self.advertiser = MCAdvertiserAssistant.init(serviceType: "Chat", discoveryInfo: nil, session: self.mySession!)
    self.advertiser?.start()
    
    self.dataArray.append("111111".data(using: .utf8)!)
  }
  
  @IBAction func contectApp() {
    if self.browserVC != nil {
      self.present(self.browserVC!, animated: true, completion: nil)
    }
  }
  
  @IBAction func sendApp() {
    var data:Data?
    if self.sendText.text?.count ?? 0 > 0 {
      data = self.sendText.text!.data(using: .utf8)
      self.sendText.text = ""
    } else if self.data?.count ?? 0 > 0 {
      data = self.data
      self.data = nil
    }
    
    if data?.count ?? 0 > 0 {
      do {
        try self.mySession!.send(data!,
                                 toPeers: self.mySession!.connectedPeers,
                                 with: MCSessionSendDataMode.reliable)
      } catch _ {
        print("send error")
      }
    } else {
      print("data error")
    }
  }
  
  func dismissApp() {
    self.browserVC?.dismiss(animated: true)
    print("连接成功")
  }
  
  @IBAction func closeConnect() {
    print("关闭连接")
    stopWifiSharing()
  }
  
  @IBAction func choiceResource() {
    let imageController = UIImagePickerController.init()
    imageController.allowsEditing = true
    imageController.delegate = self
    present(imageController, animated: true)
  }
  
  func stopWifiSharing() {
    self.myPeerID = nil
    
    self.mySession?.disconnect()
    self.mySession?.delegate = nil
    self.mySession = nil
    
    self.browserVC?.delegate = nil
    self.browserVC = nil
    
    self.advertiser?.delegate = nil
    self.advertiser?.stop()
    self.advertiser = nil
  }
  
  func appendFileData(fileData:Data) {
    DispatchQueue.main.async {
      if let str = String.init(data: fileData, encoding: .utf8) {
        self.label.text = str
      } else {
        self.imageView.image = UIImage.init(data: fileData)
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
}

extension ViewController : MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case MCSessionState.connected:
      print("Connected: \(peerID.displayName)")
      
    case MCSessionState.connecting:
      print("Connecting: \(peerID.displayName)")
      
    case MCSessionState.notConnected:
      print("Not Connected: \(peerID.displayName)")
    @unknown default:
      print("fatalError")
    }
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    print("data received : %d", data.count)
    
    if let str = String.init(data: data, encoding: .utf8), str == K_Receive_Success {
      print(K_Receive_Success)
      
      // Knowing that the other party's data is successfully received
      if self.dataArray.count > 0 {
        // continue to send the data
        
        // do something...
      } else {

        // or inform the data transmission is complete
        let doneData = K_Send_Done.data(using: .utf8)!
        do {
          try self.mySession!.send(doneData,
                                   toPeers: self.mySession!.connectedPeers,
                                   with: MCSessionSendDataMode.reliable)
        } catch _ {
          print("send error")
        }
      }
    } else if let str = String.init(data: data, encoding: .utf8), str == K_Send_Done {
      print(K_Send_Done)
      
      // Know that the other party's data has been sent, close your connection
      stopWifiSharing()
      
    } else {
      self.appendFileData(fileData: data)
      
      if data.count > 0 {//
        print("receive success")
      } else {
        print("receive fail")
      }
      
      // After receiving the data, the analysis is successful and inform the other party
      let doneData = K_Receive_Success.data(using: .utf8)!
      do {
        try self.mySession!.send(doneData,
                                 toPeers: self.mySession!.connectedPeers,
                                 with: MCSessionSendDataMode.reliable)
      } catch _ {
        print("send error")
      }
    }
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    print("did receive stream")
  }
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    print("start receiving")
  }
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    print("finish receiving resource")
  }
  
  
}


extension ViewController : MCBrowserViewControllerDelegate {
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    self.dismissApp()
  }
  
  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    self.dismissApp()
  }
}




extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.editedImage] as? UIImage else { return }
    if let jpegData = image.jpegData(compressionQuality: 0.8) {
      appendFileData(fileData: jpegData)
      self.data = jpegData
    }
    dismiss(animated: true)
  }
  
}

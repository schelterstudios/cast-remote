//
//  ContentView.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 7/29/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import GoogleCast
import Combine

struct CastButton: UIViewRepresentable {
    func makeUIView(context: Context) -> UIButton {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            btn.titleLabel?.text = "[]"
            return btn
        }
        return GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
    }
}

class RequestHandler: NSObject, GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        print("SUCCESS")
    }
    
    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("ABORT")
    }
    
    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("FAIL")
    }
}

struct ContentView: View {
    private var requestHandler: GCKRequestDelegate = RequestHandler()
    @State private var selection = 0
    
    //@ObservedObject var pinnedModel = PinnedProvidersViewModel(services: [TwitchService()]).eraseToAnyViewModel()
    
 
    var body: some View {
        TabView(selection: $selection){
            //TwitchChannelsSheet()
            NavigationView() {
                VStack {
                    Text("First View")
                    //CastButton()
                    Button(action: castMedia) {
                        Text("CAST")
                    }
                }
                .navigationBarTitle(Text("Cast Test"))
                .navigationBarItems(trailing: CastButton())
            }
            .font(.title)
            .tabItem {
                VStack {
                    Image("first")
                    Text("First")
                }
            }.tag(0)
            ProvidersGroupView()
                //.environmentObject(pinnedModel)
            .tabItem {
                VStack {
                    Image("second")
                    Text("Second")
                }
            }.tag(1)
        }
    }
    
    func castMedia() {
        let metadata = GCKMediaMetadata()
        metadata.setString("Big Buck Bunny (2008)", forKey: kGCKMetadataKeyTitle)
        metadata.setString("Big Buck Bunny tells the story of a giant rabbit with a heart bigger than " +
          "himself. When one sunny day three rodents rudely harass him, something " +
          "snaps... and the rabbit ain't no bunny anymore! In the typical cartoon " +
          "tradition he prepares the nasty rodents a comical revenge.",
                           forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg")!,
                                   width: 480,
                                   height: 360))
        
        let url = URL.init(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        guard let mediaURL = url else {
          print("invalid mediaURL")
          return
        }

        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: mediaURL)
        mediaInfoBuilder.streamType = GCKMediaStreamType.none;
        mediaInfoBuilder.contentType = "video/mp4"
        mediaInfoBuilder.metadata = metadata
        let mediaInfo = mediaInfoBuilder.build()
        
        /*mediaInformation = mediaInfoBuilder.build()

        guard let mediaInfo = mediaInformation else {
          print("invalid mediaInformation")
          return
        }
*/
        if let request = GCKCastContext.sharedInstance().sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInfo) {
          request.delegate = requestHandler
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

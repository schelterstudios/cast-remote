//
//  ContentView.swift
//  Cast Remote
//
//  Created by Steve Schelter on 7/29/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    //private var requestHandler: GCKRequestDelegate = RequestHandler()
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection){
            CastableListView()
                .environmentObject(CastableListViewModel().eraseToAnyViewModel())
                .tabItem {
                    VStack {
                        Image(systemName: "tv.fill")
                            .imageScale(.large)
                        Text("Cast Remote")
                    }
                }.tag(0)
            ProviderGroupView()
                .environmentObject(ProviderGroupViewModel(title: "Watchlist",
                                                          group: App.shared.pinned!).eraseToAnyViewModel())
                .tabItem {
                    VStack {
                        Image(systemName: "eye.fill")
                            .imageScale(.large)
                        Text("Watchlist")
                    }
                }.tag(1)
            Text("Settings")
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                            .imageScale(.large)
                        Text("Profile")
                    }
                }.tag(2)
        }
    }
    
    func castMedia() {
        let streams = DemoJSON().twitchStreams
        return
        
        /*
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
        
        // https://pwn.sh/tools/streamapi.py?url=twitch.tv/glermz
        
        let url = URL(string: "https://video-weaver.fra05.hls.ttvnw.net/v1/playlist/Cs0DubWIsZHHLM3Nj-EKQkIBMUzx8OHcl7kXigaLR5ZVEvC7lXKnPXg2fcYfqHybL0Ir6m-1J472ethM52Lb7D8lzGS1FkgL_Ce9cm8xeRTpT1FRwa09FAPVZbGikgFq6A57UUe6RqoU0vioE0mykBxwkG8LXAzecg3qrufPTqWuzbdceuvZSzcKGF0gKo9yuCtF_GWsXKODxYkfG0zqg-UvAVVZbOkvzFCj2dzGwRLF7zdw4g7pIjlFJAyMyu5QwpcRPk8Ui-LER5qqGi8wTweqldGFbntD2rDQYBuUTuYg2dJRpfkRA-mmmyvU9AdurPb_IMBXmhpTjawXzmb7I-aY9YobeGrOtIlnBpex8oWubuy9841W_-Td2IWW6rfT4zsnbLa74COCD19t3i9XYEg2_T8dJXinhMHhqOIG1J9k5gER0-cswn73Tdt8_1XGCw7qv7JrobOwbKhr-ViXT0GIcf00Y7aJvhcSBupQSgfmj6N5mpRKHNb4biY8v_jTgIAf41BYHCrBBzPTxLGHti7UGzq9MZdkXe3yXwKxSAEcnQcRlPQbCPNfCFbnMifpYOEA8x0ya8oBZzuTlRirnkHlPGFGVjfte22DkER0ay4SEMcPKMS9L0aEGbPW74pYCggaDP0JsgDs_ZnnifK08g.m3u8")
        //let url = URL.init(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        guard let mediaURL = url else {
          print("invalid mediaURL")
          return
        }

        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: mediaURL)
        mediaInfoBuilder.streamType = GCKMediaStreamType.none;
        mediaInfoBuilder.contentType = "video/mp4"
        mediaInfoBuilder.metadata = metadata
        let mediaInfo = mediaInfoBuilder.build()
        */
        /*mediaInformation = mediaInfoBuilder.build()

        guard let mediaInfo = mediaInformation else {
          print("invalid mediaInformation")
          return
        }
*/
        /*
        if let request = GCKCastContext.sharedInstance().sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInfo) {
          request.delegate = requestHandler
        }*/
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().colorScheme(.light)
            ContentView().colorScheme(.dark)
        }
    }
}

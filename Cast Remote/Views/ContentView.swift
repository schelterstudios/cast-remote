//
//  ContentView.swift
//  Cast Remote
//
//  Created by Steve Schelter on 7/29/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection){
            CastableListView()
                .environmentObject(CastableListViewModel(title: "Cast Remote", group: ProviderGroup.pinned)
                    .eraseToAnyViewModel())
                .tabItem {
                    VStack {
                        Image(systemName: "tv.fill")
                            .imageScale(.large)
                        Text("Cast Remote")
                    }
                }.tag(0)
            ProviderGroupView()
                .environmentObject(ProviderGroupViewModel(title: "Watchlist", group: ProviderGroup.pinned)
                    .eraseToAnyViewModel())
                .tabItem {
                    VStack {
                        Image(systemName: "eye.fill")
                            .imageScale(.large)
                        Text("Watchlist")
                    }
                }.tag(1)
        }
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

//
//  CastableListView.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import GoogleCast

struct CastableListState {
    var title: String
    var content: CastableListContent
}

enum CastableListContent {
    case preinit
    case loaded([CastableRowViewModel])
    case failed(Error)
}

enum CastableListInput {
    case reload(Bool)
    case toggle(CastableRowViewModel)
}

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

struct CastableListView: View {
    
    @EnvironmentObject var model: AnyViewModel<CastableListState, CastableListInput>
    
    // NOTE: - breaking out content due to ViewBuilder limitations
    private var castables: [CastableRowViewModel]? {
        if case let CastableListContent.loaded(castables) = model.state.content {
            return castables
        }
        return nil
    }
    private var error: Error? {
        if case let CastableListContent.failed(error) = model.state.content {
            return error
        }
        return nil
    }
    //
    
    var body: some View {
        NavigationView() {
            VStack {
                
                // loaded
                if castables != nil {
                    List {
                        ForEach(castables!) { castable in
                            CastableRow(model: castable)
                                .onTapGesture {
                                    self.model.trigger(.toggle(castable))
                                }
                        }
                    }
                    .listStyle(GroupedListStyle())
                
                // failed
                } else if error != nil {
                    FailureMessage(error: error)
                    
                // preinit
                } else {
                    Activity(description: "Loading Media")
                }
            }
            .navigationBarTitle(Text(model.state.title))
            .navigationBarItems(trailing: CastButton())
        }
        .onAppear{ self.model.trigger(.reload(true)) }
    }
}

fileprivate let previewPreinit = CastableListState(title: "Cast Remote",
                                                   content: .preinit)

fileprivate let previewLoaded = CastableListState(title: "Cast Remote",
                                                  content: CastableListContent.loaded(DemoJSON()
                                                    .twitchStreams.map{ CastableRowViewModel(demoDTO: $0, index: 0) }))

fileprivate let previewFailed = CastableListState(title: "Cast Remote",
                                                  content: .failed(NSError(domain: "", code: 0, userInfo: nil)))

struct CastableListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CastableListView()
                .environmentObject(JustViewState<CastableListState, CastableListInput>(state: previewPreinit)
                    .eraseToAnyViewModel())
            
            CastableListView()
                .environmentObject(JustViewState<CastableListState, CastableListInput>(state: previewLoaded)
                    .eraseToAnyViewModel())
            
            CastableListView()
                .environmentObject(JustViewState<CastableListState, CastableListInput>(state: previewFailed)
                    .eraseToAnyViewModel())
        }
    }
}

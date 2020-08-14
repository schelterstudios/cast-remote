//
//  ProviderListView.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/9/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct ProviderListState {
    var title: String
    var themeColor: Color
    var content: ProviderListContent
}

enum ProviderListContent {
    case preinit
    case loaded([ProviderRowViewModel])
    case failed(Error)
}

enum ProviderListInput {
    case reload(Bool)
    case apply
}

struct ProviderListView: View {

    @Binding var isPresented: Bool
    @Binding var accentColor: Color
    @ObservedObject var model: AnyViewModel<ProviderListState, ProviderListInput>
    
    // NOTE: - breaking out content due too ViewBuilder limitations
    private var providers: [ProviderRowViewModel]? {
        if case let ProviderListContent.loaded(providers) = model.state.content {
            return providers
        }
        return nil
    }
    private var error: Error? {
        if case let ProviderListContent.failed(error) = model.state.content {
            return error
        }
        return nil
    }
    //
    
    var body: some View {
        VStack {
            
            // failed
            if error != nil {
                Text(error!.localizedDescription)
            
            // loaded
            } else if providers != nil {
                List {
                    ForEach(providers!) { provider in
                        ProviderRow(model: provider)
                            .onTapGesture {
                                provider.toggleSelect()
                                self.model.trigger(.reload(false))
                            }
                    }
                }
                .listStyle(GroupedListStyle())
                
            // preinit
            } else {
                Text("Loading...")
            }
        }
        .navigationBarTitle(Text(model.state.title))
        .navigationBarItems(trailing: Button(action: {
            self.model.trigger(.apply)
            self.isPresented = false
        }) {
            Text("Done")
        })
        //.accentColor(Color.orange)
        .onAppear{
            self.accentColor = self.model.state.themeColor
            self.model.trigger(.reload(true))
        }
    }
}

fileprivate let previewPreinit = ProviderListState(title: "Demo Providers", themeColor: Color.green, content: .preinit)
fileprivate let previewLoaded = ProviderListState(title: "Demo Providers", themeColor: Color.green,
                                                  content: ProviderListContent.loaded(DemoJSON().twitchChannels.map{
                                                    ProviderRowViewModel(demoDTO: $0) }))
fileprivate let previewFailed = ProviderListState(title: "Demo Providers", themeColor: Color.green,
                                                  content: .failed(NSError(domain: "ErrorDomain", code: 400, userInfo: nil)))

struct ProviderListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ProviderListView(isPresented: .constant(true), accentColor: .constant(Color.accentColor),
                                 model: JustViewState(state: previewPreinit).eraseToAnyViewModel())
            }
            NavigationView {
                ProviderListView(isPresented: .constant(true), accentColor: .constant(Color.accentColor),
                                 model: JustViewState(state: previewLoaded).eraseToAnyViewModel())
            }
            NavigationView {
                ProviderListView(isPresented: .constant(true), accentColor: .constant(Color.accentColor),
                                 model: JustViewState(state: previewFailed).eraseToAnyViewModel())
            }
        }
    }
}

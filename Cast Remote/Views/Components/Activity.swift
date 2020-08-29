//
//  Activity.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/24/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct Activity: View {
    
    @State var description: String = "Loading"
    
    @State private var animateWave1 = false
    @State private var animateWave2 = false
    @State private var animateWave3 = false
    @State private var animateBox = false

    var body: some View {
        VStack {
            ZStack {
                Path { path in
                    path.move(to: .init(x: 0, y: 2.5))
                    path.addLine(to: .init(x: 0, y: 1))
                    path.addQuadCurve(to: .init(x: 1, y: 0), control: .init(x: 0, y: 0))
                    path.addLine(to: .init(x: 9, y: 0))
                    path.addQuadCurve(to: .init(x: 10, y: 1), control: .init(x: 10, y: 0))
                    path.addLine(to: .init(x: 10, y: 9))
                    path.addQuadCurve(to: .init(x: 9, y: 10), control: .init(x: 10, y: 10))
                    path.addLine(to: .init(x: 7.5, y: 10))
                }
                .scale(9, anchor: .topLeading)
                .offset(x: animateBox ? 6 : 3, y: animateBox ? 6 : 9)
                .stroke(Color.accentColor, lineWidth: animateBox ? 12 : 6)
                
                Path { path in
                    path.move(to: .init(x: 0, y: 3.75))
                    path.addCurve(to: .init(x: 6.25, y: 10), control1: .init(x: 3.5, y: 3.75), control2: .init(x: 6.25, y: 6.5))
                }
                .scale(animateWave3 ? 9 : 8, anchor: .topLeading)
                .offset(x: 0, y: animateWave3 ? 12 : 22)
                .stroke(Color.accentColor, lineWidth: animateWave3 ? 12 : 6)
                
                Path { path in
                    path.move(to: .init(x: 0, y: 6.25))
                    path.addCurve(to: .init(x: 3.75, y: 10), control1: .init(x: 2, y: 6.25), control2: .init(x: 3.75, y: 8))
                }
                .scale(animateWave2 ? 9 : 7, anchor: .topLeading)
                .offset(x: 0, y: animateWave2 ? 12 : 32)
                .stroke(Color.accentColor, lineWidth: animateWave2 ? 12 : 6)
                
                Path { path in
                    path.move(to: .init(x: 0, y: 10))
                    path.addLine(to: .init(x: 0, y: 8))
                    path.addQuadCurve(to: .init(x: 2, y: 10), control: .init(x: 2, y: 8))
                }
                .scale(animateWave1 ? 9 : 4.5, anchor: .topLeading)
                .offset(x: 0, y: animateWave1 ? 14 : 56)
                .fill(Color.accentColor)
            }
            .frame(width: 102, height: 102)
            
            Text(description)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
        }
        .onAppear{
            withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                self.animateWave1.toggle()
            }
            
            withAnimation(Animation.easeInOut(duration: 1).repeatForever().delay(0.2)) {
                self.animateWave2.toggle()
            }
            
            withAnimation(Animation.easeInOut(duration: 1).repeatForever().delay(0.4)) {
                self.animateWave3.toggle()
            }
            withAnimation(Animation.easeIn(duration: 1).repeatForever(autoreverses: true).delay(0.6)) {
                self.animateBox.toggle()
            }
        }
    }
}

struct Activity_Previews: PreviewProvider {
    static var previews: some View {
        Activity().previewLayout(.fixed(width: 102, height: 132))
    }
}

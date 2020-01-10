//
//  ContentView.swift
//  LockPerformanceSwift
//
//  Created by g on 2019/12/30.
//  Copyright © 2019 g. All rights reserved.
//

import SwiftUI


//优化 你的技术专长
//有效 收益 目标是什么

struct CountGroup:Codable,Hashable,Identifiable {
    var id = UUID()
    var count: Int
}

struct ButtonView: View {
    public var cg:CountGroup
    var body: some View {
        Button(action: {
            let c = self.cg.count
            LockTest.default.totalTest(UInt(c))
        }) {
            Text("Run (\(self.cg.count))")
            .font(.system(size: 20))
            .foregroundColor(.primary)
            
        }.frame(width: 200, height: 30, alignment: Alignment.leading)
    }
}


struct ContentView: View {
    let countGroups :[CountGroup] = [
        CountGroup( count: 1000),
        CountGroup( count: 10000),
        CountGroup( count: 100000),
        CountGroup( count: 1000000)
    ]
    var body: some View {
        VStack {
            ForEach(countGroups,id: \.id) { item in
                ButtonView(cg: item).padding(.bottom, 20.0)
            }
         
        }.position(x: 200, y: 200)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class Refresher {
    @objc class func injected() {
        UIApplication.shared.windows.first?.rootViewController =
            UIHostingController(rootView: ContentView())
    }
}


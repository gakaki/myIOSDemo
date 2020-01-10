//
//  ContentView.swift
//  simdZippyJSONBenchmark
//
//  Created by g on 2020/1/2.
//  Copyright © 2020 g. All rights reserved.
//

import SwiftUI
import ZippyJSON

func testBlock(_ testName:String, count:Int = 1000,  closure:@escaping () -> Void ) -> String {
    let begin:TimeInterval = CACurrentMediaTime()
    for _ in 0..<count {
        closure()
    }
    
    let end:TimeInterval = CACurrentMediaTime()
    let time_diff = (end-begin) * 1000
    let str = String(format:"%@ : %.2f ms",testName, time_diff)
    print(str)
    return str
}
func printdata()  {
    let path = Bundle.main.path(forResource: "tweets", ofType: "json")
    let url = URL(fileURLWithPath: path!)
    // 带throws的方法需要抛异常
    do {
        let data      = try? Data(contentsOf: url)

        let iterator_count = 1000
        DispatchQueue.global().async {
           testBlock("simd json decode", count: iterator_count,closure: {
               let _  = try? ZippyJSONDecoder().decode(Tweets.self, from: data!)
           })
        }
        DispatchQueue.global().async {
             testBlock("apple json decode", count: iterator_count,closure: {
                let _   = try? JSONDecoder().decode(Tweets.self, from: data!)
            })
        }
       
        
    } catch let error {
        print("读取本地数据出现错误!",error)
    }

}

struct ContentView: View {
    
    @State var labelText = ""
    var body: some View {
        VStack{
            Button(action: {
                printdata()
            }) {
                Text("simd json vs apple json decode")
            }
            Text(labelText)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

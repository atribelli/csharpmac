//
//  ContentView.swift
//  CSharp
//

import SwiftUI

typealias opFunc = @convention(c) (CInt) -> CInt

let handle   = dlopen("../Resources/CSharpLib.dylib", RTLD_NOW) // Local to executable
let symbol   = dlsym(handle, "OperationsSquare")                // The C# entry point
let opSquare = unsafeBitCast(symbol, to: opFunc.self)           // Function to call
let value    = 5                                                // Value to square
let result   = String(opSquare(CInt(value)));                   // String to display

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("The square of \(value) is \(result)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

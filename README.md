# csharpmac

Using C# code with Swift on macOS.  

It is necessary to install .NET. See:
https://learn.microsoft.com/en-us/dotnet/core/install/macos

Swift code cannot call C# code; it can call Objective-C code. It is possible to create an Objective-C bridging header and wrapper around C/C++ code. This C/C++ code can then call C# code that has been compiled ahead-of-time (AOT) and where callable functions have specially defined unmanaged code entry points. This native compiled C# code will be in a dynamic library built outside of Xcode using .NET console tools.  

However, since we have a normal dynamic library, we have a simpler option. Swift can load this library and determine the unmanaged code entry point for a desired function. "Unmanaged code" is C# terminology; in Swift, it is called "unsafe code". "Unsafe" is a bit of a misnomer. "Unmanaged" and "unsafe" are noting that the C# and Swift languages have more built-in defensive programming to help spot and avoid bugs. The C language, and to a lesser degree, the C++ and Objective-C languages, leave such defensive programming to the programmer.  

This project will use the Swift manual loading a dynamic library approach. If you would like to see an example of a bridging header and wrapper, take a look at the asmmobile project.  


# C# Dynmic Library

The C# dynamic library CSharpLib was created using .NET console tools.  

```
dotnet new classlib -o CSharpLib --force
```

In the CSharpLib subfolder the file CSharpLib.csproj needs to have the following lines added to the "PropertyGroup" group.  
```
    <PublishAot>true</PublishAot>
    <PublishAotUsingRuntimePack>true</PublishAotUsingRuntimePack>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
```

The file Class1.cs should be renamed Operations.cs. It's contents should be changed to the following.  
```
using System.Runtime.InteropServices;

namespace CSharpLib;

public static class Operations {
    [UnmanagedCallersOnly(EntryPoint = "OperationsSquare")]
    public static unsafe int Square(int value) {
        return value * value;
    }
}
```

Create CSharp.h.  
```
#ifdef __cplusplus
extern "C" {
#endif
    int OperationsSquare(int value);
#ifdef __cplusplus
}
#endif
```

Create Test.cpp.  
```
#include <iostream>

#include "CSharp.h"

using namespace std;

int main(void) {
    cout << "Square(5) = " << OperationsSquare(5) << endl;

    return 0;
}
```

Create makefile.  
```
platform := $(shell uname -m)

ifeq ($(platform), x86_64)
target  = osx-x64
else ifeq ($(platform), arm64)
target  = osx-arm64
endif

all: test

test: CSharp.h Test.cpp publish/CSharpLib.dylib
    clang++ -o test Test.cpp publish/CSharpLib.dylib

publish/CSharpLib.dylib: Operations.cs
    dotnet publish -c Release -r $(target) -o ./publish /p:NativeLib=Shared --self-contained

clean:
    rm -fr test a.out bin obj/Release publish
```

To build the library execute the make utility  
```
make
```

Test the library with the test utility.  
```
./test
```

# macOS application

The Mac application project CSharp was created using Xcode. Using a macOS app template, swift language, and swiftui interface.  

Before attempting to build the Mac app in Xcode, use the macOS Terminal app to run the make utility from the csharpmac/CSharpLib subfolder as shown above.  

How the macOS project was created:  
- Created the CSharp project using a macOS app template, swift language, and swiftui interface.  
- Added CSharpLib.dylib to the project build phase "Copy Bunde Resources".  
- Updated ContentView.swift to open the library and call C# code. The following Swift code was added:
```
typealias opFunc = @convention(c) (CInt) -> CInt

let handle   = dlopen("../Resources/CSharpLib.dylib", RTLD_NOW) // Local to executable
let symbol   = dlsym(handle, "OperationsSquare")                // The C# entry point
let opSquare = unsafeBitCast(symbol, to: opFunc.self)           // Function to call
let value    = 5                                                // Value to square
let result   = String(opSquare(CInt(value)));                   // String to display
```

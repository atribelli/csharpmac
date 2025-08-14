platform := $(shell uname -m)
kernel   := $(shell uname -s)

ifeq ($(kernel), Darwin)

ifeq ($(platform), x86_64)
target  = osx-x64
else ifeq ($(platform), arm64)
target  = osx-arm64
endif

else ifeq ($(kernel), Linux)

ifeq ($(platform), x86_64)
target  = linux-x64
else ifeq ($(platform), arm64)
target  = linux-arm64
endif

endif   # Linux, Darwin

all: test

test: CSharp.h Test.cpp publish/CSharpLib.dylib
	clang++ -o test Test.cpp publish/CSharpLib.dylib

publish/CSharpLib.dylib: Operations.cs
	dotnet publish -c Release -r $(target) -o ./publish /p:NativeLib=Shared --self-contained

clean:
	rm -fr test a.out bin obj/Release publish


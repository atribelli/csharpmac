using System.Runtime.InteropServices;

namespace CSharpLib;

public static class Operations {
    [UnmanagedCallersOnly(EntryPoint = "OperationsSquare")]
    public static unsafe int Square(int value) {
        return value * value;
    }
}


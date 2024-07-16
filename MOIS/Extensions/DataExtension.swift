import Foundation

extension Data {
    var dataToHexString: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    var firstTwoBytesAsUInt16: UInt16? {
        guard count >= 2 else { return nil }
        return self.prefix(2).withUnsafeBytes { $0.load(as: UInt16.self) }
    }
}

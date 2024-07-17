import Foundation

let companyIdentifiers: [UInt16: String] = [
    0x0006: "Microsoft",
    0x0008: "Motorola",
    0x0078: "Nike, Inc.",
    0x00C4: "LG Electronics",
    0x004C: "Apple, Inc.",
    0x000F: "Broadcom Corporation",
    0x001A: "Qualcomm",
    0x0059: "Nordic Semiconductor ASA",
    0x0075: "Samsung Electronics Co. Ltd."
]

let memberServices: [UInt16: String] = [
    0xFCA0: "Apple Inc.",
    0xFCB1: "Google LLC",
    0xFCB2: "Apple Inc.",
    0xFCC0: "Xiaomi Inc.",
    0xFCCF: "Google LLC",
    0xFCE1: "Sony Group Corporation",
    0xFCF1: "Google LLC",
    0xFD1D: "Samsung Electronics Co., Ltd",
    0xFD31: "LG Electronics Inc.",
    0xFD36: "Google LLC",
    0xFD43: "Apple Inc.",
    0xFD44: "Apple Inc.",
    0xFD59: "Samsung Electronics Co., Ltd",
    0xFD5A: "Samsung Electronics Co., Ltd",
    0xFD6C: "Samsung Electronics Co., Ltd",
    0xFD6F: "Apple Inc.",
    0xFD7E: "Samsung Electronics Co., Ltd",
    0xFD82: "Sony Group Corporation",
    0xFD87: "Google LLC",
    0xFD8C: "Google LLC",
    0xFD96: "Google LLC",
    0xFDDB: "Samsung Electronics Co., Ltd",
    0xFDE2: "Samsung Electronics Co., Ltd",
    0xFDF0: "Samsung Electronics Co., Ltd",
    0xFE13: "Apple Inc.",
    0xFE19: "Google LLC",
    0xFE26: "Google LLC",
    0xFE27: "Google LLC",
    0xFE2C: "Google LLC",
    0xFE8A: "Apple Inc.",
    0xFE8B: "Apple Inc.",
    0xFE9F: "Google LLC",
    0xFEA0: "Google LLC",
    0xFEAA: "Google LLC",
    0xFEB2: "Microsoft Corporation",
    0xFEB9: "LG Electronics",
    0xFEC7: "Apple Inc.",
    0xFEC8: "Apple Inc.",
    0xFEC9: "Apple Inc.",
    0xFECA: "Apple Inc.",
    0xFECB: "Apple Inc.",
    0xFECC: "Apple Inc.",
    0xFECD: "Apple Inc.",
    0xFECE: "Apple Inc.",
    0xFECF: "Apple Inc.",
    0xFED0: "Apple Inc.",
    0xFED1: "Apple Inc.",
    0xFED2: "Apple Inc.",
    0xFED3: "Apple Inc.",
    0xFED4: "Apple Inc.",
    0xFED8: "Google LLC",
    0xFEF3: "Google LLC",
    0xFEF4: "Google LLC"
]

func hexStringToUInt16(hexString: String) -> UInt16? {
    guard hexString.count > 0 && hexString.count <= 4 else { return nil }
    
    var result: UInt32 = 0
    let scanner = Scanner(string: hexString)
    if scanner.scanHexInt32(&result) {
        return UInt16(result)
    }
    
    return nil
}

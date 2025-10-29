//
//  UTType+Audio.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import UniformTypeIdentifiers

extension UTType {
    static var mp3: UTType {
        UTType(filenameExtension: "mp3") ?? .audio
    }

    static var wav: UTType {
        UTType(filenameExtension: "wav") ?? .audio
    }
}

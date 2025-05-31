//
// PreviewProvider.swift
// implementation of PreviewProvider class.
// this is to provide the QuickLook Extension.
//
// Copyright (C) 2025 KAENRYUU Koutoku.
//

import QuickLookUI

class PreviewProvider: QLPreviewProvider {
    func providePreview(for request: QLFilePreviewRequest,
                        completionHandler: @escaping (QLPreviewReply?, Error?) -> Void) {

        // merely convert `.poco` to `.png` intact, because PoCoPicture meets PNG specification.
        let tempDir = FileManager.default.temporaryDirectory
        let tempPNGURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")

        do {
            try FileManager.default.copyItem(at: request.fileURL, to: tempPNGURL)
            let reply = QLPreviewReply(fileURL: tempPNGURL)
            completionHandler(reply, nil)
        } catch {
            completionHandler(nil, error)
        }
    }
}

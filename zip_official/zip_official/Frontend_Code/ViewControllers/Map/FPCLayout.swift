//
//  FPCLayout.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 11/15/21.
//

import Foundation
import FloatingPanel


class ZipFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 180.0, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 50.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}

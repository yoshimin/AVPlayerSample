//
//  CMTime+Validation.swift
//  PlayerSample
//
//  Created by Shingai Yoshimi on 9/17/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

import AVFoundation

extension CMTime {
    var isValid:Bool {
        return (flags & .Valid) != nil
    }
}

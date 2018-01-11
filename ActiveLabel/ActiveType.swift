//
//  ActiveType.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation

enum ActiveElement {
    case mention(String)
    case hashtag(String)
    case url(original: String, trimmed: String)
    case custom(String)
    case range(String)

    static func create(with activeType: ActiveType, text: String) -> ActiveElement {
        switch activeType {
        case .mention: return mention(text)
        case .hashtag: return hashtag(text)
        case .url: return url(original: text, trimmed: text)
        case .custom: return custom(text)
        case .range(_, let id): return range(id)
        }
    }
}

public enum ActiveType {
    case mention
    case hashtag
    case url
    case custom(pattern: String)
    case range(NSRange, id: String)

    var pattern: String? {
        switch self {
        case .mention: return RegexParser.mentionPattern
        case .hashtag: return RegexParser.hashtagPattern
        case .url: return RegexParser.urlPattern
        case .custom(let regex): return regex
        case .range: return nil
        }
    }

    var range: NSRange? {
        switch self {
        case .range(let range, _):
            return range
        default:
            return nil
        }
    }
}

extension ActiveType: Hashable, Equatable {
    public var hashValue: Int {
        switch self {
        case .mention: return -1
        case .hashtag: return -2
        case .url: return -3
        case .custom(let regex): return regex.hashValue
        case .range(_, let id): return id.hashValue
        }
    }
}

public func ==(lhs: ActiveType, rhs: ActiveType) -> Bool {
    switch (lhs, rhs) {
    case (.mention, .mention): return true
    case (.hashtag, .hashtag): return true
    case (.url, .url): return true
    case (.custom(let pattern1), .custom(let pattern2)): return pattern1 == pattern2
    case (let .range(range1, id1), let .range(range2, id2)): return range1 == range2 && id1 == id2
    default: return false
    }
}

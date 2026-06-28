import CoreGraphics

/// Spacing scale — mirrors CSS --space-* tokens (1rem = 16pt)
enum Spacing {
    static let s1:  CGFloat =  4
    static let s2:  CGFloat =  8
    static let s3:  CGFloat = 12
    static let s4:  CGFloat = 16
    static let s5:  CGFloat = 20
    static let s6:  CGFloat = 24
    static let s8:  CGFloat = 32
    static let s10: CGFloat = 40
    static let s12: CGFloat = 48
    static let s16: CGFloat = 64
}

/// Corner radius scale — mirrors CSS --radius-* tokens
enum Radius {
    static let sm:   CGFloat =  6
    static let md:   CGFloat =  8
    static let lg:   CGFloat = 12
    static let xl:   CGFloat = 16
    static let full: CGFloat = 9999
}

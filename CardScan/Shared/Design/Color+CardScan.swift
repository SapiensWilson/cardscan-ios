import SwiftUI

extension Color {

    // MARK: — Background
    static let csBg      = Color("csBg")       // #f7f6f2 / #171614
    static let csSurface = Color("csSurface")  // #f9f8f5 / #1c1b19
    static let csSurface2 = Color("csSurface2") // #ffffff / #201f1d
    static let csSurfaceOffset  = Color("csSurfaceOffset")  // #f0ede8 / #1d1c1a
    static let csSurfaceDynamic = Color("csSurfaceDynamic") // #e6e4df / #2d2c2a

    // MARK: — Borders & dividers
    static let csDivider = Color("csDivider") // #dcd9d5 / #262523
    static let csBorder  = Color("csBorder")  // #d4d1ca / #393836

    // MARK: — Text
    static let csText       = Color("csText")      // #28251d / #cdccca
    static let csTextMuted  = Color("csTextMuted") // #7a7974 / #797876
    static let csTextFaint  = Color("csTextFaint") // #bab9b4 / #5a5957
    static let csTextInverse = Color("csTextInverse") // #f9f8f4 / #2b2a28

    // MARK: — Primary (teal)
    static let csGreen          = Color("csGreen")          // #01696f / #4f98a3
    static let csGreenHover     = Color("csGreenHover")     // #0c4e54 / #227f8b
    static let csGreenActive    = Color("csGreenActive")    // #0f3638 / #1a626b
    static let csGreenHighlight = Color("csGreenHighlight") // #cedcd8 / #313b3b

    // MARK: — Success
    static let csSuccess          = Color("csSuccess")          // #437a22 / #6daa45
    static let csSuccessHover     = Color("csSuccessHover")     // #2e5c10 / #4d8f25
    static let csSuccessHighlight = Color("csSuccessHighlight") // #d4dfcc / #3a4435
}

/*
 SETUP: In Xcode, open Assets.xcassets and create one Color Set per name above.
 Set "Appearances" to "Any, Dark" and enter the hex values from DESIGN.md.

 Quick reference (Light / Dark):
   csBg              #f7f6f2 / #171614
   csSurface         #f9f8f5 / #1c1b19
   csSurface2        #ffffff / #201f1d
   csSurfaceOffset   #f0ede8 / #1d1c1a
   csSurfaceDynamic  #e6e4df / #2d2c2a
   csDivider         #dcd9d5 / #262523
   csBorder          #d4d1ca / #393836
   csText            #28251d / #cdccca
   csTextMuted       #7a7974 / #797876
   csTextFaint       #bab9b4 / #5a5957
   csTextInverse     #f9f8f4 / #2b2a28
   csGreen           #01696f / #4f98a3
   csGreenHover      #0c4e54 / #227f8b
   csGreenActive     #0f3638 / #1a626b
   csGreenHighlight  #cedcd8 / #313b3b
   csSuccess         #437a22 / #6daa45
   csSuccessHover    #2e5c10 / #4d8f25
   csSuccessHighlight #d4dfcc / #3a4435
*/

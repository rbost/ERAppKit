//
//  ERGlobals.h
//  ERAppKit
//
//  Created by Raphael Bost on 05/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#ifndef ERAppKit_ERGlobals_h
#define ERAppKit_ERGlobals_h

/**
 \file ERGlobals.h 
 \brief Shared constants and globals.
 */

/**
 \enum ERMenuStyle
 \brief Available menu styles for ERMenu
 */
typedef enum{
    ERDefaultMenuStyle = -1,    /**< The default menu style, ERCenteredMenuStyle for now */
    ERCenteredMenuStyle = 0,    /**< Menu items all around the center button */
    ERUpperMenuStyle = 1,       /**< Menu items only on the upper part of the center button */
    EREmptyQuarterMenuStyle = 2 /**< Menu items all around the center button but on the down quarter */
}ERMenuStyle;

#endif

//
//  RADownloadButton.h
//  RADownloadButton
//
//  Created by hongy on 05/12/2017.
//  Copyright © 2017 hongyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RADownloadButton : UIButton

@property (nullable, nonatomic, copy) UIColor *normalBackgroundColor;
@property (nullable, nonatomic, copy) UIColor *highlightedBackgroundColor;
@property (nonatomic) float progress;
@property (copy) void (^ _Nullable buttonAction)(void);

@end

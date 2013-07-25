//
//  DAOverlayView.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/25/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DAOverlayView;

@protocol DAOverlayViewDelegate <NSObject>

- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end


@interface DAOverlayView : UIView

@property (weak, nonatomic) id<DAOverlayViewDelegate> delegate;

@end

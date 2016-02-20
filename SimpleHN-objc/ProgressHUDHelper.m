//
//  ProgressHUDHelper.m
//  FODMAP
//
//  Created by James Eunson on 26/06/12.
//  Copyright (c) 2012 JEON. All rights reserved.
//

#import "ProgressHUDHelper.h"

@implementation ProgressHUDHelper

static NSTimeInterval kHudHideDelay = 2.0f;

+ (void)showConfirmationHUDWithImage:(UIImage*)image withLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText withHideDelay:(NSTimeInterval)hideDelay {
    [[self class] showConfirmationHUDWithImage:image withLabelText:labelText withDetailsLabelText:detailsLabelText withHideDelay:hideDelay inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showConfirmationHUDWithImage:(UIImage*)image withLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText {
    [[self class] showConfirmationHUDWithImage:image withLabelText:labelText withDetailsLabelText:detailsLabelText withHideDelay:kHudHideDelay inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showConfirmationHUDWithImage:(UIImage*)image withLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText withHideDelay:(NSTimeInterval)hideDelay inView:(UIView*)view {
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:view];
    
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.mode = MBProgressHUDModeCustomView;
    hud.userInteractionEnabled = NO;
    
    [view addSubview:hud];
    
    hud.labelText = labelText;
    hud.detailsLabelText = detailsLabelText;
    [hud show:YES];
    [hud hide:YES afterDelay:hideDelay];
}

+ (MBProgressHUD*)showLoadingHUDWithLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText {
    
    UIView * targetView = [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:targetView];
	hud.mode = MBProgressHUDModeIndeterminate;
    hud.userInteractionEnabled = NO;    
    [targetView addSubview:hud];
    
    hud.labelText = labelText;
    hud.detailsLabelText = detailsLabelText;
    [hud show:YES];
    return hud;
}

+ (MBProgressHUD*)showLoadingHUDWithLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText inView:(UIView *)view {
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:view];
	hud.mode = MBProgressHUDModeIndeterminate;
    hud.userInteractionEnabled = NO;
    [view addSubview:hud];
    
    hud.labelText = labelText;
    hud.detailsLabelText = detailsLabelText;
    [hud show:YES];
    return hud;
}

+ (MBProgressHUD*)showDeterminateLoadingHUDWithLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText {
    
    MBProgressHUD * hud = [[self class] showLoadingHUDWithLabelText:labelText withDetailsLabelText:detailsLabelText];
    
	hud.mode = MBProgressHUDModeDeterminate;
    hud.progress = 0;
    hud.userInteractionEnabled = NO;    
    
    return hud;
}

@end

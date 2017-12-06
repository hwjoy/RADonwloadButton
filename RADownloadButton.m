//
//  RADownloadButton.m
//  RADownloadButton
//
//  Created by hongy on 05/12/2017.
//  Copyright © 2017 hongyu. All rights reserved.
//

#import "RADownloadButton.h"

typedef NS_ENUM(NSInteger, ActionState) {
    ActionStateIdle,
    ActionStateDownloading,
    ActionStateDownloaded,
    ActionStateFileOpened,
};

@interface RADownloadButton()

@property (nonatomic) ActionState actionState;
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic, copy) NSString *normalTitle;

@end

@implementation RADownloadButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.f;
        
        self.backgroundColor = [UIColor blackColor];
        self.normalBackgroundColor = [UIColor blackColor];
        self.highlightedBackgroundColor = [UIColor grayColor];
        
        self.normalTitle = @"Download";
        [self setTitle:self.normalTitle forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [self addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.actionState = ActionStateIdle;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (self.actionState == ActionStateDownloading) {
        return;
    }
    
    if (highlighted || self.actionState == ActionStateDownloading) {
        self.backgroundColor = self.highlightedBackgroundColor;
    } else if (self.actionState != ActionStateFileOpened) {
        self.backgroundColor = self.normalBackgroundColor;
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    
    if (state == UIControlStateNormal && title != nil && self.actionState != ActionStateDownloading) {
        self.normalTitle = title;
    }
}

- (void)setProgress:(float)progress {
    if (self.progressView == nil) {
        return;
    }
    if (_progress == progress) {
        return;
    }
    
    _progress = progress;
    [self.progressView setProgress:progress animated:YES];
    
    if (progress >= 1.f) {
        if (self.actionState == ActionStateDownloading) {
            [UIView animateWithDuration:0.5f delay:0.5f options:0 animations:^{
                self.progressView.transform = CGAffineTransformMakeScale(0.5f, 1.f);
            } completion:^(BOOL finished) {
                self.transform = CGAffineTransformMakeScale(1.f, 1.f);
                self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.bounds) / 2, 0);
                [self setTitle:@"Open File" forState:UIControlStateNormal];
                [self setTitleColor:self.normalBackgroundColor forState:UIControlStateNormal];
                self.actionState = ActionStateDownloaded;
            }];
        }
    }
}

- (void)startAction {
    if (self.actionState == ActionStateIdle) {
        self.actionState = ActionStateDownloading;
        
        [self setTitle:nil forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5f animations:^{
            self.transform = CGAffineTransformMakeScale(1.f, 4 / CGRectGetHeight(self.frame));
        } completion:^(BOOL finished) {
            self.backgroundColor = [UIColor clearColor];
            self.transform = CGAffineTransformMakeScale(1.f, 1.f);
            
            UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) / 2, CGRectGetWidth(self.frame), 1.f)];
            progressView.tag = 1000;
            progressView.transform = CGAffineTransformMakeScale(1.f, 4 / CGRectGetHeight(progressView.frame));
            progressView.progressTintColor = self.normalBackgroundColor;
            progressView.trackTintColor = self.highlightedBackgroundColor;
            [self addSubview:progressView];
            self.progressView = progressView;
            
            [self performSelector:@selector(continueAction) withObject:nil afterDelay:0.1f];
        }];
    } else if (self.actionState == ActionStateDownloading || self.actionState == ActionStateFileOpened) {
        [[self viewWithTag:1000] removeFromSuperview];
        self.transform = CGAffineTransformMakeScale(1.f, 4 / CGRectGetHeight(self.frame));
        self.backgroundColor = self.highlightedBackgroundColor;
        [UIView animateWithDuration:0.5f animations:^{
            self.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.backgroundColor = self.normalBackgroundColor;
        } completion:^(BOOL finished) {
            [self setTitle:self.normalTitle forState:UIControlStateNormal];
            self.progress = 0;
            self.actionState = ActionStateIdle;
        }];
    } else if (self.actionState == ActionStateDownloaded) {
        self.actionState = ActionStateFileOpened;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"File Opened" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:^{
            self.actionState = ActionStateIdle;
            [[self viewWithTag:1000] removeFromSuperview];
            [self setTitle:nil forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5f animations:^{
                self.backgroundColor = self.normalBackgroundColor;
            } completion:^(BOOL finished) {
                self.titleEdgeInsets = UIEdgeInsetsZero;
                [self setTitle:self.normalTitle forState:UIControlStateNormal];
                [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }];
        }];
    }
}

- (void)continueAction {
    if (self.buttonAction) {
        self.buttonAction();
    }
}

@end

//
//  ViewController.m
//  RadialPlayback
//
//  Created by Jordan Focht on 3/5/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

#import "ViewController.h"
#import "MiniPlaybackButton.h"

@interface ViewController () {
    CFTimeInterval startLoadTime;
    CADisplayLink* progressLink;
}

@property (weak, nonatomic) IBOutlet MiniPlaybackButton *radialButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)touchUpInsidePlayButton:(UIButton *)sender {
    self.radialButton.loading = sender.selected;
    self.radialButton.value = self.radialButton.minimumValue;
    [progressLink invalidate];
    if (self.radialButton.loading) {
        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
        dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
            self.radialButton.loading = false;
            startLoadTime = DBL_MAX;
            progressLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress:)];
            [progressLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        });
    }
}

-(void)updateProgress:(CADisplayLink*)link {
    if (startLoadTime == DBL_MAX) {
        startLoadTime = link.timestamp;
        self.radialButton.minimumValue = startLoadTime;
        self.radialButton.maximumValue = startLoadTime + 10;
    }
    if (link.timestamp - startLoadTime > 10) {
        [link invalidate];
        progressLink = nil;
    }
    self.radialButton.value = link.timestamp;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

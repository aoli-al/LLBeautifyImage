//
//  ViewController.m
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import "ViewController.h"
#import "BeautifyImage.h"

@interface ViewController ()

@property (retain, nonatomic) BeautifyImage * manager;
@property (strong, nonatomic) UISlider * slider;
@property (strong, nonatomic) UISlider * sslider;

@end

@implementation ViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _slider = [[UISlider alloc] init];
        _sslider = [[UISlider alloc] init];
    }
    return self;
}

-(void)loadView {
    [super loadView];
    [self.view addSubview:_imageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * image = [UIImage imageNamed:@"test.png"];
    _manager = [[BeautifyImage alloc] initWithImage:image];
    
    UIImage * new = [_manager imageProcessingWithDeviation:10.0 spatial:0.02];
    
    [_imageView setImage:new];
    _imageView.frame = self.view.frame;
    
    _slider.frame = CGRectMake(30, 30, 300, 60);
    _slider.value = 1;
    _slider.minimumValue = 0;
    _slider.maximumValue = 100;
    [_slider addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
    
    
    _sslider.frame = CGRectMake(30, 80, 300, 60);
    _sslider.value = 0.5;
    _sslider.minimumValue = 0;
    _sslider.maximumValue = 1;
    [_sslider addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_slider];
    [self.view addSubview:_sslider];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)getValue1:(id)sender {
    static bool flag = false;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.pic.leo", NULL);
    if (! flag) {
        dispatch_async(backgroundQueue, ^{
            flag = true;
            UIImage * new = [_manager imageProcessingWithDeviation:_slider.value spatial:_sslider.value];
            dispatch_async(dispatch_get_main_queue(), ^{
                flag = false;
                NSLog(@"%lf", _slider.value);
                [_imageView setImage:new];
                [_imageView setNeedsDisplay];
            });
        });
    }
}

- (void)getValue2:(id)sender {
    UISlider * slider = (UISlider *) sender;
    UIImage * new = [_manager imageProcessingWithDeviation:_slider.value spatial:slider.value];
    [_imageView setImage:new];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  InputTextViewDemo
//
//  Created by John on 2017/4/28.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "ViewController.h"
#import "InputTextView.h"

@interface ViewController () <UITextViewDelegate, UIGestureRecognizerDelegate, InputTextViewDelegate>

@property (nonatomic, weak) InputTextView *inputTextView;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createInputView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)userDidTakeScreenshot:(NSNotification *)nf {
    
    
}

- (void)createInputView {
    InputTextView *inputView = [[InputTextView alloc] initWithFrame:CGRectMake(10, 20, self.view.frame.size.width - 20, 300)];
    inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    inputView.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
    inputView.placeHolderText = @"please input your text!~";
    
    inputView.attachmentDelegate = self;
    
//    inputView.allowsEditingTextAttributes = YES;
    self.inputTextView = inputView;
    [self.view addSubview:inputView];
    
    UIButton *seletedPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    seletedPhotoButton.frame = CGRectMake((self.view.frame.size.width - 30) / 2, inputView.frame.origin.y + inputView.frame.size.height + 20, 50, 44);
    [seletedPhotoButton setTitle:@"Photo" forState:UIControlStateNormal];
    [seletedPhotoButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [seletedPhotoButton addTarget:self action:@selector(selectedPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:seletedPhotoButton];
}


- (void)becomeEdit:(UIGestureRecognizer *)gz {
    UITextView *textView = (UITextView *)gz.view;
    CGPoint tapLocation = [gz locationInView:textView];
    UITextPosition *textPosition = [textView closestPositionToPoint:tapLocation];
    NSDictionary *attributes = [textView textStylingAtPosition:textPosition inDirection:UITextStorageDirectionForward];
    NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
    
    if (attachment) {
        [self didSeletedImage:attachment.image];
    
    } else {
        
        textView.editable = YES;
        [textView becomeFirstResponder];
    }
}

- (void)didSeletedImage:(UIImage *)image {

    
}

- (void)selectedPhoto {
    [self.view  endEditing:YES];

    DYMAttachmentInfo *info = [[DYMAttachmentInfo alloc] init];
    info.identifire = @"1";
    info.image = [UIImage imageNamed:@"1.jpeg"];
    info.bounds = CGRectMake(0, 0, info.image.size.width, info.image.size.height);
    
    [self.inputTextView addAttachmentInfo:info];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark 

- (void)inputTextView:(InputTextView *)inputTextView didSeletedAttachmentInfo:(DYMAttachmentInfo *)attachmentInfo {
    
    NSLog(@"click attachment");
    
}

- (void)inputTextViewMaximumRemind:(InputTextView *)inputTextView {

    NSLog(@"it is over the max");
}

@end

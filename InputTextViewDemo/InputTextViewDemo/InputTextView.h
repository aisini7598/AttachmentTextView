//
//  InputTextView.h
//  InputTextViewDemo
//
//  Created by John on 2017/4/28.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYMAttachmentInfo : NSObject

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *data;

@property (nonatomic) CGRect bounds;

@property (nonatomic, copy) NSString *identifire;

@end

@class InputTextView;

@protocol InputTextViewDelegate <NSObject>
//点击副本的事件
- (void)inputTextView:(InputTextView *)inputTextView didSeletedAttachmentInfo:(DYMAttachmentInfo *)attachmentInfo;
//超过最大副本数的回调
- (void)inputTextViewMaximumRemind:(InputTextView *)inputTextView;

@end

@interface InputTextView : UITextView

@property (nonatomic, copy) NSString *placeHolderText;
@property (nonatomic, copy) NSAttributedString *placeHolderAttributedString;
// 最大副本数，默认 == 10
@property (nonatomic) NSInteger maximumImageCount;

@property (nonatomic, weak) id <InputTextViewDelegate> attachmentDelegate;
@property (nonatomic, readonly) NSMutableArray *attachmentArray;

/**
 添加一个副本

 @param attachmentInfo 副本文件
 */
- (void)addAttachmentInfo:(DYMAttachmentInfo *)attachmentInfo;


/**
 替换一个副本

 @param newAttachmentInfo 新副本
 @param targetAttachmentInfo 原始副本
 */
- (void)replaceAttachmentInfo:(DYMAttachmentInfo *)newAttachmentInfo targetInfo:(DYMAttachmentInfo *)targetAttachmentInfo;

@end


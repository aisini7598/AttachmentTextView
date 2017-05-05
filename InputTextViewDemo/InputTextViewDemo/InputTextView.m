
//
//  InputTextView.m
//  InputTextViewDemo
//
//  Created by John on 2017/4/28.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "InputTextView.h"

@implementation DYMAttachmentInfo



@end


@interface DYMAttachment : NSTextAttachment

@property (nonatomic) DYMAttachmentInfo *info;

- (instancetype)initWithAttachmentInfo:(DYMAttachmentInfo *)info maxWidth:(CGFloat)width;

@end

@implementation DYMAttachment

- (instancetype)initWithAttachmentInfo:(DYMAttachmentInfo *)info maxWidth:(CGFloat)width {
    self = [super init];
    if (self) {
        _info = info;
        if (info.image) {
            self.image = info.image;
        }
        if (info.data) {
            self.contents = info.data;
        }
    }
    return self;
}


- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGFloat scale  = self.info.image.size.width / self.info.image.size.height;
    return CGRectMake(0, 0, (lineFrag.size.width - textContainer.lineFragmentPadding * 2), (lineFrag.size.width - textContainer.lineFragmentPadding * 2) / scale);
}


@end


@interface InputTextView () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSMutableArray *attachmentArray;
@property (nonatomic, weak) UILabel *placeHolderLabel;

@property (nonatomic) DYMAttachmentInfo *seletedInfo;


@end

@implementation InputTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configurationTextView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configurationTextView];
    }
    return self;
}

- (void)configurationTextView {
    self.delegate = self;
    
    _maximumImageCount = 2;
    _attachmentArray = [NSMutableArray array];
    self.font = [UIFont systemFontOfSize:14.0f];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 10;
    
    self.typingAttributes = @{
                              NSFontAttributeName : self.font,
                              NSParagraphStyleAttributeName : paragraph
                              };
    
    self.textContainerInset = UIEdgeInsetsMake(10, 10, 20, 10);
    
    UILabel *placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    placeHolderLabel.font = self.font;
    placeHolderLabel.backgroundColor = [UIColor clearColor];
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:placeHolderLabel];
    _placeHolderLabel = placeHolderLabel;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTextView:)];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.placeHolderLabel sizeToFit];
    self.placeHolderLabel.frame = CGRectMake(self.textContainerInset.left + 10 ,10, self.placeHolderLabel.bounds.size.width, self.placeHolderLabel.bounds.size.height);
}

- (void)setPlaceHolderText:(NSString *)placeHolderText {
    self.placeHolderLabel.text = placeHolderText;
    [self layoutSubviews];
}

- (void)setPlaceHolderAttributedString:(NSAttributedString *)placeHolderAttributedString {
    self.placeHolderLabel.attributedText = placeHolderAttributedString;
    [self layoutSubviews];
}

- (void)handleTextView:(UIGestureRecognizer *)gz {
    if (gz.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    CGPoint locationPoint = [gz locationInView:gz.view];
    
    DYMAttachmentInfo *info = [self attachmentInfoWithPoint:locationPoint];
    if (info) {
        self.seletedInfo = info;
        if (self.attachmentDelegate && [self.attachmentDelegate respondsToSelector:@selector(inputTextView:didSeletedAttachmentInfo:)]) {
            [self.attachmentDelegate inputTextView:self didSeletedAttachmentInfo:info];
        }
    } else {
        self.editable = YES;
        self.selectable = YES;
    }
}

#pragma gustureRecognized

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    CGPoint locationPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    DYMAttachmentInfo *info = [self attachmentInfoWithPoint:locationPoint];
    return info == nil;
}

- (BOOL)attachmentExistWithIdentifire:(NSString *)identifire {
    __block BOOL ret = NO;
    
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        DYMAttachment *attachment = (DYMAttachment *)value;
        if (attachment) {
            if ([attachment.info.identifire isEqualToString:identifire]) {
                ret = YES;
                *stop = YES;
            }
        }
    }];
    return ret;
}

- (CGRect)frameAttachmentWithIdentifire:(NSString *)identifire {
    __block CGRect frame = CGRectZero;
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        DYMAttachment *attachment = (DYMAttachment *)value;
        if (attachment) {
            
            if ([attachment.info.identifire isEqualToString:identifire]) {
                frame = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
                frame.origin.x += self.textContainerInset.left;
                frame.origin.y += self.textContainerInset.top;
                *stop = YES;
            }
        }
    }];
    
    return frame;
}

- (DYMAttachmentInfo *)attachmentInfoWithPoint:(CGPoint)point {
    NSTextContainer *container = self.textContainer;
    NSLayoutManager *layoutManager = self.layoutManager;
    
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:point inTextContainer:container fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (characterIndex >= self.text.length) {
        return nil;
    }
    
    NSRange range ;

    DYMAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range];
    
    CGRect bounds = [layoutManager boundingRectForGlyphRange:range inTextContainer:container];
    
    if (CGRectContainsPoint(bounds, point)) {
        return attachment.info;
    }
    return nil;
}

- (void)addAttachmentInfo:(DYMAttachmentInfo *)attachmentInfo {
    if (self.attachmentArray.count >= self.maximumImageCount) {
        if (self.attachmentDelegate && [self.attachmentDelegate respondsToSelector:@selector(inputTextViewMaximumRemind:)]) {
            [self.attachmentDelegate inputTextViewMaximumRemind:self];
        }
        
        return;
    }
    
    self.placeHolderLabel.hidden = YES;
    
    DYMAttachment *attachment = [[DYMAttachment alloc] initWithAttachmentInfo:attachmentInfo maxWidth:self.frame.size.width];
    [self.attachmentArray addObject:attachmentInfo];
    
    UITextRange *selRange = self.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    NSUInteger index = (NSUInteger)[self offsetFromPosition:self.beginningOfDocument toPosition:selStartPos];

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    NSMutableAttributedString *attributedString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [attributedString addAttributes:self.typingAttributes range:(NSRange){0, [attributedString length]}];
    [string insertAttributedString:attributedString atIndex:index];
    
    NSAttributedString *returnString = [[NSAttributedString alloc] initWithString:@"\n" attributes:self.typingAttributes];
    
    [string insertAttributedString:returnString atIndex:index + 1];
    
    self.attributedText = string;
    
    [self.class selectTextForInput:self atRange:NSMakeRange(index + 2, 0)];
    
    self.selectable = NO;
    
}

- (void)replaceAttachmentInfo:(DYMAttachmentInfo *)newAttachmentInfo targetInfo:(DYMAttachmentInfo *)targetAttachmentInfo {
    if (targetAttachmentInfo) {
        if ([self attachmentExistWithIdentifire:targetAttachmentInfo.identifire]) {
            DYMAttachment *attachment = [[DYMAttachment alloc] initWithAttachmentInfo:newAttachmentInfo maxWidth:self.frame.size.width - self.textContainerInset.left - self.textContainerInset.right];
            [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                DYMAttachment *result = (DYMAttachment *)value;
                if (result) {
                    if ([result.info.identifire isEqualToString:targetAttachmentInfo.identifire]) {
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
                        NSMutableAttributedString *attributedString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
                        [attributedString addAttributes:self.typingAttributes range:(NSRange){0, [attributedString length]}];
                        [string replaceCharactersInRange:range withAttributedString:attributedString];
                        *stop = YES;
                    }
                }
            }];
        }
    }
}

+ (void) selectTextForInput:(UITextView *)input atRange:(NSRange)range {
    UITextPosition *startPosition = [input positionFromPosition:[input beginningOfDocument]
                                                         offset:range.location];
    UITextPosition *endPosition = [input positionFromPosition:startPosition
                                                       offset:range.length];
    [input setSelectedTextRange:[input textRangeFromPosition:startPosition toPosition:endPosition]];
}

#pragma textView delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeHolderLabel.hidden = textView.text.length > 0;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value) {
            DYMAttachment *attachment = (DYMAttachment *)value;
            [self.attachmentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DYMAttachmentInfo *info = (DYMAttachmentInfo *)obj;
                if ([info.identifire isEqualToString:attachment.info.identifire]) {
                    [self.attachmentArray removeObjectAtIndex:idx];
                    *stop = YES;
                }
            }];
            *stop = YES;
        }
    }];
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (pasteboard.image != nil)
            return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)paste:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    UIImage *image = pasteboard.image;
    if (image) {
    }
    else
        [super paste:sender];

}

@end

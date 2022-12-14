//
//  AliyunMusicPickCell.m
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickCell.h"
#import "AliyunMusicPickCoverView.h"

@interface AliyunMusicPickCell () <UIScrollViewDelegate>
@property (nonatomic, assign) CGFloat musicDuration;
@property (nonatomic, assign) CGFloat pageDuration;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, strong) UIView *fillLayer;
@property (nonatomic, strong) UIBezierPath *overlayPath;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) AliyunMusicPickCoverView *coverView;
@end

@implementation AliyunMusicPickCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, ScreenWidth/4, 0, ScreenWidth/4);
    [self.contentView addSubview:self.scrollView];
    self.lineView = [[AliyunMusicLineView alloc] initWithFrame:self.bounds];
    [self.scrollView addSubview:self.lineView];
    
    
    self.coverView = [[AliyunMusicPickCoverView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:self.coverView];
    
    
    _startLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _startLabel.textColor = [UIColor whiteColor];
    _startLabel.font = [UIFont systemFontOfSize:11];
    _startLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_startLabel];
    _endLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _endLabel.textColor = [UIColor whiteColor];
    _endLabel.font = [UIFont systemFontOfSize:11];
    _endLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_endLabel];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

-(void)layout {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat factor = _musicDuration/_pageDuration > 1 ? _musicDuration/_pageDuration : 1;
    CGFloat contentWidth = width/2 * factor;
    self.scrollView.contentSize = CGSizeMake(contentWidth, height-48);
    //offset 开始时间 /总时间 
    self.scrollView.frame = CGRectMake(0, 8, width, height-48);
    self.coverView.frame = CGRectMake(0, 8, width, height-48);
    self.lineView.frame =  CGRectMake(0, 0, contentWidth, height-48);
    self.startLabel.frame = CGRectMake(width/4, height-18, 36, 12);
    self.endLabel.frame = CGRectMake(width/4*3-36, height-18, 36, 12);
    self.scrollView.contentInset = UIEdgeInsetsMake(0, ScreenWidth/4, 0, ScreenWidth/4);
    [self.lineView refresh];
    CGFloat contentOffSetX = (_startTime *0.001 * self.scrollView.contentSize.width /_musicDuration) - self.scrollView.contentInset.left;
    [self.scrollView setContentOffset:CGPointMake(contentOffSetX, 0) animated:NO];
}

-(void)configureMusicDuration:(CGFloat)musicDuration pageDuration:(CGFloat)pageDuration startTime:(NSInteger)startTime{
    _pageDuration = pageDuration;
    _musicDuration = musicDuration;
    _startTime = startTime;
    [self layout];
    //设置初始值 开始时间 /总时间
   
//    CGFloat startTime = (_musicDuration * (self.scrollView.contentOffset.x + self.scrollView.contentInset.left)) / self.scrollView.contentSize.width;
//    if (startTime < 0) {
//        startTime = 0;
//    }
    
    self.startLabel.text = [self timeFormatted:startTime*0.001];
    self.endLabel.text = [self timeFormatted:startTime*0.001+_pageDuration];
}

- (void)playMusic{
    [self updateCurrentTime];
}

#pragma mark - scroll view delegate



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentTime];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateCurrentTime];
    }
    
}

- (void)updateCurrentTime {
    NSInteger startTime = (_musicDuration * 1000 * (self.scrollView.contentOffset.x + self.scrollView.contentInset.left) / self.scrollView.contentSize.width);
    if (startTime < 0) {
        startTime = 0;
    }
    self.startTime = startTime;
    self.startLabel.text = [self timeFormatted:startTime * 0.001];
    self.endLabel.text = [self timeFormatted:startTime * 0.001 +_pageDuration];
    [self.delegate didSelectStartTime:startTime];
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)stopScroll {
        CGPoint offset = self.scrollView.contentOffset;
        
        CGFloat minOffset = -self.scrollView.contentInset.left;
        if (offset.x < minOffset) {
            offset.x = minOffset;
        }
        CGFloat maxOffset = self.scrollView.contentSize.width - self.scrollView.bounds.size.width + ScreenWidth/4;
        if (offset.x > maxOffset) {
            offset.x = maxOffset;
        }
        
        [self.scrollView setContentOffset:offset animated:NO];
}
@end

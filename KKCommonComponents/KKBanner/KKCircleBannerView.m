//
//  BannerView.m
//  kakatrip
//
//  Created by CaiMing on 2016/12/5.
//  Copyright © 2016年 kakatrip. All rights reserved.
//

#import "KKCircleBannerView.h"
#import "UIImageView+KKWebImage.h"
#import <Masonry/Masonry.h>
#import "UIView+Frame.h"
#import "UIColor+HexColor.h"

@interface KKCircleBannerView ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIPageControl *pageControl;
@property(nonatomic,strong)NSArray *urls;
@property(nonatomic,assign)int currentIndex;
@property(nonatomic,strong)NSArray *imageViews;
@property(nonatomic,strong)UITapGestureRecognizer *tap;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)UILabel *pageLabel;

@end

@implementation KKCircleBannerView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        [self addSubview:self.pageLabel];
        
        [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(@40);
            make.height.equalTo(@20);
            make.right.offset(-28);
            make.bottom.offset(-14);
        }];
    }
    
    return self;
}

- (void)reloadData:(NSArray*)urls selectIndex:(int)index
{
    if (urls==nil || urls.count<1) {
        
        self.scrollView.hidden = YES;
        return ;
    }
    self.scrollView.hidden = NO;
    _urls = urls;
    _currentIndex = index;
    _pageControl.numberOfPages = _urls.count;
    
    [self displayerCurrentIndex:NO];
    if (urls.count == 1) {
        
        self.scrollView.scrollEnabled = NO;
//        self.pageControl.hidden = YES;
        
    }else
    {
        self.scrollView.scrollEnabled = YES;
//        self.pageControl.hidden = NO;

    }
    self.pageLabel.text = [NSString stringWithFormat:@"%@/%@",@(index+1),@(urls.count)];
    self.pageLabel.hidden = NO;
}

- (void)startTimer
{
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (_urls.count<2) {
        return;
    }
    
    __weak KKCircleBannerView *weakSelf = self;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:weakSelf selector:@selector(cutDown) userInfo:nil repeats:YES];
    
}
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)cutDown
{
    _currentIndex+=1;
    if (_currentIndex >(int) _urls.count-1)
    {
        _currentIndex = 0;
    }
    UIImageView *imageV = _imageViews.lastObject;
    NSString *url = _urls[_currentIndex];
    [imageV kk_setImageWithURLString:url];
    [self.scrollView setContentOffset:CGPointMake(self.frame_width*2, 0) animated:YES];
}

- (void)displayerCurrentIndex:(BOOL)animtion
{

    NSInteger previousIndex;
    NSInteger nextIndex;
    
    if (_currentIndex == 0) {
        
        previousIndex = _urls.count-1;
        
    }else
    {
        previousIndex = _currentIndex-1;
    }
    
    if (_currentIndex == _urls.count-1) {
        
        nextIndex = 0;
        
    }else
    {
        nextIndex = _currentIndex+1;
    }
    
    NSMutableArray *currentDisplayURLs = @[].mutableCopy;
    
    [_urls objectAtIndex:previousIndex];
    
    [currentDisplayURLs addObject:[_urls objectAtIndex:previousIndex]];
    [currentDisplayURLs addObject:[_urls objectAtIndex:_currentIndex]];
    [currentDisplayURLs addObject:[_urls objectAtIndex:nextIndex]];

    
    
//    NSArray *currentDisplayURLs = @[_urls[previousIndex],_urls[_currentIndex],_urls[nextIndex]];
    
    for (NSInteger i = 0; i<currentDisplayURLs.count; i++)
    {
        UIImageView *imageV = _imageViews[i];
        NSString *url = currentDisplayURLs[i];
        [imageV kk_setImageWithURLString:url];
    }
    [self.scrollView setContentOffset:CGPointMake(self.frame_width, 0) animated:animtion];
    self.pageControl.currentPage = _currentIndex;
    self.pageLabel.text = [NSString stringWithFormat:@"%@/%@",@(_currentIndex+1),@(self.urls.count)];
    
}

- (void)onTapAction
{
    if ([self.delegate respondsToSelector:@selector(circleBannerView:didSelectIndex:)]) {
        
        [self.delegate circleBannerView:self didSelectIndex:_currentIndex];
    }
}

#pragma mark -pageController

- (void)pageValueChange:(UIPageControl *)pageControl
{
    
    if ((int)pageControl.currentPage>_currentIndex)
    {
        UIImageView *imageV = _imageViews.lastObject;
        NSString *url = _urls[pageControl.currentPage];
        [imageV kk_setImageWithURLString:url];
        [self.scrollView setContentOffset:CGPointMake(self.frame_width*2, 0) animated:YES];
        
    }else if ((int)pageControl.currentPage<_currentIndex)
    {
        UIImageView *imageV = _imageViews.firstObject;
        NSString *url = _urls[pageControl.currentPage];
        [imageV kk_setImageWithURLString:url];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    
    _currentIndex = (int)pageControl.currentPage;
    

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self displayerCurrentIndex:NO];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentIndex = scrollView.contentOffset.x/self.frame_width;
    if (currentIndex==2)
    {
        _currentIndex++;
        
    }else if (currentIndex==1)
    {
        
    }else if (currentIndex==0)
    {
        _currentIndex--;
    }

    if (_currentIndex >(int)_urls.count-1) {
        
        _currentIndex = 0;
    }
    
    if (_currentIndex<0) {
        
        _currentIndex = (int)_urls.count-1;
        
    }
    
    [self displayerCurrentIndex:NO];
    
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5]];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(3*self.frame_width, self.frame_height);
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView addGestureRecognizer:self.tap];
        _scrollView.hidden = YES;
        NSMutableArray *arr = [NSMutableArray array];
        
        for (NSInteger i = 0; i<3; i++)
        {
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame_width*i, 0, self.frame_width, self.frame_height)];
            [_scrollView addSubview:imageV];
            [arr addObject:imageV];
        }
        
        _imageViews = arr.copy;
        
    }
    return _scrollView;
}


- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.frame_height-23, self.frame_width, 23)];
        _pageControl.backgroundColor = [UIColor clearColor];
        [_pageControl addTarget:self action:@selector(pageValueChange:) forControlEvents:UIControlEventValueChanged];
        _pageControl.pageIndicatorTintColor = KKColorWithHex(@"#959495");
        _pageControl.currentPageIndicatorTintColor = KKColorWithHex(@"#D67118");
        _pageControl.hidden = YES;
    }
    
    return _pageControl;
}


- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAction)];
    }
    return _tap;
}

- (UILabel *)pageLabel
{
    if (_pageLabel == nil) {
        
        _pageLabel = [[UILabel alloc]init];
        _pageLabel.layer.cornerRadius = 4;
        _pageLabel.layer.borderWidth = 0.5;
        _pageLabel.hidden = YES;
        _pageLabel.layer.borderColor = KKColorWithHex(@"#333333").CGColor;
        _pageLabel.textColor = KKColorWithHex(@"#333333");
        _pageLabel.font = [UIFont systemFontOfSize:12];
        _pageLabel.textAlignment  = NSTextAlignmentCenter;
        _pageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        _pageLabel.layer.masksToBounds = YES;

    }
    return _pageLabel;
}


@end

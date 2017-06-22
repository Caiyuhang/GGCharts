//
//  DLineScaler.m
//  HSCharts
//
//  Created by 黄舜 on 17/6/22.
//  Copyright © 2017年 I really is a farmer. All rights reserved.
//

#import "DLineScaler.h"

typedef double(^LineScaler)(double record);

/** 纵轴计算 */
LineScaler y_axiScaler(CGFloat max, CGFloat min, CGRect rect)
{
    CGFloat dis = CGRectGetHeight(rect);
    CGFloat pix = dis / (max - min);
    
    CGFloat zero = min > 0 ? dis + rect.origin.y : dis - pix * fabs(min) + rect.origin.y;
    
    return ^(double val) {
        
        if (val < 0) {
            
            return zero + fabs(val) * pix;
        }
        else {
            
            if (min < 0) {
                
                return zero - fabs(val) * pix;
            }
            
            return zero - fabs(val - min) * pix;
        }
    };
}

/** 横轴计算 */
LineScaler x_axiScaler(NSInteger sep, CGRect rect, CGFloat base)
{
    CGFloat interval = CGRectGetWidth(rect) / sep;
    
    return ^(double index) {
        
        return base * interval + index * interval + rect.origin.x;
    };
}

@interface DLineScaler ()

@property (nonatomic, copy) LineScaler fig;     ///< 纵轴换算

@property (nonatomic, copy) LineScaler axis;    ///< 横轴换算

@end

@implementation DLineScaler

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _xRatio = .5f;
    }
    
    return self;
}

/** 获取价格点 */
- (CGFloat)getYPixelWithData:(CGFloat)data
{
    return _fig(data);
}

- (void)setDataAry:(NSArray<NSNumber *> *)dataAry
{
    _dataAry = dataAry;
    
    if (_xMaxCount == 0) {
        
        _xMaxCount = dataAry.count;
    }
    
    CGPoint * point = malloc(dataAry.count * sizeof(CGPoint));
    [self updateLinePoints:point];
}

- (void)updateLinePoints:(CGPoint *)linePoints
{
    if (_linePoints != nil) {
        
        free(_linePoints);
    }
    
    _linePoints = linePoints;
}

/** 更新计算点 */
- (void)updateScaler
{
    _fig = y_axiScaler(_max, _min, self.rect);
    _axis = x_axiScaler(_xMaxCount, self.rect, _xRatio);
    
    [self.dataAry enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL * stop) {
        
        _linePoints[idx] = CGPointMake(_axis(idx), _fig(obj.floatValue));
    }];
}

- (void)dealloc
{
    if (_linePoints != nil) {
        
        free(_linePoints);
        _linePoints = nil;
    }
}

@end

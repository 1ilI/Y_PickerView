//
//  AreaModel.m
//  Y_PickerViewExample
//
//  Created by Yue on 2018/11/6.
//  Copyright © 2018年 Yue. All rights reserved.
//

#import "AreaModel.h"

@implementation AreaModel

- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
- (NSUInteger)hash { return [self yy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }
- (NSString *)description { return [self yy_modelDescription]; }


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"subArr" : @[@"city",@"area"],
             };
}

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"subArr" : [AreaModel class]
             };
}

@end

//
//  AreaModel.h
//  Y_PickerViewExample
//
//  Created by Yue on 2018/11/6.
//  Copyright © 2018年 Yue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

@interface AreaModel : NSObject <NSCoding, NSCopying>

@property (copy, nonatomic) NSString *shortCode;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *grade;
@property (copy, nonatomic) NSArray  *subArr;

@end

//
//  Y_PickerViewController.h
//  Y_PickerView
//
//  Created by Yue on 2016/11/5.
//  Copyright © 2016年 Yue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DataPickerResult)(NSDate *selectDate);
typedef void(^CustomPickerResult)(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic);

@interface Y_PickerViewController : UIViewController

@property (nonatomic, strong) UIDatePicker  *datePicker;
@property (nonatomic, strong) UIPickerView  *picker;

@property (nonatomic, copy, nonnull) DataPickerResult dataPickerBlock;
@property (nonatomic, copy, nonnull) CustomPickerResult customPickerBlock;

@property (nonatomic, assign) BOOL isNeedDefault;//是否需要默认项(提示语)

/**
 创建 UIDatePicker 默认仅选择日期(UIDatePickerModeDate)
 @param handler 回调
 @return UIDatePicker
 */
- (instancetype)initDatePickerWithCompletionHandle:(DataPickerResult)handler;

/**
 根据传入的模型数组数据创建自定义的PickerView
 @param data 模型数组
 @param displayProperty 模型中要在PickerView上显示的字段
 @param defaultValue 默认值(提示语)数组，要和 data 的元素个数一样
 @param handler 回调
 @return UIPickerView
 */
- (instancetype)initCustomPickerWithArray:(NSArray <NSArray *> *)data displayProperty:(NSString *)displayProperty defaultValue:(NSArray *)defaultValue completionHandle:(CustomPickerResult)handler;

/**
 创建省市县 PickerView
 @param data            数据源
 @param displayProperty 模型中要在PickerView上显示的字段
 @param subArrProperty  模型中 子数组 的字段
 @param handler         回调
 @return UIPickerView
 */
- (instancetype)initCityPickerWithArray:(NSArray *)data displayProperty:(NSString *)displayProperty subArrProperty:(NSString *)subArrProperty completionHandle:(CustomPickerResult)handler;

/**
 展示 PickerViewController
 @param parentVC 父VC
 */
- (void)showPickerVC:(UIViewController *)parentVC ;

@end

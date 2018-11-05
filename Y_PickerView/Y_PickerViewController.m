//
//  Y_PickerViewController.m
//  Y_PickerView
//
//  Created by Yue on 2016/11/5.
//  Copyright © 2016年 Yue. All rights reserved.
//

#import "Y_PickerViewController.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define MainViewHeight SCREEN_HEIGHT * 0.4

typedef NS_ENUM(NSUInteger, PickerStyle) {
    PickerStyle_DatePicker,
    PickerStyle_CustomPicker,
};

@interface Y_PickerViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (assign, nonatomic) PickerStyle   style;
@property (strong, nonatomic) UIControl *bgControl;
@property (strong, nonatomic) UIView    *mainView;
@property (strong, nonatomic) UIButton  *cancelBut;
@property (strong, nonatomic) UIButton  *confirmBut;
@property (strong, nonatomic) CALayer   *lineLay;
@property (assign, nonatomic) BOOL      needAnimateMainView;
@property (copy, nonatomic)   NSString  *displayProperty;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *recomendData;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexDictionary;
@property (nonatomic, strong) NSMutableDictionary *selectedValueDictionary;
@property (nonatomic, assign) NSInteger selectedIndex;//DatePicker使用的index

@end

@implementation Y_PickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedIndexDictionary = [NSMutableDictionary new];
    self.selectedValueDictionary = [NSMutableDictionary new];
    self.selectedIndex = -1;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
    [self.view addSubview:self.bgControl];
    [self.view addSubview:self.mainView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _bgControl.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (!_needAnimateMainView) {
        _mainView.frame = CGRectMake(0, SCREEN_HEIGHT - MainViewHeight, SCREEN_WIDTH, MainViewHeight);
    }
    CGFloat buttonH = 45;
    CGFloat cancelButX = (SCREEN_WIDTH > SCREEN_HEIGHT) ? 50 : 5;
    _cancelBut.frame = CGRectMake(cancelButX, 0, buttonH, buttonH);
    CGFloat confirmButX = SCREEN_WIDTH - buttonH - 5 - ((SCREEN_WIDTH > SCREEN_HEIGHT) ? 50 : 0);
    _confirmBut.frame = CGRectMake(confirmButX, 0, buttonH, buttonH);
    _lineLay.frame = CGRectMake(0, buttonH, SCREEN_WIDTH, 1);
    
    CGFloat pickerY = buttonH+2;
    CGFloat pickerH = MainViewHeight - pickerY;
    _picker.frame = CGRectMake(0, pickerY, SCREEN_WIDTH, pickerH);
    _datePicker.frame = CGRectMake(0, pickerY, SCREEN_WIDTH, pickerH);
}

#pragma mark - ===== 创建PickerVC =====
- (instancetype)initDatePickerWithCompletionHandle:(DataPickerResult)handler {
    if (self = [super init]) {
        self.isNeedDefault = NO;
        self.recomendData = nil;
        self.style = PickerStyle_DatePicker;
        self.dataPickerBlock = handler;
    }
    return self;
}

- (instancetype)initCustomPickerWithArray:(NSArray <NSArray *> *)data displayProperty:(NSString *)displayProperty defaultValue:(NSArray *)defaultValue completionHandle:(CustomPickerResult)handler {
    [self checkSourceValidWithData:data defaultValue:defaultValue];
    if (self = [super init]) {
        self.displayProperty = displayProperty;
        self.isNeedDefault = defaultValue.count ? YES : NO;
        self.recomendData = [defaultValue copy];
        self.style = PickerStyle_CustomPicker;
        self.customPickerBlock = handler;
        self.dataSource = [data copy];
        [self.picker reloadAllComponents];
    }
    return self;
}

//检查数据的合法性
- (void)checkSourceValidWithData:(NSArray *)data defaultValue:(NSArray *)defaultValue {
    if (defaultValue.count && data.count != defaultValue.count ) {
        @throw [NSException exceptionWithName:@"CreatePickerField" reason:@"选项数组个数和默认项个数不匹配" userInfo:nil];
    }
    for (id item in data) {
        if (![item isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"CreatePickerField" reason:@"选项数组格式错误" userInfo:nil];
        }
    }
}

#pragma mark - ===== 展示PickerVC =====
- (void)showPickerVC:(UIViewController *)parentVC {
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext | UIModalPresentationFullScreen;
    self.needAnimateMainView = YES;
    self.mainView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, MainViewHeight);
    [parentVC presentViewController:self animated:NO completion:^{
        [UIView animateWithDuration:0.3 animations:^{
            self.mainView.frame = CGRectMake(0, SCREEN_HEIGHT - MainViewHeight, SCREEN_WIDTH, MainViewHeight);
        } completion:^(BOOL finished) {
            self.needAnimateMainView = NO;
        }];
    }];
}

#pragma mark - ===== 点击事件 =====
- (void)dissmissVC {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)confirmData {
    if ([self existEmptyData]) {
        //存在默认值的情况下,且点击确定的时候没有选择就不进行回调
        if (self.isNeedDefault) {
            //有默认值的情况下，其中有一项未选择，则选择失败，取消掉视图
            [self dissmissVC];
            return;
        }
        else {
            //不存在提示语，点击确定没有选择就默认使用第一条数据
            [self checkEmptyData];
        }
    }
    
    if (self.style == PickerStyle_DatePicker) {
        if (self.dataPickerBlock) {
            self.dataPickerBlock(_datePicker.date);
        }
    }
    else if (self.style == PickerStyle_CustomPicker) {
        if (self.customPickerBlock) {
            self.customPickerBlock([self.selectedIndexDictionary copy], [self.selectedValueDictionary copy]);
        }
    }
    
    [self dissmissVC];
}

//判断是否有为空的数据
- (BOOL)existEmptyData {
    for (NSInteger index = 0; index < self.dataSource.count; index ++) {
        if (![self.selectedIndexDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]]) {
            return YES;
        }
    }
    return NO;
}

//检查数据，将空数据赋值为一个条数据
- (void)checkEmptyData {
    [self.dataSource enumerateObjectsUsingBlock:^(NSArray   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self.selectedIndexDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)idx]]) {
            [self.selectedIndexDictionary setObject:@(0) forKey:[NSString stringWithFormat:@"%ld", (long)idx]];
        }
        if (![self.selectedValueDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)idx]]) {
            [self.selectedValueDictionary setObject:obj.firstObject forKey:[NSString stringWithFormat:@"%ld", (long)idx]];
        }
    }];
}

#pragma mark - ===== UIPickerViewDataSource =====
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dataSource.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *array = self.dataSource[component];
    if (self.isNeedDefault) {
        return array.count + 1;
    } else {
        return array.count;
    }
}

#pragma mark - ===== UIPickerViewDelegate =====
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *array = self.dataSource[component];
    //有提示项
    if (self.isNeedDefault) {
        if (row == 0) {
            return self.recomendData[component];
        }
        else {
            id data = array[row - 1];
            return [self returnDisplayTitle:data];
        }
    }
    //无提示选项
    else {
        id data = array[row];
        return [self returnDisplayTitle:data];
    }
}

- (NSString *)returnDisplayTitle:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        return data;
    }
    else if (_displayProperty.length && [data respondsToSelector:NSSelectorFromString(_displayProperty)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *displayValue = [data performSelector:NSSelectorFromString(_displayProperty)];
        return displayValue;
#pragma clang diagnostic pop
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *array = self.dataSource[component];
    if (self.isNeedDefault) {
        if (row == 0) {
            [self.selectedIndexDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)component]];
            [self.selectedValueDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)component]];
        }
        else {
            [self.selectedIndexDictionary setObject:@(row - 1) forKey:[NSString stringWithFormat:@"%ld", (long)component]];
            [self.selectedValueDictionary setObject:array[row - 1] forKey:[NSString stringWithFormat:@"%ld", (long)component]];
            self.selectedIndex = row - 1;
        }
    }
    else {
        [self.selectedIndexDictionary setObject:@(row) forKey:[NSString stringWithFormat:@"%ld", (long)component]];
        [self.selectedValueDictionary setObject:array[row] forKey:[NSString stringWithFormat:@"%ld", (long)component]];
        self.selectedIndex = row;
    }
}

#pragma mark - ===== 懒加载 =====
- (UIControl *)bgControl {
    if (!_bgControl) {
        UIControl *control = [[UIControl alloc] init];
        [control addTarget:self action:@selector(dissmissVC) forControlEvents:UIControlEventTouchUpInside];
        _bgControl = control;
    }
    return _bgControl;
}

- (UIView *)mainView {
    if (!_mainView) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:self.cancelBut];
        [view addSubview:self.confirmBut];
        [view.layer addSublayer:self.lineLay];
        
        if (self.style == PickerStyle_DatePicker) {
            [view addSubview:self.datePicker];
        }
        else if (self.style == PickerStyle_CustomPicker) {
            [view addSubview:self.picker];
        }
        
        _mainView = view;
    }
    return _mainView;
}

- (UIButton *)cancelBut {
    if (!_cancelBut) {
        UIButton *button = [self createButtonWithTitle:@"取消"];
        [button setTintColor:[UIColor lightGrayColor]];
        [button addTarget:self action:@selector(dissmissVC) forControlEvents:UIControlEventTouchUpInside];
        _cancelBut = button;
    }
    return _cancelBut;
}

- (UIButton *)confirmBut {
    if (!_confirmBut) {
        UIButton *button = [self createButtonWithTitle:@"确认"];
        [button addTarget:self action:@selector(confirmData) forControlEvents:UIControlEventTouchUpInside];
        _confirmBut = button;
    }
    return _confirmBut;
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    return button;
}

- (CALayer *)lineLay {
    if (!_lineLay) {
        CALayer *line = [CALayer layer];
        line.backgroundColor = [UIColor colorWithRed:221 / 255.0 green:221 / 255.0 blue:221 / 255.0 alpha:1].CGColor;
        _lineLay = line;
    }
    return _lineLay;
}

- (UIPickerView *)picker {
    if (!_picker) {
        _picker = [[UIPickerView alloc] init];
        _picker.delegate = self;
        _picker.dataSource = self;
        [_picker selectRow:0 inComponent:0 animated:YES];
    }
    return _picker;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        //        [_datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [_datePicker setTimeZone:[NSTimeZone localTimeZone]];
        [_datePicker setDate:[NSDate date] animated:YES];
    }
    return _datePicker;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

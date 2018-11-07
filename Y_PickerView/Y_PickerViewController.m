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
    PickerStyle_CityPicker,
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
@property (copy, nonatomic)   NSString  *subArrProperty;

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
    
    //省市县模式 初始化就全部选中第一条数据
    if (_style == PickerStyle_CityPicker) {
        _selectedIndexDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"0":@(0), @"1":@(0), @"2":@(0)}];
        [_selectedValueDictionary setObject:[_dataSource firstObject] forKey:@"0"];
        [_selectedValueDictionary setObject:[[self cityDataArr] firstObject] forKey:@"1"];
        [_selectedValueDictionary setObject:[[self countyData] firstObject] forKey:@"2"];
    }
    
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

- (instancetype)initCityPickerWithArray:(NSArray *)data displayProperty:(NSString *)displayProperty subArrProperty:(NSString *)subArrProperty completionHandle:(CustomPickerResult)handler {
    if (self = [super init]) {
        self.displayProperty = displayProperty;
        self.subArrProperty = subArrProperty;
        self.isNeedDefault = NO;
        self.recomendData = nil;
        self.style = PickerStyle_CityPicker;
        self.customPickerBlock = handler;
        self.dataSource = [data copy];
        [self.picker reloadAllComponents];
    }
    return self;
}

//获取到 省下所有的 市的数据
- (NSArray *)cityDataArr {
    NSInteger selectProvince = [[_selectedIndexDictionary valueForKey:@"0"] integerValue];
    NSArray *cityData = [self subArrWithDataModel:[_dataSource objectAtIndex:selectProvince]];
    return cityData;
}

//获取到 市下所有的 县的数据
- (NSArray *)countyData {
    NSArray *cityData = [self cityDataArr];
    NSInteger selectCity = [[_selectedIndexDictionary valueForKey:@"1"] integerValue];
    NSArray *countyData = [self subArrWithDataModel:[cityData objectAtIndex:selectCity]];
    return countyData;
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
    else if (_style == PickerStyle_CustomPicker || _style == PickerStyle_CityPicker) {
        if (self.customPickerBlock) {
            self.customPickerBlock([self.selectedIndexDictionary copy], [self.selectedValueDictionary copy]);
        }
    }
    
    [self dissmissVC];
}

//判断是否有为空的数据
- (BOOL)existEmptyData {
    NSInteger max = (_style == PickerStyle_CityPicker) ? 3 : _dataSource.count;
    for (NSInteger index = 0; index < max; index ++) {
        if (![self.selectedIndexDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]]) {
            return YES;
        }
    }
    return NO;
}

//检查数据，将空数据赋值为一个条数据
- (void)checkEmptyData {
    //省市县模式下
    if (_style == PickerStyle_CityPicker) {
        if (![_selectedValueDictionary objectForKey:@"0"]) {
            [_selectedValueDictionary setObject:[_dataSource firstObject] forKey:@"0"];
            [_selectedIndexDictionary setObject:@(0) forKey:@"0"];
        }
        if (![_selectedValueDictionary objectForKey:@"1"]) {
            [_selectedValueDictionary setObject:[[self cityDataArr] firstObject] forKey:@"1"];
            [_selectedIndexDictionary setObject:@(0) forKey:@"1"];
        }
        if (![_selectedValueDictionary objectForKey:@"2"]) {
            [_selectedValueDictionary setObject:[[self countyData] firstObject] forKey:@"2"];
            [_selectedIndexDictionary setObject:@(0) forKey:@"2"];
        }
    }
    //非省市县模式
    else {
        [self.dataSource enumerateObjectsUsingBlock:^(NSArray   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.selectedIndexDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)idx]]) {
                [self.selectedIndexDictionary setObject:@(0) forKey:[NSString stringWithFormat:@"%ld", (long)idx]];
            }
            if (![self.selectedValueDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)idx]]) {
                [self.selectedValueDictionary setObject:obj.firstObject forKey:[NSString stringWithFormat:@"%ld", (long)idx]];
            }
        }];
    }
}


- (NSArray *)subArrWithDataModel:(id)dataModel {
    SEL subArrSel = NSSelectorFromString(_subArrProperty);
    if ([dataModel respondsToSelector:subArrSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *subArr = [dataModel performSelector:subArrSel];
#pragma clang diagnostic pop
        return subArr;
    }
    return nil;
}

#pragma mark - ===== UIPickerViewDataSource =====
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    //省市县模式
    if (_style == PickerStyle_CityPicker) {
        return 3;
    }
    //其他模式
    return self.dataSource.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //省市县模式
    if (_style == PickerStyle_CityPicker) {
        NSArray *cityData = [self cityDataArr];
        NSArray *countyData = [self countyData];
        if (component == 0) {
            return [_dataSource count];
        }
        else if (component == 1) {
            return [cityData count];
        }
        else if (component == 2) {
            return [countyData count];
        }
    }
    //其他模式
    NSArray *array = self.dataSource[component];
    if (self.isNeedDefault) {
        return array.count + 1;
    } else {
        return array.count;
    }
}

#pragma mark - ===== UIPickerViewDelegate =====
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //省市县模式
    if (_style == PickerStyle_CityPicker) {
        NSArray *cityData = [self cityDataArr];
        NSArray *countyData = [self countyData];
        
        if (component == 0) {
            return [self returnDisplayTitle:_dataSource[row]];
        }
        else if (component == 1) {
            if (row < cityData.count) {
                id city = [cityData objectAtIndex:row];
                return [self returnDisplayTitle:city];
            }
        }
        else if (component == 2) {
            if (row < countyData.count) {
                id county = [countyData objectAtIndex:row];
                return [self returnDisplayTitle:county];
            }
        }
        return nil;
    }
    
    //其他模式
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
    NSString *key = [NSString stringWithFormat:@"%ld", (long)component];
    //省市县模式下
    if (_style == PickerStyle_CityPicker) {
        [_selectedIndexDictionary setObject:@(row) forKey:key];
        if (component == 0) {
            //保存好index然后再刷新Component选择row
            [_selectedIndexDictionary setObject:@(0) forKey:@"1"];
            [_selectedIndexDictionary setObject:@(0) forKey:@"2"];
            [_picker reloadComponent:1];
            [_picker reloadComponent:2];
            [_picker selectRow:0 inComponent:2 animated:YES];
            [_picker selectRow:0 inComponent:1 animated:YES];
        }
        else if (component == 1) {
            //保存好index然后再刷新Component选择row
            [_selectedIndexDictionary setObject:@(0) forKey:@"2"];
            [_picker reloadComponent:2];
            [_picker selectRow:0 inComponent:2 animated:YES];
        }
        else if (component == 2) {
        }
        //保存选择内容
        [self saveSelectedValueDictionary];
    }
    //其他模式
    else {
        NSArray *array = self.dataSource[component];
        if (self.isNeedDefault) {
            if (row == 0) {
                [self.selectedIndexDictionary removeObjectForKey:key];
                [self.selectedValueDictionary removeObjectForKey:key];
            }
            else {
                [self.selectedIndexDictionary setObject:@(row - 1) forKey:key];
                [self.selectedValueDictionary setObject:array[row - 1] forKey:key];
                self.selectedIndex = row - 1;
            }
        }
        else {
            [self.selectedIndexDictionary setObject:@(row) forKey:key];
            [self.selectedValueDictionary setObject:array[row] forKey:key];
            self.selectedIndex = row;
        }
    }
}

- (void)saveSelectedValueDictionary {
    NSInteger provinceIdx = [[_selectedIndexDictionary valueForKey:@"0"] integerValue];
    id province = [_dataSource objectAtIndex:provinceIdx];
    [_selectedValueDictionary setObject:province forKey:@"0"];
    NSInteger cityIdx = [[_selectedIndexDictionary valueForKey:@"1"] integerValue];
    id city = [[self cityDataArr] objectAtIndex:cityIdx];
    [_selectedValueDictionary setObject:city forKey:@"1"];
    NSInteger countyIdx = [[_selectedIndexDictionary valueForKey:@"2"] integerValue];
    id county = [[self countyData] objectAtIndex:countyIdx];
    [_selectedValueDictionary setObject:county forKey:@"2"];
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
        else if (self.style == PickerStyle_CityPicker) {
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

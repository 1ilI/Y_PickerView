//
//  ViewController.m
//  Y_PickerViewExample
//
//  Created by Yue on 2016/11/5.
//  Copyright © 2016年 Yue. All rights reserved.
//

#import "ViewController.h"
#import "Y_PickerViewController.h"
#import "Model.h"
#import "SubjectModel.h"
#import "GradeModel.h"
#import "YYModel.h"
#import "AreaModel.h"

static NSString *const tableViewCellID = @"tableViewCellReuseIdentifier";
@interface ViewController ()

@property (copy, nonatomic) NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"Y_PickerView";
    
    self.dataArr = @[@"默认日期选择（UIDatePickerModeDate）",@"日期选择（UIDatePickerModeDateAndTime）",@"单列PickerView",@"单列PickerView-带有默认值",@"单列PickerView-模型数组",@"多列PickerView",@"多列PickerView-模型数组",@"省市县 PickerView"];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellID forIndexPath:indexPath];
    cell.textLabel.text = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *funcName = [NSString stringWithFormat:@"showPicker%ld",indexPath.row+1];
    SEL sel = NSSelectorFromString(funcName);
    if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:sel];
#pragma clang diagnostic pop
    }
}

#pragma mark - ===== ShowAlert =====
- (void)showPicker1 {
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initDatePickerWithCompletionHandle:^(NSDate *selectDate) {
        NSLog(@"--->%@",selectDate);
    }];
    [picker showPickerVC:self];
}

- (void)showPicker2 {
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initDatePickerWithCompletionHandle:^(NSDate *selectDate) {
        NSLog(@"--->%@",selectDate);
    }];
    picker.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [picker showPickerVC:self];
}

- (void)showPicker3 {
    NSArray *data = @[@[@"Objective-C", @"Swift", @"Java", @"Python", @"Hello World"]];
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCustomPickerWithArray:data displayProperty:nil defaultValue:nil completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
        NSString *selected = [selectedValueDic valueForKey:@"0"];
        NSLog(@"--->%@",selected);
    }];
    [picker showPickerVC:self];
}

- (void)showPicker4 {
    NSArray *data = @[@[@"Objective-C", @"Swift", @"Java", @"Python", @"Hello World"]];
    NSArray *defaultData = @[@"---从入门到放弃---"];
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCustomPickerWithArray:data displayProperty:nil defaultValue:defaultData completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
        NSString *selected = [selectedValueDic valueForKey:@"0"];
        NSLog(@"--->%@",selected);
    }];
    [picker showPickerVC:self];
}

- (void)showPicker5 {
    Model *m1 = [[Model alloc] init];
    m1.name = @"张";
    m1.number = @"001";
    
    Model *m2 = [[Model alloc] init];
    m2.name = @"王";
    m2.number = @"002";
    
    Model *m3 = [[Model alloc] init];
    m3.name = @"李";
    m3.number = @"003";
    
    Model *m4 = [[Model alloc] init];
    m4.name = @"赵";
    m4.number = @"004";
    
    NSArray *data = @[@[m1, m2, m3, m4]];
    NSArray *defaultData = @[@"---请选择---"];
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCustomPickerWithArray:data displayProperty:@"name" defaultValue:defaultData completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
        Model *selected = [selectedValueDic valueForKey:@"0"];
        NSLog(@"--->%@--->%@--->%@",selected,selected.name,selected.number);
    }];
    [picker showPickerVC:self];
}

- (void)showPicker6 {
    NSArray *data = @[@[@"Objective-C", @"Swift", @"Java", @"Python", @"Hello World"], @[@"男", @"女"]];
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCustomPickerWithArray:data displayProperty:nil defaultValue:nil completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
        NSString *selected1 = [selectedValueDic valueForKey:@"0"];
        NSString *selected2 = [selectedValueDic valueForKey:@"1"];
        NSLog(@"--->%@---->%@",selected1, selected2);
    }];
    [picker showPickerVC:self];
}

- (void)showPicker7 {
    Model *n1 = [[Model alloc] init];
    n1.name = @"张";
    n1.number = @"001";
    
    Model *n2 = [[Model alloc] init];
    n2.name = @"王";
    n2.number = @"002";
    
    Model *n3 = [[Model alloc] init];
    n3.name = @"李";
    n3.number = @"003";
    
    Model *n4 = [[Model alloc] init];
    n4.name = @"赵";
    n4.number = @"004";
    
    SubjectModel *m1 = [[SubjectModel alloc] init];
    m1.name = @"语文";
    m1.subjectID = @"01101";
    
    SubjectModel *m2 = [[SubjectModel alloc] init];
    m2.name = @"数学";
    m2.subjectID = @"00110";
    
    SubjectModel *m3 = [[SubjectModel alloc] init];
    m3.name = @"英语";
    m3.subjectID = @"00101";
    
    SubjectModel *m4 = [[SubjectModel alloc] init];
    m4.name = @"理综";
    m4.subjectID = @"01011";
    
    GradeModel *m5 = [[GradeModel alloc] init];
    m5.name = @"优";
    m5.gradeID = @"grade100-85";
    
    GradeModel *m6 = [[GradeModel alloc] init];
    m6.name = @"良";
    m6.gradeID = @"grade85-70";
    
    GradeModel *m7 = [[GradeModel alloc] init];
    m7.name = @"差";
    m7.gradeID = @"grade70-60";
    
    NSArray *data = @[@[n1, n2, n3, n4], @[m1, m2, m3, m4], @[m5, m6, m7]];
    NSArray *defaultData = @[@"--姓名--", @"--学科--", @"--评级--"];
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCustomPickerWithArray:data displayProperty:@"name" defaultValue:defaultData completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
        Model *person = [selectedValueDic valueForKey:@"0"];
        SubjectModel *selected1 = [selectedValueDic valueForKey:@"1"];
        GradeModel *selected2 = [selectedValueDic valueForKey:@"2"];
        NSLog(@"--->%@--->%@--->%@--->%@--->%@",person.name, selected1.name, selected1.subjectID, selected2.name, selected2.gradeID);
    }];
    [picker showPickerVC:self];
}

- (void)showPicker8 {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"area2" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:jsonPath];
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *areaList = [NSArray yy_modelArrayWithClass:[AreaModel class] json:jsonData];
    Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCityPickerWithArray:areaList displayProperty:@"name" subArrProperty:@"subArr" completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
        AreaModel *province = [selectedValueDic valueForKey:@"0"];
        AreaModel *city = [selectedValueDic valueForKey:@"1"];
        AreaModel *county = [selectedValueDic valueForKey:@"2"];
        NSLog(@"--->%@:%@--->%@:%@--->%@:%@",province.name, province.shortCode, city.name, city.shortCode, county.name, county.shortCode);
        NSLog(@"----->%@",selectedIndexDic);
    }];
    [picker showPickerVC:self];
}

@end

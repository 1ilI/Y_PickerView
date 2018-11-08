# Y_PickerView
对 UIDatePicker/UIPickerView 进行封装，快速创建一个多种样式的 PickerView 选择器。

## 功能
一般选择器嘛，都是由一个点击事件触发，然后弹出视图，选择后消失。所以就简单封装一个 UIViewController ，里面有 UIDatePicker/UIPickerView ，可通过传入的自定义数组，来创建视图，选择结果通过 block 获取。

现阶段主要就三种模式展示：
> 日期选择器-UIDatePicker ，使用自带的 datePickerMode 切换样式
 
> 自定义的 UIPickerView ，通过传入的数组数据创建单列或多列 PickerView

> 省市县选择器，通过传入的模型数组创建选择器

特别之处就是在创建时可指定 `displayProperty` ，这个就是你传入的对象数组中，那个对象模型，你想要在 PickerView 中显示的属性。

这样做的目的是这个库不关心你的数据模型是什么，只要告我讲你要 `在 PickerView 中展示的文字所对应模型的字段`就可以。

省市县的 `subArrProperty` ，也是同理。

![show](https://raw.githubusercontent.com/1ilI/Y_PickerView/master/Y_PickerView.gif)

## 安装

### 1.手动安装:
下载 Example 后,将子文件夹 `Y_PickerView` 拖入到项目中, 导入头文件 `Y_PickerViewController.h` 即可开始使用。

### 2.CocoaPods安装:

>`pod 'Y_PickerView' `

>`pod install 或 pod install --verbose --no-repo-update`


## 使用

* 日期选择器
```objc
Y_PickerViewController *picker = [[Y_PickerViewController alloc] initDatePickerWithCompletionHandle:^(NSDate *selectDate) {
}];
[picker showPickerVC:self];
```

* 自定义PickerView
```objc
NSArray *data = @[@[@"Objective-C", @"Swift", @"Java", @"Python", @"Hello World"]];
Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCustomPickerWithArray:data displayProperty:@"DisplayName" defaultValue:nil completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
    NSString *selected = [selectedValueDic valueForKey:@"0"];
}];
[picker showPickerVC:self];
```

* 省市县PickerView
```objc
NSArray *areaList = [NSArray yy_modelArrayWithClass:[AreaModel class] json:jsonData];
Y_PickerViewController *picker = [[Y_PickerViewController alloc] initCityPickerWithArray:areaList displayProperty:@"name" subArrProperty:@"subArr" completionHandle:^(NSDictionary *selectedIndexDic, NSDictionary *selectedValueDic) {
    AreaModel *province = [selectedValueDic valueForKey:@"0"];
    AreaModel *city = [selectedValueDic valueForKey:@"1"];
    AreaModel *county = [selectedValueDic valueForKey:@"2"];
}];
[picker showPickerVC:self];
```

## Example

详细使用参见 [Example](https://codeload.github.com/1ilI/Y_PickerView/zip/master)

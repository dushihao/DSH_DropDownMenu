//
//  ViewController.m
//  DSH_DropDownMenu
//
//  Created by 杜世豪 on 2017/5/12.
//  Copyright © 2017年 杭州秋溢科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "DSH_DropDownMenu.h"

@interface ViewController ()<DSH_DropDownMenuDataSource,DSH_DropDownMenuDelegate>
{
    NSArray *_contentArray;
}
@property (weak, nonatomic) IBOutlet DSH_DropDownMenu *dropDownMenu;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _contentArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"plist"]];
    
    self.dropDownMenu.dataSource = self;
    self.dropDownMenu.delegate = self;
}


- (NSArray<NSString *> *)sectionTitlesWithdropDownMenu:(DSH_DropDownMenu *)dropDownMenu{
    return @[@"ALLSTAR",@"ADC",@"🤣"];
}

- (NSArray<NSString *> *)dropDownMenu:(DSH_DropDownMenu *)dropDownMenu MenusInSection:(NSInteger)section{
    return _contentArray[section] ;
}

- (void)dropDownMenu:(DSH_DropDownMenu *)dropDownMenu didSectedRowAtSection:(NSInteger)seciton row:(NSInteger)row{
    NSLog(@"你选择的是>>>>>%@",_contentArray[seciton][row]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

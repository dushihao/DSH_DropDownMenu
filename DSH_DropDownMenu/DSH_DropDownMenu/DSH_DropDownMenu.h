//
//  DSH_DropDowmMenu.h
//  DSH_DropDownMenu
//
//  Created by 杜世豪 on 2017/5/12.
//  Copyright © 2017年 杭州秋溢科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DSH_DropDownMenu;
// 数据源 代理方法
@protocol  DSH_DropDownMenuDataSource<NSObject>

@required

// 返回标题数组
- (NSArray <NSString  *>*)sectionTitlesWithdropDownMenu:(DSH_DropDownMenu *)dropDownMenu;
// 返回某一组的分类数组
- (NSArray <NSString *>*)dropDownMenu:(DSH_DropDownMenu *)dropDownMenu  MenusInSection:(NSInteger)section;

@end

@protocol DSH_DropDownMenuDelegate <NSObject>

@optional
- (void)dropDownMenu:(DSH_DropDownMenu *)dropDownMenu didSectedRowAtSection:(NSInteger)seciton row:(NSInteger)row;

@end




@interface DSH_DropDownMenu : UIView

// 记录菜单栏 开合状态
@property (nonatomic) BOOL isOpen;
// 记录当前选择的组
@property (nonatomic,assign) NSInteger currentGroup;
// 菜单栏标题数组
@property (strong,nonatomic)NSArray *titles;

@property (weak,nonatomic) id <DSH_DropDownMenuDataSource> dataSource;
@property (weak,nonatomic) id <DSH_DropDownMenuDelegate> delegate;

/// 展开 关闭 tableview 操作
- (void)closeMenu;
- (void)expandMenu;

@end

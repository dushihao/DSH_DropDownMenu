//
//  DSH_DropDowmMenu.m
//  DSH_DropDownMenu
//
//  Created by 杜世豪 on 2017/5/12.
//  Copyright © 2017年 杭州秋溢科技有限公司. All rights reserved.
//

#import "DSH_DropDownMenu.h"


@interface SH_WarpperView : UIView
@end
@implementation SH_WarpperView
@end

@interface SH_Button : UIButton
@end
@implementation SH_Button

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    
    // image 与 button  左侧间距
    CGFloat margin = imageRect.origin.x;
    
    // 系统默认的格式是："image + title"
    // 现在需求是："title + image"
    /*做法：
     因为： image 和 title 分别与 button 的左间距和右间距相同，二者相邻且居中
     所以： 通过间距，颠倒 image title 的位置
     */
    imageRect.origin.x = CGRectGetMaxX(contentRect) - (imageRect.size.width + margin) + 2;
    
    return imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    //title 与 button 右间距
    CGFloat margin = contentRect.size.width - (titleRect.origin.x + titleRect.size.width);
    
    // image  title  各向边界移动2点距离，间隔为4
    titleRect.origin.x = margin -2;
    
    return titleRect;
}

@end

@interface DSH_DropDownMenu()<UITableViewDelegate,UITableViewDataSource>

/// UI
// warpperView
@property (nonatomic) SH_WarpperView *dshWarpperView;
// 蒙板
@property (nonatomic) UIControl *dshMaskView;

// 下拉菜单
@property (nonatomic) UITableView *dshMenuTableView;

@property (strong,nonatomic)SH_Button *currentSelectBtn;



//标题 按钮数组
@property (nonatomic,strong)NSArray *btnsArray;

// tableView 高度约束
@property (nonatomic,strong)NSLayoutConstraint *tableViewHeightConstraint;

@end


@implementation DSH_DropDownMenu




// 初始化

- (instancetype)initWithFrame:(CGRect)frame{
    if (self  = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    //界面配置信息
}

# pragma mark == set get  method
- (UITableView *)dshMenuTableView{
    if (!_dshMenuTableView) {
        _dshMenuTableView = [UITableView new];
        _dshMenuTableView.delegate = self;
        _dshMenuTableView.dataSource = self;
        _dshMenuTableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _dshMenuTableView;
}

- (void)didMoveToWindow{
    
    //配置menuBar
    [self creatMenuViewWithTitles:[self.dataSource sectionTitlesWithdropDownMenu:self]];
    //配置dimingview tableview warpperview
    [self creatMenuView];
}

- (void)creatMenuViewWithTitles:(NSArray *)titles{
    
    if (titles.count <= 0) return; //数组元素个数必须大于零
    
    NSMutableArray *btnArray = [NSMutableArray arrayWithCapacity:titles.count];
    for (int i = 0 ; i<titles.count;i++) {
        SH_Button *btn = [SH_Button new];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        
        //设置标题颜色
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        //设置背景
        [btn setImage:[[UIImage imageNamed:@"down_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [btn setImage:[[UIImage imageNamed:@"up_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        
        [self addSubview: btnArray[i] = btn];
        
        NSDictionary *views = nil;
        if (i==0) {
            views =  NSDictionaryOfVariableBindings(btn);
        }else{
            UIButton *leftBtn = btnArray[i-1];
            views =  NSDictionaryOfVariableBindings(leftBtn,btn);
        }
        
        NSString *visuals[2] = {@"V:|[btn]-1-|"};
        if (i==0) {
            //左侧
            visuals[1] = titles.count == 1 ? @"H:|[btn]|" : @"H:|[btn]" ;
        }else if (i<=titles.count-2){
            //中间
            visuals[1] = @"H:[leftBtn][btn(leftBtn)]";
        }else{
            //右侧
            visuals[1] = @"H:[leftBtn][btn(leftBtn)]|";
        }
        
        for (int i =0 ; i<2; i++) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visuals[i] options:kNilOptions metrics:nil views:views]];
        }
    }
    
    self.btnsArray = [btnArray copy];
}

- (void)creatMenuView{
    
    //warpperView
    SH_WarpperView *warpperView = [SH_WarpperView new];
    warpperView.hidden = YES;
    warpperView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dshWarpperView = warpperView;
    
    //蒙板
    UIControl *maskView = [UIControl new];
    maskView.translatesAutoresizingMaskIntoConstraints = NO;
    [maskView addTarget:self action:@selector(maskViewDidTap) forControlEvents:UIControlEventTouchUpInside];
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.dshMaskView = maskView;
    
    UIViewController *vc = [self currentViewController];
    
    UIView
    *vcView = vc.view,
    *tableView = self.dshMenuTableView;
    
    [warpperView addSubview:maskView];
    [warpperView addSubview:tableView];
    [vcView addSubview:warpperView];
    
    //添加约束
    id<UILayoutSupport> bottomGuide = vc.bottomLayoutGuide;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(self,bottomGuide,maskView,tableView,warpperView);
    
    NSString *vivsuls[6] = {
        @"V:[self][warpperView][bottomGuide]",
        @"H:|[warpperView]|",
        
        @"V:|[maskView]|",
        @"H:|[maskView]|",
        
        @"V:|[tableView]",
        @"H:|[tableView]|"};
    
    for (int i = 0; i< 6; i++) {
        [vcView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vivsuls[i] options:kNilOptions metrics:nil views:views]];
    }
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [tableView addConstraint:constraint];
    
    self.tableViewHeightConstraint = constraint;
    
}

// 点击方法实现
- (void)buttonClick:(SH_Button *)btn{
    //1 处理tableview的开合 2 处理点击按钮状态的改变
    btn.selected = !btn.selected;
    self.currentGroup = btn.tag;
    
    if (btn == self.currentSelectBtn) {
        self.isOpen ? [self closeMenu]:[self expandMenu];
    }else{
        self.currentSelectBtn.selected = NO;
        
        [self expandMenu];
    }
    
    self.currentSelectBtn = btn;
    
}
- (void)maskViewDidTap{
    self.currentSelectBtn.selected = NO;
    [self closeMenu];
}

- (void)refreshMenu{
    
    [self.dshMenuTableView reloadData];
}

- (void)closeMenu{
    
    //关闭动画
    self.dshMaskView.alpha = 0;
    self.tableViewHeightConstraint.constant  = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.dshWarpperView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isOpen = NO;
        
        self.currentGroup = NSNotFound; //滞空
        self.currentSelectBtn.selected = NO;
        self.currentSelectBtn = nil; // 滞空
        self.dshWarpperView.hidden = YES;
    }];
    
}

- (void)expandMenu{
    //展开动画
    self.dshMaskView.alpha = 1;
    self.dshWarpperView.hidden = NO;
    self.tableViewHeightConstraint.constant = 0;
    
   // [self.dshWarpperView layoutIfNeeded]; // 解注释 -> 重新展开的效果不同
    
    
    self.tableViewHeightConstraint.constant = [self.dataSource dropDownMenu:self MenusInSection:self.currentGroup].count * 44;
    
    CGFloat  maxHeight = [UIScreen mainScreen].bounds.size.height - 64 - 40 ;
    //对高度 进行处理 不能超过 屏幕底部
    self.tableViewHeightConstraint.constant = self.tableViewHeightConstraint.constant > maxHeight ? maxHeight : self.tableViewHeightConstraint.constant ;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 1;
        [self.dshWarpperView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isOpen = YES;
    }];
    
    //刷新数据源
    [self.dshMenuTableView  reloadData];
}

#pragma mark == tableView Delegate ==

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *contentArray = [self.dataSource dropDownMenu:self MenusInSection:self.currentGroup];
    
    return contentArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *contentArray = [self.dataSource dropDownMenu:self MenusInSection:self.currentGroup];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
         cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = contentArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:didSectedRowAtSection:row:)]) {
        
        [self.delegate dropDownMenu:self didSectedRowAtSection:self.currentGroup row:indexPath.row];
    }
    
    [self closeMenu];
}

//获取当前控制器
- (UIViewController *)currentViewController{
    
    UIResponder *responder = self.nextResponder;
    
    for (Class cls = [UIViewController class]; responder && ![responder isKindOfClass:cls];) {
        responder = responder.nextResponder;
    }
    return (UIViewController * _Nullable)responder;
}

@end

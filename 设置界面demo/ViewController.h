//
//  ViewController.h
//  设置界面demo
//
//  Created by douxindong on 16/7/11.
//  Copyright © 2016年 douxindong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *outBtn;

- (IBAction)clickBtn:(id)sender;
@end


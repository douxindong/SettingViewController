//
//  ViewController.m
//  设置界面demo
//
//  Created by douxindong on 16/7/11.
//  Copyright © 2016年 douxindong. All rights reserved.
//
#import "ViewController.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,
                              UIAlertViewDelegate>
@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, strong) UIAlertView *alertView;
@property(nonatomic, strong) NSString *garbage;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _titleArray = @[ @"检查更新", @"清除缓存" ];
  _tableView.showsHorizontalScrollIndicator = NO;
  _tableView.showsVerticalScrollIndicator = NO;
  _tableView.scrollEnabled = NO;

  self.garbage = nil;
    [self getFolderSize];
  [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}
- (void)getFolderSize {
  float folderSize = [self
      floatWithPath:[NSSearchPathForDirectoriesInDomains(
                        NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
  if (folderSize > 0 && folderSize < 1280000) {
    self.garbage = [NSString stringWithFormat:@"%.2fM", folderSize];
  } else {
    self.garbage = nil;
  }
  [_tableView reloadData];
}
- (CGFloat)floatWithPath:(NSString *)path {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  float folderSize;
  if ([fileManager fileExistsAtPath:path]) {
    NSArray *childerFiles = [fileManager subpathsAtPath:path];
    for (NSString *filename in childerFiles) {
      NSString *fullPath = [path stringByAppendingPathComponent:filename];
      folderSize += [self fileSizeAtPath:fullPath];
    }
  }
  return folderSize;
}
- (float)fileSizeAtPath:(NSString *)path {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:path]) {
    long long size =
        [fileManager attributesOfItemAtPath:path error:nil].fileSize;
    return size / 1024.0 / 1024.0;
  }
  return 0;
}
- (UITableViewCell *)infomationCell:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"settingCell";
  UITableViewCell *cell =
      [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:cellIdentifier];
  }
  cell.textLabel.font = [UIFont systemFontOfSize:14];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self infomationCell:indexPath];
  if (indexPath.row == 0) {
    cell.textLabel.text = _titleArray[0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else if (indexPath.row == 1) {
      cell.textLabel.text = _titleArray[1];
    if (self.garbage) {
      cell.detailTextLabel.text = self.garbage;
    } else {
      cell.detailTextLabel.text = @"正在计算缓存大小";
    }
  }
    cell.backgroundColor = [UIColor whiteColor];
  return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50;
}
- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  return 50;
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            [self onCheckVersion];
            //[[MessageBox sharedInstance] show:@"已是最新版本"];
            } else if (indexPath.row == 1) {
                NSLog(@"点击清除缓存");
                if (self.garbage) {
                    self.alertView = [[UIAlertView alloc]initWithTitle:@"清理缓存"message:[NSString stringWithFormat:@"缓存大小为%@,"@"确定要清理缓存吗?",self.garbage]delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"确定", nil];
                    [self.alertView show];
                    self.alertView.delegate = self;
                   }
                 }
  
    } else {
                NSLog(@"点击退出登录");
           }
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.alertView == alertView) {
        if (buttonIndex == 1) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                for (NSString *p in files) {
                    NSError *error;
                    NSString *path = [cachPath stringByAppendingPathComponent:p];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                    }
                }
                [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
            });
        }
    }
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
- (void)clearCacheSuccess {
    if (self.garbage == 0) {
        NSLog(@"最好在这里加个alertView,已经全部清除");
    } else {
        [self getFolderSize];
    }
}
- (void)onCheckVersion {
  NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
  NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
  NSString *URL = @"http://itunes.apple.com/lookup?id=app的id";
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:[NSURL URLWithString:URL]];
  [request setHTTPMethod:@"POST"];
  NSHTTPURLResponse *urlResponse = nil;
  NSError *error = nil;
  NSData *recerveData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&urlResponse
                                                          error:&error];
  NSString *results = [[NSString alloc] initWithBytes:[recerveData bytes]
                                               length:[recerveData length]
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"%@",results);
  //模型转化,使用时把 NSDictionary *dic = nil
  //替换为注释里面的语句,转化模型自己处理
  /*
   NSDictionary *dic = [results jsonValueDecoded];
   */
  NSDictionary *dic = nil;
  NSArray *infoArray = [dic objectForKey:@"results"];
  if ([infoArray count]) {
    NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
    NSString *lastVersion = [releaseInfo objectForKey:@"version"];

    if (![lastVersion isEqualToString:currentVersion]) {
      UIAlertView *alert = [[UIAlertView alloc]
              initWithTitle:@"更新"
                    message:@"有新的版本更新，是否前往更新？"
                   delegate:self
          cancelButtonTitle:@"关闭"
          otherButtonTitles:@"更新", nil];
      alert.tag = 10000;
      [alert show];
    } else {
      // todo
      /*
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新"
       message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定"
       otherButtonTitles:nil, nil];
       alert.tag = 10001;
       [alert show];
       */
    }
  } else {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"更新"
                                   message:@"此版本为最新版本"
                                  delegate:self
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil, nil];
    alert.tag = 10001;
    [alert show];
  }
}
- (IBAction)clickBtn:(id)sender {
  [self userLoginOut];
}
- (void)userLoginOut {
  NSLog(@"点击退出登录");
}
@end

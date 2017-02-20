//
//  ViewController.h
//  BlockTest
//
//  Created by 贾则栋 on 17/2/20.
//  Copyright © 2017年 贾则栋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// 属性声明的block都是全局的__NSGlobalBlock__
@property (nonatomic, copy) void (^copyBlock)();
@property (nonatomic, weak) void (^weakBlock)();

@end


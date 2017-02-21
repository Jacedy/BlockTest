//
//  ViewController.m
//  Blockself
//
//  Created by 贾则栋 on 17/2/20.
//  Copyright © 2017年 贾则栋. All rights reserved.
//

#import "ViewController.h"
#import "Test.h"

typedef void (^blockSave)(void);

typedef void (^typedefBlock)(void);

void (^outFuncBlock)(void) = ^{
    NSLog(@"someBlock");
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *str3 = @"1234";
    NSLog(@"block is %@", ^{NSLog(@":%@", str3);});     // __NSStackBlock__
    
#pragma mark - 当全局block引用了外部变量，ARC机制优化会将Global的block,转为Malloc（堆）的block进行调用。
    
    __block int age = 20;
    int *ptr = &age;
    // ARC下
    blockSave x = ^{
        NSLog(@"(++age):%d", ++age);    // 变量前不加__block的情况下，会报错，变量的值只能获取，不能更改
    };
    blockSave y = [x copy];
    y();
    NSLog(@"x():%@, y():%@ , (*ptr):%d", x, y, *ptr);
    // MRC下
    Test *test = [[Test alloc] init];
    [test test];
    [test exampleB];
    
    /**总结：
     ARC下：(++age):21   (*ptr):20    // blockSave在堆中，*ptr在栈中
     MRC下：(++age):21   (*ptr):21    // blockSave和*ptr都在栈中
     */
    
#pragma mark - copyBlock （使用函数内变量） __NSMallocBlock__
    
    self.copyBlock = ^{
        age = age+1-1;
    };
    NSLog(@"1：%@", self.copyBlock);
    
#pragma mark - copyBlock（未使用函数内变量）
    
    self.copyBlock = ^{
        
    };
    NSLog(@"2：%@", self.copyBlock);
    
#pragma mark - weakBlock（未使用函数内变量）
    
    self.weakBlock = ^{
        
    };
    NSLog(@"3：%@", self.weakBlock);
    
#pragma mark - weakBlock（使用函数内变量） __NSStackBlock__
    
    self.weakBlock = ^{
        age = age+1-1;
    };
    NSLog(@"4：%@", self.weakBlock);
    
#pragma mark - someBlock（定义在函数体外）
    
    NSLog(@"5：%@", outFuncBlock);
    
#pragma mark - typedefBlock（函数体外自定义的Block）
    
    typedefBlock b = ^{
        
    };
    NSLog(@"6：%@", b);
    
#pragma mark - 对栈中的block进行copy
    // 不引用外部变量，定义在全局区、表达式没有使用到外部变量时，生成的block都是__NSGlobalBlock__类型
    void (^testBlock1)() = ^(){
        
    };
    NSLog(@"testBlock1: %@", testBlock1);
    
    // 引用外部变量 -- ARC下默认对block进行了copy操作，所以这里是__NSMallocBlock__类型
    void (^testBlock2)() = ^(){
        age = age+1-1;
    };
    NSLog(@"testBlock2: %@", testBlock2);
    
    
    // Blocks提供了将Block和__block变量从栈上复制到堆上的方法来解决变量作用域结束时销毁的问题，堆上的Block会依然存在。
    
    
    /*那么什么时候栈上的Block会复制到堆上呢？
     1.调用Block的copy实例方法时
     2.Block作为函数返回值返回时
     3.将Block赋值给附有__strong修饰符id类型的类或Block类型成员变量时
     4.将方法名中含有usingBlock的Cocoa框架方法或GCD的API中传递Block时
     
     在使用__block变量的Block从栈上复制到堆上时，__block变量也被从栈复制到堆上并被Block所持有。
     */
    
    
    /*block里面使用self会造成循环引用吗？
     
     1.很显然答案不都是，有些情况下是可以直接使用self的，比如调用系统的方法：
     [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"%@", self);
     }];
     因为这个block存在于静态方法中，虽然block对self强引用着，但是self却不持有这个静态方法，所以完全可以在block内部使用self。
     
     2.当block不是self的属性时，self并不持有这个block，所以也不存在循环引用
     void(^block)(void) = ^() {
        NSLog(@"%@", self);
     };
     block();
     
     3.大部分GCD方法:
     dispatch_async(dispatch_get_main_queue(), ^{
        [self doSomething];
     });
     因为self并没有对GCD的block进行持有，没有形成循环引用。
     
     4.
     
     只要我们抓住循环引用的本质，就不难理解这些东西。
     */
}

@end

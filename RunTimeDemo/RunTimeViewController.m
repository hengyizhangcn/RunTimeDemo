//
//  RunTimeViewController.m
//  RunTimeDemo
//
//  Created by zhy on 18/05/2017.
//  Copyright © 2017 UAMA. All rights reserved.
//

#import "RunTimeViewController.h"
#import <objc/runtime.h>

@interface RunTimeViewController ()

@property (nonatomic) NSInteger age;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) NSString *address;
@end

@implementation RunTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = @"低收入者";
    
    NSLog(@"%@", objc_getClass(NSStringFromClass([UITableView class]).UTF8String)); //1.获取UITableView类
//   objc_getClass内的参数只能是const Char *类型
    
    NSLog(@"%@", NSClassFromString(NSStringFromClass([UITableView class]))); //2.同1
    
    NSLog(@"%@", object_getClass(descLabel));
    
//    NSLog(@"%@", object_setClass(descLabel, [NSDictionary class]));
    
    self.age = 18;
    self.name = @"Michael";
    
    NSLog(@"%@", object_getClass(descLabel));
    
    NSLog(@"%d", object_isClass(self.name)); //object_isClass里面必须是对象
    
    Ivar myvar = class_getInstanceVariable([self class], "_name");
    
    NSLog(@"%@", object_getIvar(self, myvar)); //如果想获取age，此行会出错，因为%@只打印对象
    
    object_setIvar(self, myvar, @"xiaozuanfeng"); //设置unsafe_unretained类型的变量
    object_setIvarWithStrongDefault(self, myvar, @"weather"); //设置strong类型的变量
    
    NSLog(@"%@", self.name);
    
    Class metaClassObj = objc_getMetaClass(NSStringFromClass([UILabel class]).UTF8String);
    NSLog(@"%p", metaClassObj);
    NSLog(@"%p", object_getClass([UILabel class]));
    NSLog(@"%d", class_isMetaClass(metaClassObj));
    
//    class_setSuperclass([descLabel class], [UIButton class]);
    
    Class instanceClass = object_getClass(descLabel); //类实例->类对象
    NSLog(@"%p", instanceClass);
    NSLog(@"%@", instanceClass);
    NSLog(@"superClass:%@", class_getSuperclass(instanceClass));
    NSLog(@"%d", class_isMetaClass(instanceClass));
    
    Class metaClass = object_getClass(instanceClass); //类对象->元类对象
    NSLog(@"%p", metaClass);
    NSLog(@"%@", metaClass);
    NSLog(@"superClass:%@", class_getSuperclass(metaClass));
    NSLog(@"%d", class_isMetaClass(metaClass));
    
    Class rootClass = object_getClass(metaClass); //元类对象->根类对象
    NSLog(@"%p", rootClass);
    NSLog(@"%@", rootClass);
    NSLog(@"superClass:%@", class_getSuperclass(rootClass));
    NSLog(@"%@", object_getClass(rootClass));
    NSLog(@"%d", class_isMetaClass(rootClass));
    
    NSLog(@"%@", objc_lookUpClass("UILabel")); //该方法不会调用class handler callback
    NSLog(@"%@", objc_getRequiredClass("UILabel")); //与objc_getClass相同，但是类不存在会终止进程
    
    int numClasses;
    Class * classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses); //获取iOS系统中，可用类列表
        
        for (int i = 0; i < numClasses; i++) {
//            NSLog(@"Class name:%s", class_getName(classes[i]));
        }
//        NSLog(@"total number:%d", numClasses);
        free(classes);
    }
    
    unsigned totalClass = 0;
    Class *classList = objc_copyClassList(&totalClass); //复制iOS系统中可用类列表，赋值后需要进行释放
    if (totalClass > 0) {
        NSString *filePath = @"/Users/zhy/Desktop/ClassList";
        NSMutableArray *classNameArray = [NSMutableArray new];
        for (int i = 0; i < totalClass; i ++) {
//            NSLog(@"Class name:%s", class_getName(classList[i]));
            
            NSString *className = [NSString stringWithFormat:@"%s", class_getName(classList[i])];
            [classNameArray addObject:className];
        }
        
        NSString *classNameStr = [classNameArray componentsJoinedByString:@"\n"];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSData *data = [classNameStr dataUsingEncoding:NSUTF8StringEncoding];
        if ([manager fileExistsAtPath:filePath]) {
//            [data writeToFile:filePath options:NSDataWritingWithoutOverwriting error:nil];
            [data writeToFile:filePath atomically:YES];
        } else {
            [manager createFileAtPath:filePath contents:data attributes:nil];
        }
        NSLog(@"total number:%d", totalClass);
    }
    free(classList);
    
<<<<<<< HEAD:RunTimeDemo/ViewController.m
    
=======
    class_setVersion([UILabel class], 5);
    
    NSLog(@"%d", class_getVersion([UILabel class]));
>>>>>>> 08d72073f592240a99e9e74d0e706143011c9ec9:RunTimeDemo/RunTimeViewController.m
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

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

@property (class) NSInteger height;

@property (nonatomic) NSInteger age;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) NSString *address;

@end

@implementation RunTimeViewController

static NSInteger _height = 0;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        Class class = object_getClass((id)self); //替换类方法
//        SEL originalSelector = @selector(setHeight:);
//        SEL swizzledSelector = @selector(setTemproaryHeight:);
        
        Class class = [self class]; //替换实例方法
//        SEL originalSelector = @selector(setName:);
//        SEL swizzledSelector = @selector(setTemproary:);
        SEL originalSelector = NSSelectorFromString(@"getWeather");
        SEL swizzledSelector = NSSelectorFromString(@"getCalendar");
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) { //说明该方法没被实现，需要替换方法
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else { //该方法有实现，需要替换实现
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)getWeather
{
    
}

- (void)getCalendar
{
    NSLog(@"%@", [NSDate date]);
}

- (void)setTemproary:(NSString *)temproary
{
    _name = temproary;
    NSLog(@"_name:%@", temproary);
}

+ (void)setTemproaryHeight:(NSInteger)temproary
{
    _height = temproary;
    NSLog(@"_height:%ld", temproary);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name = @"zhy";
    RunTimeViewController.height = 20;
    
    [self runtimeLearn];
}


- (void)runtimeLearn {
    const char * className = "Calculator";
    Class kclass = objc_getClass(className);
    if (!kclass)
    {
        Class superClass = [NSObject class];
        kclass = objc_allocateClassPair(superClass, className, 0);
    }
    
    NSUInteger size;
    NSUInteger alignment;
    NSGetSizeAndAlignment("*", &size, &alignment);
    [self class_addIvar:kclass name:"country" size:size alignment:alignment types:"*"];
    class_addMethod(kclass, @selector(setExpressionFormula:), (IMP)setExpressionFormula, "v@:@");
    class_addMethod(kclass, @selector(getExpressionFormula), (IMP)getExpressionFormula, "@@:");
    
//    d.注册到运行时环境
    objc_registerClassPair(kclass);
//    e.实例化类
    id instance = [[kclass alloc] init];
//    f.给变量赋值
    Ivar country = class_getInstanceVariable(kclass, "country");
    object_setIvar(kclass, country, @"China");
    
    id countryStr = object_getIvar(kclass, country);
    
    NSLog(@"country:%@", countryStr);
    
//    object_setInstanceVariable(instance, "expression", "1+1");, 在arc下不能使用，可使用object_setIvar代替
////    g.获取变量值
//    void * value = NULL;
//    object_getInstanceVariable(instance, "expression", &value);, 在arc下不能使用，可使用object_getIvar代替
//    h.调用函数
    
    
    /*
     * 在此处调用会产生runloop崩溃CFRUNLOOP is calling out to a source0 perform function
     */
    [instance performSelector:@selector(getExpressionFormula)];
}

static void setExpressionFormula(id self, SEL cmd, id value)
{
    NSLog(@"call setExpressionFormula");
}

static void getExpressionFormula(id self, SEL cmd)
{
    NSLog(@"call getExpressionFormula");
}

- (void)class_addIvar:(Class)class name:(const char *)name size:(size_t)size alignment:(uint8_t)alignment types:(const char *)types {
    
    //    if (class_addIvar([_person class], "country", sizeof(NSString *), 0, "@")) {
    if (class_addIvar(class, name, size, alignment, types)) {
        
        NSLog(@"%sadd ivar success",__func__);
    }else{
        NSLog(@"%sadd ivar fail",__func__);
    }
}

- (void)runtimeLearn0 {
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
    
    class_setVersion([UILabel class], 5);
    
    NSLog(@"%d", class_getVersion([UILabel class]));
    
    NSLog(@"%zu", class_getInstanceSize([self class]));
    
    RunTimeViewController.height = 30;
    Ivar classIvar = class_getClassVariable([RunTimeViewController class], "height");
    
    NSLog(@"%ld", (NSInteger)object_getIvar([RunTimeViewController class], classIvar));
    NSLog(@"%ld", (long)RunTimeViewController.height);
    
    unsigned int outCount = 0;
    Ivar *labelIvar = class_copyIvarList([UILabel class], &outCount);
    for (int index = 0; index < outCount; index++) {
//        NSLog(@"%s", ivar_getName(labelIvar[index]));
//        NSLog(@"%s", ivar_getTypeEncoding(labelIvar[index]));
        //type定义参考：https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
//        NSLog(@"");
    }
    
    Method *methodList = class_copyMethodList([UILabel class], &outCount);
    for (int i = 0; i< outCount; i ++ ) {
        Method method = methodList[i];
        NSLog(@"%s", sel_getName(method_getName(method)));
        NSLog(@"returnType:%s", method_copyReturnType(method));
        struct objc_method_description *method_description = method_getDescription(method);
        NSLog(@"%s", sel_getName(method_description->name));
        NSLog(@"%s", method_description->types);
        NSLog(@"%s", method_getTypeEncoding(method));
        char dst[100];
        method_getReturnType(method, dst, 100);
        NSLog(@"returnType:%s", dst);
        NSLog(@"\n\n");
    }
    
    NSLog(@"%s", class_getIvarLayout([self class])); //uint8应该是无符号8位二进制整型，其实就是unsigned char类型
    NSLog(@"%s", class_getWeakIvarLayout([self class]));
}


+ (void)setHeight:(NSInteger)height
{
    _height = height;
}

+ (NSInteger)height
{
    return _height;
}
@end

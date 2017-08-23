//
//  RunTimeViewController.m
//  RunTimeDemo
//
//  Created by zhy on 18/05/2017.
//  Copyright © 2017 UAMA. All rights reserved.
//

#import "RunTimeViewController.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>


static void setFlyHeight(id self, SEL cmd, float height);
void changeCheck(__strong id name);

@interface RunTimeViewController ()

@property (class) NSInteger height;

@property (nonatomic) NSInteger age;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) NSString *address;

@end

@implementation RunTimeViewController

static NSInteger _height = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name = @"zhy";
    RunTimeViewController.height = 20;
    
    objc_setAssociatedObject(self, "city", @"Washington", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self runtimeLearn];
}

/**
 OC 语言特性language feature
 */
- (void)runtimeLearn
{
    
    void (*handler)(id) = changeCheck; //函数指针变量
    
    NSNumber *index = @90;
    
    objc_setEnumerationMutationHandler(handler);
    objc_enumerationMutation(index); //监控对象的变化，注意：objc_setEnumerationMutationHandler需要先设置，不然会引起内部错误
    index = @80; //这句话执行后，会调用changeCheck
    
    IMP myIMP = imp_implementationWithBlock(^(id argument){ //创建一个指向block的指针
        NSLog(@"new implementation: %@", argument);
    });
    method_setImplementation(class_getInstanceMethod([self class], @selector(runtimeLearn)), myIMP);
    [self runtimeLearn]; //这里不会死循环
    
    void (^myBlock)(id) = imp_getBlock(myIMP); //获取imp_implementationWithBlock绑定的block
    myBlock(@"34"); //打印new implementation: 34
    
}

void changeCheck(id name) {
    if ([name isKindOfClass:[NSString class]]) {
        printf("%s", [((NSString *)name) cStringUsingEncoding:NSUTF8StringEncoding]);
    } else if ([name isKindOfClass:[NSNumber class]]) {
        printf("%ld", ((NSNumber *)name).integerValue);
    }
//    printf("%@", name);
}
/**
 协议, property
 */
- (void)runtimeLearnProtocolAndProperty {
    Protocol *copyProtocol = objc_getProtocol("NSCopy");
    [self conformsToProtocol:copyProtocol];
    
    unsigned int outCount = 0;
    
    __unsafe_unretained Protocol ** list = objc_copyProtocolList(&outCount); //共791个协议
    for (int i = 0; i < outCount; i++) {
        Protocol *tempProtocol = list[i];
//        NSLog(@"%@", NSStringFromProtocol(tempProtocol));
    }
    free(list);
    
    Protocol *planeFlyProtocol = objc_allocateProtocol("planeFlyProtocol");
    protocol_addMethodDescription(planeFlyProtocol, @selector(setFlyHeight:), "v24@0:8f16", YES, YES);//给实例添加一个必须的方法
    protocol_addMethodDescription(planeFlyProtocol, @selector(setExpressionFormula:), "v@:@", YES, YES);
    objc_property_attribute_t *atomicAttribute = (objc_property_attribute_t *)malloc(sizeof(objc_property_attribute_t *));
    atomicAttribute->name = "N";
    atomicAttribute->value = "";
    objc_property_attribute_t *weakAttribute = (objc_property_attribute_t *)malloc(sizeof(objc_property_attribute_t *));
    weakAttribute->name = "C";
    weakAttribute->value = "";
    objc_property_attribute_t *readAttribute = (objc_property_attribute_t *)malloc(sizeof(objc_property_attribute_t *));
    readAttribute->name = "R";
    readAttribute->value = "";
    objc_property_attribute_t *typeAttribute = (objc_property_attribute_t *)malloc(sizeof(objc_property_attribute_t *));
    typeAttribute->name = "T";
    typeAttribute->value = "@\"NSString\"";
    objc_property_attribute_t *varAttribute = (objc_property_attribute_t *)malloc(sizeof(objc_property_attribute_t *));
    varAttribute->name = "V";
    varAttribute->value = "_windSpeed";
    //http://blog.csdn.net/myzlk/article/details/50815381
    
    objc_property_attribute_t attributes[] = {*typeAttribute, *weakAttribute, *atomicAttribute, *readAttribute, *varAttribute};
//    objc_property_attribute_t attributes[] = {{"&","N"},{"T", "@\"NSString\""}, {"V", ""}}; //这样写更方便
    protocol_addProperty(planeFlyProtocol, "windSpeed", attributes, 5, YES, YES); //给实例添加一个可选的属性
    protocol_addProtocol(planeFlyProtocol, objc_getProtocol("UITableViewDelegate")); //后一个协议必须在运行时注册过
    objc_registerProtocol(planeFlyProtocol); //协议在创建后调用此方法，一旦成功，将不可变而且可以使用，即所有对协议的改动应该在注册之前
    
    
//    Protocol *planeFlyProtocol = objc_getProtocol("planeFlyProtocol");
    
    protocol_getName(planeFlyProtocol); //"planeFlyProtocol"
    
    protocol_isEqual(planeFlyProtocol, objc_getProtocol("UITableViewDelegate")); //NO
    
    unsigned int methodCount;
    struct objc_method_description *methodDescription = protocol_copyMethodDescriptionList(planeFlyProtocol, YES, YES, &methodCount);
    for (int i = 0; i < methodCount; i ++) {
        struct objc_method_description temp = methodDescription[i];
        NSLog(@"%@, %s", NSStringFromSelector(temp.name), temp.types);
    }
    
//    unsigned int outCount = 0;
    const objc_property_t *propertyList = protocol_copyPropertyList(planeFlyProtocol, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t tempAttribute = propertyList[i];
        NSLog(@"%s", property_getName(tempAttribute));
        property_getAttributes(tempAttribute); //"T@"NSString",C,N,R,V_windSpeed"，其中N代表nonatomic,&代表retain/strong，
        //类型编码：        https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1
        property_copyAttributeValue(tempAttribute, property_getName(tempAttribute)); //
        
        unsigned int attributeCount;
        objc_property_attribute_t *attributeList = property_copyAttributeList(tempAttribute, &attributeCount);
        for (int i = 0; i < attributeCount; i ++) {
            objc_property_attribute_t attribute = attributeList[i];
            NSLog(@"%s, %s", attribute.name, attribute.value);
        }
    }
    
    class_getProperty([self class], "address");
    property_getAttributes(class_getProperty([self class], "viewLoaded"));//"TB,R,N,GisViewLoaded", type:bool, readonly, nonatomic, getter=isViewLoaded
    property_getAttributes(class_getProperty([self class], "address"));//"T@"NSString",W,N,V_address"，type:NSString, weak, nonatomic, var:_address
}

/**
 库、选择器、
 */
- (void)runtimeLearnLibraryAndSelector
{
    unsigned int outCount = 0;
    const char ** imageNames = objc_copyImageNames(&outCount); //iOS10，共59个框架和动态库
    for (int i = 0; i < outCount; i ++) {
        NSString *fileName = [NSString stringWithCString:imageNames[i] encoding:NSUTF8StringEncoding];
        NSURL *fileUrl = [NSURL fileURLWithPath:fileName];
//        NSLog(@"%@", fileUrl.lastPathComponent);
    }
    free(imageNames);
    
    class_getImageName([RunTimeViewController class]); //查询类的来源库
    
    const char ** classNames = objc_copyClassNamesForImage(class_getImageName([AVCaptureInput class]), &outCount);
    for (int i = 0; i < outCount; i ++) {
        NSLog(@"%s", classNames[i]); //如UIKit共2079个类，AVFoundation共399个类
    }
    free(classNames);
    
    sel_getName(@selector(setImage:));
    
    const char *name = [NSStringFromSelector(@selector(runtimeLearn3)) UTF8String];
    SEL registeredSel = sel_registerName(name);
    registeredSel = sel_getUid(name); //与sel_registerName方法相同
    sel_isEqual(registeredSel, @selector(runtimeLearn3)); //YES
}

/**
 变量、实例、方法
 */
- (void)runtimeLearn3 {
    
    NSNumber *place;
    
    object_setClass(place, [NSString class]);
    
    place = @"test";
    
    NSLog(@"%@", object_getClass(place));
    
    NSLog(@"%@", objc_lookUpClass("UIViewController")); //查询类是否注册， 并返回
    
//    objc_getRequiredClass("MYClassYourClass"); //如果找不到会崩溃
    
    NSLog(@"%@", objc_getAssociatedObject(self, "city"));
    
    Method runtimeMethod = class_getInstanceMethod([self class], @selector(setTemproary:));
    method_getName(runtimeMethod);
    IMP implementation = method_getImplementation(runtimeMethod);
    method_getTypeEncoding(runtimeMethod); //""v24@0:8@16"" v:void, 24:整个方法参数占位总长度，@0表示在offset为0的地方有个OC对象，即self自身，8（字节）:在offset为8的地方有个SEL,@16:代表在offset 16的地方有个oc类型，我们可以发现24为所有参数所占空间的和..
    //类型编码如下：https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
    method_copyReturnType(runtimeMethod); //v，代表void，比如q代表nsinteger(long long)，@代表OC对象
    method_copyArgumentType(runtimeMethod, 0); //其中0是index，代表第几个字节，如0的参数类型是@，1的参数类型是:代表SEL,2的参数类型是@
    char *returnType = (char *)malloc(sizeof(char *) * 2);
    method_getReturnType(runtimeMethod, returnType, 8); //注：应先给returnType分配内存空间,然后释放
    free(returnType);
    method_getNumberOfArguments(runtimeMethod);//3，不带参数的方法，默认有两个参数，id和SEL
    
    char *argumentType = (char *)malloc(sizeof(char *));
    method_getArgumentType(runtimeMethod, 0, argumentType, 8); //获取第*个的参数类型，如0的参数类型是@，1的参数类型是:代表SEL,2的参数类型是@
    free(argumentType);
    struct objc_method_description *methodDescription = method_getDescription(runtimeMethod);
    //methodDescription->name; //打印为"setTemproary:"
    //methodDescription->types;//"v24@0:8@16"，同method_getTypeEncoding(runtimeMethod)
    
    method_setImplementation(runtimeMethod, method_getImplementation(class_getInstanceMethod([self class], @selector(setAddress:))));
    [self setTemproary:@"this is come from Temproary"]; //调用此方法时，会打印“this is come from Temproary”
    method_exchangeImplementations(runtimeMethod, class_getInstanceMethod([self class], @selector(setAddress:)));
    [self setAddress:@"this is come from address"];
    //经过以上两步，方法的实现又给交换回来了
}

- (void)dealloc
{
    objc_setAssociatedObject(self, "city", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


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

- (void)setAddress:(NSString *)address
{
    _address = address;
}

+ (void)setTemproaryHeight:(NSInteger)temproary
{
    _height = temproary;
    NSLog(@"_height:%ld", temproary);
}


- (void)runtimeLearn2 {
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
        NSString *filePath = @"/Users/hengyi.zhang/Desktop/ClassList";
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

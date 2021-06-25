# ZZActionPipe

# 什么是ZZActionPipe？
ZZActionPipe是一款响应式的开发框架。通过ZZActionPipe即可以关联两个模块，又可以让两个模块互不依赖，从而达到高内聚低耦合的目的，极大增加模块的可服用性，可重构性。

通过使用pipe，可以轻松的将一个大功能进行拆分，并且包装成独立的，可复用的，功能模块。并可以任意组合。例如：
1、MVVM的响应式框架开发。
2、对Class无侵入式的AOP。
3、通知系统（全局响应链）。
4、更灵活的filter、map、reduce等。

# ZZActionPipe 的基本功能

## 1、注册selector
通过```registAction```方法注册一个selector，并用```action```来接受一个block，作为selector的响应体。
block要使用宏```pipe_createAction```来构造。
一个pipe可以注册多个selector
```objectivec
@protocol actionPipeProtocol <NSObject>
- (CGFloat)someFuncWithNumber:(NSInteger)number object:(id)objc;
@end

ZZActionPipe *pipe = [ZZActionPipe new];
id actionBlock = pipe_createAction(NSInteger number, id objc) {
      NSLog(@"number _ %ld , objc _ %@", number, objc);
      return 100.0;
};
pipe.registAction(@selector(someFuncWithNumber:object:)).action = block;
```
## 2、触发selector
通过注册后，pipe对象将视为拥有相应的方法，直接调用即可。如上述注册了```someFuncWithNumber:object:```，就可以直接触发。
```objectivec
CGFloat fReturn = [(id<actionPipeProtocol>)pipe someFuncWithNumber:999 object:@[@1, @2, @3]];
NSLog(@"result _ %f", fReturn);

//NSLog output
//number _ 999 , objc _ (1, 2, 3)
//result _ 100.000000
```
## 3、组合pipe
多个pipe可以相互组合，组合后的pipe将变成一个pipe链，使用链上任一pipe触发方法，链上注册了该方法的pipe将被逐一顺序执行，顺序将遵循组合时的顺序执行。若pipe中未注册该方法，则会跳过此pipe，执行下一个pipe。
```objectivec
@protocol actionPipeProtocol <NSObject>
- (void)someFunc2WithNumber:(CGSize)size object:(id)objc;
- (void)someFunc3;
@end

ZZActionPipe *pipe1 = [ZZActionPipe new];
ZZActionPipe *pipe2 = [ZZActionPipe new];
ZZActionPipe *pipe3 = [ZZActionPipe new];
  
pipe1.registAction(@selector(someFunc2WithNumber:object:)).action = pipe_createAction(CGSize size, id objc) {
    NSLog(@"pipe1 _ called size: %f %f , %@", size.height, size.width, objc);
};
    
pipe2.registAction(@selector(someFunc2WithNumber:object:)).action = pipe_createAction(CGSize size, id objc) {
    NSLog(@"pipe2 _ called size: %f %f , %@", size.height, size.width, objc);
};
    
pipe3.registAction(@selector(someFunc2WithNumber:object:)).action = pipe_createAction(CGSize size, id objc) {
    NSLog(@"pipe3 _ called size: %f %f , %@", size.height, size.width, objc);
};
    
pipe2.registAction(@selector(someFunc3)).action = pipe_createAction() {
    NSLog(@"someFunc3 called.");
};
    
[[pipe1 addPipe:pipe2] addPipe:pipe3]; //pipe 组合 pipe1 -> pipe2 -> pipe3
    
//使用pipe3触发pipe链上的方法
[(id<actionPipeProtocol>)pipe3 someFunc2WithNumber:(CGSize){10,20} object:@"hello"];

//使用pipe1触发pipe链上的方法
[(id<actionPipeProtocol>)pipe1 someFunc3];

//NSLog output
//pipe1 _ called size: 20.000000 10.000000 , hello
//pipe2 _ called size: 20.000000 10.000000 , hello
//pipe3 _ called size: 20.000000 10.000000 , hello
//someFunc3 called.
```
## 4、注册有条件的selector
注册selector时，可以给selector增加一些格外的限制，只有达到限制的条件，action才会被触发。调用```registAction```方法后，会返回一个```ActionRequirement```对象，通过设置```ActionRequirement```相应的配置，可以限制方法被触发的条件。例如：
#### 1. returnKindOf  &  returnNotNull
```returnKindOf```当返回值类型等于某个类时selector能被触发，  ```returnNotNull``` 当返回值不为空时selector能被触发
```objectivec
@protocol actionPipeProtocol <NSObject>
- (id)someFuncWithNumber:(NSInteger)number object:(id)objc;
@end

ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> new];
pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc) {
    id returnObjc = nil;
    if (objc == nil) {
        NSLog(@"pipe1 _ return nil.");
    }else if ([objc isKindOfClass:[NSArray class]]) {
        returnObjc = [NSDate date];
    }else {
        returnObjc = [NSObject new];
    }
    
    return returnObjc;
};


ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> new];
pipe2.registAction(@selector(someFuncWithNumber:object:))
        .returnKindOf([[NSDate date] class])   //上游pipe返回值为NSDate时，才会触发。
        .action = pipe_createAction(NSInteger number, id objc) {
    NSLog(@"pipe2 _ up steam return NSDate.");
    return nil;
};

ZZActionPipe<actionPipeProtocol> *pipe3 = [ZZActionPipe<actionPipeProtocol> new];
pipe3.registAction(@selector(someFuncWithNumber:object:))
        .returnNotNull()    //上游pipe返回值不为空时，才会触发。
        .action = pipe_createAction(NSInteger number, id objc) {
    NSLog(@"pipe3 _ up steam return not Null.");
    return nil;
};

[[pipe1 addPipe:pipe2] addPipe:pipe3];

[pipe3 someFuncWithNumber:0 object:nil];
//NSLog output
//pipe1 _ return nil.  （ pipe1中return nil，pipe2和pipe3未达到触发条件，所以不执行。）

[pipe2 someFuncWithNumber:0 object:@[@1,@2]];
//NSLog output
//pipe2 _ up steam return NSDate.  （ pipe1 return NSDate对象，达到pipe2触发条件，pipe2执行。 pipe2 return nil，未达到pipe3触发条件，pipe3不执行。）
    
[pipe1 someFuncWithNumber:0 object:@{@"a":@"aa"}];
//NSLog output
//pipe3 _ up steam return not Null.  （ pipe1 return NSObject对象，pipe2未执行，返回值传递给pipe3, 达到pipe3触发条件，pipe3执行。）

```
#### 2. paramKindOf  &  paramNotNull  
同上，判断入参是否等于某个类或入参是否为空，来确定是否触发selector。
```objectivec
ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> new];
pipe1.registAction(@selector(someFuncWithNumber:object:))
    .paramKindOf(2, [NSArray class]) //第二个参数是否是NSArray
    .action = pipe_createAction(NSInteger number, id objc) {

    id returnObjc = nil;
    NSLog(@"pipe1 _ param objc is Array.");
    return returnObjc;
};

[pipe1 someFuncWithNumber:0 object:@[@1, @2]];
//NSLog output
//pipe1 _ param objc is Array.
```
#### 3. state 
可以给selector设置一个```state```，配合```pipe.doWhithState()```方法，可以选择性的触发pipe链上特定的一个或多个selector。
```objectivec
ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> new];
pipe1.registAction(@selector(someFuncWithNumber:object:)).state(1) //设置state = 1
    .action = pipe_createAction(NSInteger number, id objc) {
    id returnObjc = nil;
    NSLog(@"pipe1 _ state 1.");
    return returnObjc;
};

ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> new];
pipe2.registAction(@selector(someFuncWithNumber:object:)).state(10) //设置state = 10
    .action = pipe_createAction(NSInteger number, id objc) {
    id returnObjc = nil;
    NSLog(@"pipe1 _ state 10.");
    return returnObjc;
};

[pipe1 addPipe:pipe2];
[pipe1.doWithState(1) someFuncWithNumber:0 object:nil];
//NSLog output
//pipe1 _ state 1.
//只触发了state = 1 的selector

[pipe1.doWithState(10) someFuncWithNumber:0 object:nil];
//NSLog output
//pipe1 _ state 10.
//只触发了state = 10 的selector

[pipe1.doWithState(1 | 10) someFuncWithNumber:0 object:nil];
//NSLog output
//pipe1 _ state 1.
//pipe1 _ state 10.
//state 为 1 或 10 的selector 可以触发
```
> 不使用```doWithState```的pipe调用将触发所有state的selector。
> 不设置state的selector将不受doWithState的限制。

## 5、actionProcess 响应过程对象
在pipe的调用过程中，我们可以通过```ActionProcess```来获取上游的信息，同时可以影响下游获取到的信息。
在pipe的selector执行过程中，可以通过```[ActionProcess getCurrentActionProcess]```来获取对应的ActionProcess对象。
```objectivec
pipe.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
        ActionProcess *process = [ActionProcess getCurrentActionProcess];
        return nil;
};
```
下面看一下```ActionProcess```有哪些能力。

#### 1.向下游增加额外信息
```ActionProcess```中包含一个```JDTuple```对象，通过这个对象可以向下游扩展任意信息。（关于```JDTuple```可以看我之前的文章）
当```selector```设定的参数不足以完成一个逻辑的时候，可以通过向下扩展信息的方式传递参数。
```objectivec
ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> new];
pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
    ActionProcess *process = [ActionProcess getCurrentActionProcess];
    
    NSDate *date = [NSDate date];
    NSString *str = [NSString stringWithFormat:@"Robot No.%ld birth day", number];
    process.tmpTuple = jd_tuple(date, str); //向下游增加两个对象
    return nil;
};

ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> new];
pipe2.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, NSArray *arr){
    ActionProcess *process = [ActionProcess getCurrentActionProcess];
    JDTuple *tuple = process.tmpTuple; //获取额外信息
    __block id returnObjc = nil;
    jd_unpack(tuple)^(NSDate *date, NSString *str) {
        NSLog(@"%@ _ %@", str, date);
        returnObjc = date;
    };
    
    return returnObjc;
};

[pipe1 addPipe:pipe2];
id fReturn = [pipe1 someFuncWithNumber:999 object:nil];
NSLog(@"result _ %@", fReturn);
//NSLog output
//Robot No.999 birth day _ Wed Jun 23 19:21:28 2021
//result _ Wed Jun 23 19:21:28 2021
```
#### 2.修改下游入参
通过```- (BOOL)changeArgumentOld:(void *_Nonnull)oldArg toNew:(JDTuple *)newArg``` 方法可以修改入参，并作用于下游。
```objectivec
ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> pipe];
pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
    ActionProcess *process = [ActionProcess getCurrentActionProcess];
    [process changeArgumentOld:&objc toNew:jd_tuple([NSDate date])]; //将原本为nil的objc改为NSDate
    return nil;
};

ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> pipe];
pipe2.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, NSDate *date){
    id returnObjc = nil;
    if (date) { //接收到上游设置的NSDate
        returnObjc = date;
        return returnObjc;
    }
    return returnObjc;
};

[pipe1 addPipe:pipe2];
id fReturn = [pipe1 someFuncWithNumber:999 object:nil];
NSLog(@"result _ %@", fReturn);
//NSLog output
//result _ Thu Jun 24 17:50:34 2021
```

#### 3.获取上游返回值
通过```getUpStramReturnValue```方法可以获取上游返回值，返回值封装在NSValue中。（返回值不能自动透穿，每个pipe被触发后都会影响下游。）
```objectivec
ZZActionPipe<actionPipeProtocol> *pipe1 = [ZZActionPipe<actionPipeProtocol> pipe];
pipe1.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
    return @[@1, @2, @3];
};

ZZActionPipe<actionPipeProtocol> *pipe2 = [ZZActionPipe<actionPipeProtocol> pipe];
pipe2.registAction(@selector(someFuncWithNumber:object:)).action = pipe_createAction(NSInteger number, id objc){
    ActionProcess *process = [ActionProcess getCurrentActionProcess];
    id returnObjc = [[process getUpStramReturnValue] nonretainedObjectValue]; //获取上游返回值
    return returnObjc;
};

[pipe1 addPipe:pipe2];
id fReturn = [pipe1 someFuncWithNumber:999 object:nil];
NSLog(@"result _ %@", fReturn);
//NSLog output
//result _ (1, 2, 3)
```
## 6、将对象中的方法注册到pipe中
pipe也可以接收对象作为响应者，只要对象实现了所注册的selector也能被调用。类似于成为了对象的替身，同样注册了对象的pipe也可以跟其他pipe进行组合。
```objectivec
@interface testObject : NSObject
- (id)someFuncWithNumber:(NSInteger)number object:(id)objc;
@end

@implementation testObject

- (id)someFuncWithNumber:(NSInteger)number object:(id)objc {
    NSLog(@"%@ , %ld, %@", self, number, objc);
    return [NSObject new];
}
@end

ZZActionPipe *pipe1 = [ZZActionPipe pipe];
testObject *delegate = [testObject new];
pipe1.registAction(@selector(someFuncWithNumber:object:)).delegate = delegate; //将对象注册到pipe中
id fReturn = [(testObject *)pipe1 someFuncWithNumber:999 object:@"in instance object"];
NSLog(@"result _ %@", fReturn);
//NSLog output
// <testObject: 0x6000018bc000> , 999, in instance object
// result _ <NSObject: 0x6000018b8170>
```

//
//  ViewController2.m
//  JDSHActionPipeDemo
//
//  Created by 曾智 on 2021/6/25.
//  Copyright © 2021 曾智. All rights reserved.
//

#import "ViewController2.h"
#import "ZZActionPipe.h"

@protocol pipeAction <NSObject>

- (void)filterLoginWithName:(NSString *)strName passWord:(NSString *)strPassWord faild:(BOOL)bFaild;
- (void)loginAction;

@end

@interface ViewController2 () {
    ZZActionPipe *_vcPipe;
}

@property (nonatomic, strong) UITextField *textName;
@property (nonatomic, strong) UITextField *textPassWord;

@property (nonatomic, strong) UIButton *btnLogin;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    [self defaultLayoutSubViews];
}

- (void)defaultLayoutSubViews {
    self.textName = [[UITextField alloc]initWithFrame:(CGRect){CGPointZero, (CGSize){CGRectGetWidth(self.view.frame) * 0.7, 50}}];
    self.textName.backgroundColor = [UIColor whiteColor];
    self.textName.center = (CGPoint){CGRectGetWidth(self.view.frame) / 2, 200};
    self.textName.delegate = (id<UITextFieldDelegate>)self;
    
    self.textPassWord = [[UITextField alloc] initWithFrame:(CGRect){CGPointZero, self.textName.frame.size}];
    self.textPassWord.backgroundColor = [UIColor whiteColor];
    self.textPassWord.center = (CGPoint){CGRectGetWidth(self.view.frame) / 2, CGRectGetMaxY(self.textName.frame) + 100};
    self.textPassWord.delegate = (id<UITextFieldDelegate>)self;
    
    self.btnLogin = [[UIButton alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){CGRectGetWidth(self.view.frame) * 0.5, 50}}];
    self.btnLogin.backgroundColor = [UIColor grayColor];
    self.btnLogin.center = (CGPoint){self.textPassWord.center.x, self.textPassWord.center.y + 50};
    [self.btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [self.btnLogin addTarget:self.vcPipe action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.btnLogin setEnabled:NO];
    
    [self.view addSubview:self.textName];
    [self.view addSubview:self.textPassWord];
    [self.view addSubview:self.btnLogin];
}

- (void)textFieldDidChangeSelection:(UITextField *)textField {
    [(id <pipeAction>)self.vcPipe filterLoginWithName:self.textName.text passWord:self.textPassWord.text faild:YES];
}

- (void)filterLoginWithName:(NSString *)strName passWord:(NSString *)strPassWord faild:(BOOL)bFaild{
    if (!bFaild) {
        [self.btnLogin setEnabled:YES];
        self.btnLogin.backgroundColor = [UIColor redColor];
    }else {
        [self.btnLogin setEnabled:NO];
        self.btnLogin.backgroundColor = [UIColor grayColor];
    }
}

- (void)loginAction {
    ActionProcess *process = [ActionProcess getCurrentActionProcess];
    if (process.state == k_action_success) {
        NSLog(@"登陆成功！");
    }else if(process.state == k_action_error) {
        NSLog(@"密码错误！");
    }
}

- (ZZActionPipe *)vcPipe {
    if (!_vcPipe) {
        _vcPipe = [ZZActionPipe new];
        _vcPipe.registAction(@selector(filterLoginWithName:passWord:faild:)).delegate = self;
        _vcPipe.registAction(@selector(loginAction)).state(k_action_success | k_action_error).delegate = self;
    }
    return _vcPipe;
}
@end

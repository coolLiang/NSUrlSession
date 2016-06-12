//
//  ViewController.m
//  NSUrlSession
//
//  Created by noci on 16/6/12.
//  Copyright © 2016年 noci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

-(void)sessionTest
{
    NSURL * url = [NSURL URLWithString:@"http://517.medp.cn/DataApi/index.php?m=User&a=UpdateUserInfo"];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10];
    
    UIImage * image = [UIImage imageNamed:@"share"];
    
    //文件
    NSDictionary * files = @{@"image":image};
    //数据
    
    NSDictionary * pramas = @{@"SysNo":@"1",@"token":@"2",@"NickName":@"lalala",@"Gender":@"1",@"Mobile":@"",@"School":@"222",@"WorkYear":@"1",@"Education":@"",@"Traditional":@"1"};
    
    //整合
    NSData * data = [self getFortDataFromFileDict:files andPramaDict:pramas];
    
    [request setHTTPBody:data];
    
    // 设置请求头
    // 请求体的长度
    [request setValue:[NSString stringWithFormat:@"%zd", data.length] forHTTPHeaderField:@"Content-Length"];
    
    // 声明这个POST请求是个文件上传
    //其中 Boundary+81563E5F3C5847CC 是个标识。用以分割每个数据。下方也需要用到。
    [request setValue:@"multipart/form-data; boundary=Boundary+81563E5F3C5847CC" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        
        NSInteger statusCode = [httpResponse statusCode];
        
        if (statusCode == 200) {
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@",dict);
            
        }
        
        else
        {
            NSLog(@"false");
            
        }
        
        
    }];
    
    [dataTask resume];
}

/**
 *   1.上传的数据需要用分割标识进行分开。并且在结尾处要用--分割标识--结束上传动作。
 *   2.上传数据中name相关数据输入时要用“”.\"%@\"。
 *   3.数据上传时。要有name.value2个字段。都appendFormat在一个字符串下。
 *   4.文件上传时。要有filename.name.以及minitype字段传入。并且最后需要将文件data.附加在总data中。
 *   5.每个数据进行上传时。都需要\r\n来进行换行。！
 *
 **/
-(NSData *)getFortDataFromFileDict:(NSDictionary *)files andPramaDict:(NSDictionary *)parmas
{
    
    NSMutableData * data = [NSMutableData new];
    
    //参数
    [parmas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSMutableString * body = [NSMutableString new];
        NSString * valueKey = key;
        NSString * value = obj;
        
        [body appendFormat:@"--Boundary+81563E5F3C5847CC\r\n"];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",valueKey];
        //添加字段的值
        [body appendFormat:@"%@\r\n",value];
        
        [data appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    //文件格式(只写了图片)
    [files enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSMutableString * body = [NSMutableString new];
        
        if ([obj isMemberOfClass:[UIImage class]]) {
            
            NSLog(@"图片");
            
            
            UIImage * image = (UIImage *)obj;
            
            NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
            
            [body appendFormat:@"--Boundary+81563E5F3C5847CC\r\n"];
            [body appendFormat:@"Content-Disposition: form-data; name=\"pic\"; filename=\"boris.png\"\r\n"];
            [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
            
            //增加数据。
            [data appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
            
            [data appendData:imageData];
            
            
        }
        
        
    }];
    
    //end
    NSString * end = [[NSString alloc]initWithFormat:@"\r\n--Boundary+81563E5F3C5847CC--"];
    
    [data appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    return data;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

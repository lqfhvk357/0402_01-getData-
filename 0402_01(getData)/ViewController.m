//
//  ViewController.m
//  0402_01(getData)
//
//  Created by Mac on 15-4-2.
//  Copyright (c) 2015年 chao. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Regex.h"

#define NUM 1
@interface ViewController ()
@property (nonatomic, assign) int plistNum;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"begin");
    [self getPlist2];
    NSLog(@"end");
//    [self getData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)getPlistWithArr2:(NSArray *)array
{
    NSMutableArray *Arr_M=[NSMutableArray array];
    NSLog(@"%@", array);
    for (NSDictionary *dict in array) {
        NSArray *images=dict[@"images"];
        NSMutableArray *images_M=[NSMutableArray array];
        for (NSString *url in images) {
            UIImage *image=[self imageWithUrlStr:url];
            NSLog(@"%@", NSStringFromCGSize(image.size));
            NSMutableDictionary *imageInfo=[NSMutableDictionary dictionary];
            if (image.size.width<1) {
                NSLog(@"%@图挂了！！！！！！！！！！！", url);
                continue;
            }
            imageInfo[@"url"]=url;
            imageInfo[@"w"]=[NSString stringWithFormat:@"%f",image.size.width];
            imageInfo[@"h"]=[NSString stringWithFormat:@"%f",image.size.height];
            [images_M addObject:imageInfo];
        }
        if (images_M.count>0) {
            NSMutableDictionary *d_M=[NSMutableDictionary dictionary];
            d_M[@"name"]=dict[@"name"];
            d_M[@"title"]=dict[@"title"];
            d_M[@"images"]=images_M;
            
            NSLog(@"%@", d_M);
            [Arr_M addObject:d_M];
        }
        
    }
//    NSLog(@"%@", Arr_M);
    NSString *filePath=[NSString stringWithFormat:@"/Users/Mac/Desktop/00%d.plist",NUM];
    [Arr_M writeToFile:filePath atomically:YES];
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]);
    
}

- (void)getPlist
{
    NSString *urlStr=@"http://www.mtu5.com/xingganmeinv/list_1_2.html";
    NSString *html=[self htmlStringWithUrlString:urlStr];
//    NSLog(@"%@", html);
    NSString *pattern=@"<div class=\"imgList\">.*?<ul>(.*?)</ul>";
    NSString *condent=[html firstMatchWithPattern:pattern];
    NSString *p=@"<li><a href='(.*?)'><img src=.*?html'>(.*?)</a></li>";
    NSArray *arr=[condent matchesWithPattern:p keys:@[@"url", @"name"]];
    //    NSLog(@"%@", condent);
    NSMutableArray *Arr_M=[NSMutableArray array];
    for (NSDictionary *dict in arr) {
        NSString *tempUrl=[NSString stringWithFormat:@"http://www.mtu5.com%@", dict[@"url"]];
        NSDictionary *tempDict=[self getData3WithStr:tempUrl name:dict[@"name"]];
        [Arr_M addObject:tempDict];
}
    
    [self getPlistWithArr2:Arr_M];
//    NSString *filePath=[NSString stringWithFormat:@"/Users/Mac/Desktop/002.plist"];
//    [Arr_M writeToFile:filePath atomically:YES];
}

- (void)getPlist2
{
    NSString *urlStr=@"http://www.mtu5.com/xingganmeinv/list_1_18.html";
    NSString *html=[self htmlStringWithUrlString:urlStr];
    NSLog(@"%@", html);
    NSString *pattern=@"<div class=\"imgList\">.*?<ul>(.*?)</ul>";
    NSString *condent=[html firstMatchWithPattern:pattern];
//    NSLog(@"%@", condent);
    NSString *p=@"<li><a href='(.*?)'><img src=.*?html'>(.*?)</a></li>";
    NSArray *arr=[condent matchesWithPattern:p keys:@[@"url", @"name"]];
//    NSLog(@"%@", arr);
    NSMutableArray *Arr_M=[NSMutableArray array];
    for (NSDictionary *dict in arr) {
        NSString *tempName=dict[@"name"];
        tempName=[[tempName stringByReplacingOccurrencesOfString:@"<b>" withString:@""] stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
        NSString *tempUrl=[NSString stringWithFormat:@"http://www.mtu5.com%@", dict[@"url"]];
        NSDictionary *tempDict=[self getData3WithStr:tempUrl name:tempName];
        [Arr_M addObject:tempDict];
    }
    
    [self getPlistWithArr2:Arr_M];
    //    NSString *filePath=[NSString stringWithFormat:@"/Users/Mac/Desktop/001.plist"];
    //    [Arr_M writeToFile:filePath atomically:YES];
}

- (NSDictionary *)getData3WithStr:(NSString *)urlStr name:(NSString *)name
{
    NSString *MainUrlStr=@"http://www.mtu5.com";
    NSString *htmlStr=[self htmlStringWithUrlString:urlStr];
//    NSLog(@"%@", htmlStr);
    NSString *num=[self substringForSuperstring:htmlStr betweenString:@"共" andString:@"页"];
    NSLog(@"%@", num);
    
//    NSString *p=@"<div class=\"arcBody\">.*?<br />(.*?)<br />";
//    NSString *title=[htmlStr firstMatchWithPattern:p];
//    title=[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * title=name;
    NSLog(@"%@", title);
    
    
    NSString *urlP=@"<div class=\"arcBody\">.*?<img alt=.*?src=\"(.*?)\" title=.*? />";
    NSString *tempUrlStr0=[urlStr substringToIndex:urlStr.length-5];
    NSLog(@"%@", tempUrlStr0);
    NSString *tempHtmlStr=htmlStr;
    NSMutableArray *arr_M=[NSMutableArray array];
    for (int i=2; i<=[num intValue]+1; i++) {
        NSString *url=[tempHtmlStr firstMatchWithPattern:urlP];
        NSString *temp=[NSString stringWithFormat:@"%@%@", MainUrlStr, url];
        [arr_M addObject:temp];
        NSString *tempUrlStr=[NSString stringWithFormat:@"%@_%d.html", tempUrlStr0, i];
        tempHtmlStr=[self htmlStringWithUrlString:tempUrlStr];
//        NSLog(@"%@", tempUrlStr);
        
    }
    NSLog(@"%@", arr_M);
    NSDictionary *dict=@{@"name":name, @"title":title, @"images":arr_M};
//    NSLog(@"%@", dict);
    
    
    return dict;
}



- (void)getData2
{
    NSString *htmlStr=[self htmlStringWithUrlString:@"http://www.mtu5.com/xingganmeinv/"];
    self.plistNum=5;
    for (int i=1066; i<900; i--) {
        NSString *beginStr=[NSString stringWithFormat:@"No.%d", i];
        NSString *endStr=[NSString stringWithFormat:@"No.%d", i-11];
        NSString *content=[self substringForSuperstring:htmlStr betweenString:beginStr andString:endStr];
        //    NSLog(@"\n%@", content);
        
        NSString *p=@"<a href=\"(.*?)\" target=\"_blank\" >(.*?)</a><br />";
        NSArray *arr=[content matchesWithPattern:p keys:@[@"url", @"name"]];
        NSLog(@"%@", arr);
        for (NSDictionary *dict in arr) {
            NSString *tempStr=[self htmlStringWithUrlString:dict[@"url"]];
            //        NSLog(@"%@",tempStr);
            NSString *tempStr2=[self substringForSuperstring:tempStr betweenString:@"<br />[套图预览] :</font><br />" andString:@"华为网盘</a><br />"];
            //        NSLog(@"%@",tempStr2);
            NSString *imageUrlStr=[self substringForSuperstring:tempStr2 betweenString:@"<img src=\"" andString:@"\" border"];
            [dict setValue:imageUrlStr forKeyPath:@"url"];
            NSString *tempStr3=[dict[@"name"] substringFromIndex:34];
            tempStr3=[tempStr3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (tempStr3.length>10) {
                NSRange range=[tempStr3 rangeOfString:@"["];
                tempStr3=[tempStr3 substringToIndex:range.location];
            }
            [dict setValue:tempStr3 forKeyPath:@"name"];
            NSLog(@"%@", imageUrlStr);
        }
        NSLog(@"%@", arr);
        [self getPlistWithArr:arr];
        NSLog(@"end");
        
    }

}


- (void)getData
{
    NSString *htmlStr=[self htmlStringWithUrlString:@"http://www.itokoo.com/read.php?tid=188"];
    NSString *begin=[NSString stringWithFormat:@"No.%d",(111-NUM)*10+6];
    NSString *end=[NSString stringWithFormat:@"No.%d",(110-NUM)*10+5];
    
    NSString *content=[self substringForSuperstring:htmlStr betweenString:begin andString:end];
//    NSLog(@"\n%@", content);
    
    NSString *p=@"<a href=\"(.*?)\" target=\"_blank\" >(.*?)</a><br />";
    NSArray *arr=[content matchesWithPattern:p keys:@[@"url", @"name"]];
    NSLog(@"%@", arr);
    for (NSDictionary *dict in arr) {
        NSString *tempStr=[self htmlStringWithUrlString:dict[@"url"]];
        NSString *tempStr2=[self substringForSuperstring:tempStr betweenString:@"<br />[套图预览] :</font><br />" andString:@"华为网盘</a><br />"];
        NSString *imageUrlStr=[self substringForSuperstring:tempStr2 betweenString:@"<img src=\"" andString:@"\" border"];
        [dict setValue:imageUrlStr forKeyPath:@"url"];
        NSString *tempStr3=[dict[@"name"] substringFromIndex:34];
        tempStr3=[tempStr3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (tempStr3.length>10) {
            NSRange range=[tempStr3 rangeOfString:@"["];
            tempStr3=[tempStr3 substringToIndex:range.location];
        }
        [dict setValue:tempStr3 forKeyPath:@"name"];
        NSLog(@"%@", imageUrlStr);
    }
    NSLog(@"%@", arr);
    [self getPlistWithArr:arr];
    NSLog(@"end");

}

- (NSString *)htmlStringWithUrlString:(NSString *)urlStr
{
    NSURL *url=[NSURL URLWithString:urlStr];
//    NSData *data=[NSData dataWithContentsOfURL:url];
//    NSLog(@"begin");
    return [NSString stringWithContentsOfURL:url encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:nil];
    
}

- (NSString* )substringForSuperstring:(NSString *)superstr betweenString:(NSString *)str1 andString:(NSString *)str2
{
    NSRange beginRange=[superstr rangeOfString:str1];
    NSString *tempStr=[superstr substringFromIndex:beginRange.location+beginRange.length];
    NSRange endRange=[tempStr rangeOfString:str2];
    return [tempStr substringToIndex:endRange.location];
    
}

- (UIImage *)imageWithUrlStr:(NSString *)str
{
    NSURL *url=[NSURL URLWithString:str];
//    NSData *data=[NSData dataWithContentsOfURL:url];
    NSURLRequest *reqeust=[NSURLRequest requestWithURL:url];
    NSData *data=[NSURLConnection sendSynchronousRequest:reqeust returningResponse:NULL error:NULL];
    return [UIImage imageWithData:data];
}

- (void)getPlistWithArr:(NSArray *)array
{
    
    NSMutableArray *Arr_M=[NSMutableArray array];
    NSLog(@"%@", array);
    for (NSDictionary *dict in array) {
        
        NSMutableDictionary *d_M=[NSMutableDictionary dictionaryWithDictionary:dict];
        UIImage *image=[self imageWithUrlStr:dict[@"url"]];
        NSLog(@"%@",[NSString stringWithFormat:@"%f",image.size.height]);
        if (image.size.height<1) {
            return;
        }
        d_M[@"w"]=[NSString stringWithFormat:@"%f",image.size.width];
        
//        [d_M setValue:[NSString stringWithFormat:@"%zd",image.size.width] forKey:@"w"];
        d_M[@"h"]=[NSString stringWithFormat:@"%f",image.size.height];
        [Arr_M addObject:d_M];
    }
    NSLog(@"%@", Arr_M);
    NSString *filePath=[NSString stringWithFormat:@"/Users/Mac/Desktop/00%d.plist",NUM];
    [Arr_M writeToFile:filePath atomically:YES];
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]);
    
}
@end

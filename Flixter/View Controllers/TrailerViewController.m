//
//  TrailerViewController.m
//  Flixter
//
//  Created by Megan Miller on 6/17/22.
//

#import "TrailerViewController.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) NSArray *videos;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchVideos];
}

- (void)fetchVideos {
    NSString *firstURLString = @"https://api.themoviedb.org/3/movie/";
    NSString *secondURLString = self.trailerDict[@"id"];
    NSString *thirdURLString = @"/videos?api_key=a1d98e6dbbd7806ea51d26fdad046f7e&language=en-US";
    NSString *fullURLString = [NSString stringWithFormat:@"%@/%@/%@", firstURLString, secondURLString, thirdURLString];
    
    NSURL *url = [NSURL URLWithString:fullURLString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.videos = dataDictionary[@"results"];
        }
    }];
     
    [task resume];
}

@end

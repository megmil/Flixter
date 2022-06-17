//
//  DetailsViewController.m
//  Flixter
//
//  Created by Megan Miller on 6/15/22.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *overview;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.movieTitle.text = self.detailsDict[@"title"];
    self.overview.text = self.detailsDict[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *backdropURLString = self.detailsDict[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    
    NSString *posterURLString = self.detailsDict[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    [self.backdropView setImageWithURL:backdropURL];
    [self.posterView setImageWithURL:posterURL];
}

@end

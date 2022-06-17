//
//  MovieViewController.m
//  Flixter
//
//  Created by Megan Miller on 6/15/22.
//

#import "MovieViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#include "DetailsViewController.h"

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIAlertController *alert;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchMovies];
    
    // configure network error alert
    self.alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                                                     message:@"The Internet connection appears to be offline."
                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Try Again"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                        [self fetchMovies];
                                                    }];
    [self.alert addAction:action];
    
    // configure "pull to refresh" feature
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.tableView addSubview:self.refreshControl];
}

// MODIFIES: movies, tableView
// EFFECTS: Requests data from movie database. If there is a network error, presents an alert. Else, stores the movie data then reloads the table.
- (void)fetchMovies {
    
    [self.activityIndicator startAnimating];
    
    // request data from movie database
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a1d98e6dbbd7806ea51d26fdad046f7e"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            [self presentViewController:self.alert animated:YES completion:nil];
        } else {
            // update movie data
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.movies = dataDictionary[@"results"];
            
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
        }
        
        [self.refreshControl endRefreshing];
    }];
    
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

// EFFECTS: Returns the reusable MovieCell with the title, overview, and poster view for row at index path.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.movieCellTitle.text = movie[@"title"];
    cell.movieCellOverview.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [cell.movieCellPosterView setImageWithURL:posterURL];
    
    return cell;
}

#pragma mark - Navigation

// MODIFIES: detailsDict
// EFFECTS: Passes movie data from sender (MovieGridCell) to DetailsViewController.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *myIndexPath = [self.tableView indexPathForCell:sender];
    
    NSDictionary *dataToPass = self.movies[myIndexPath.row];
    DetailsViewController *detailVC = [segue destinationViewController];
    detailVC.detailsDict = dataToPass;
}

@end

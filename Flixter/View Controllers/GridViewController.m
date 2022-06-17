//
//  GridViewController.m
//  Flixter
//
//  Created by Megan Miller on 6/15/22.
//

#import "GridViewController.h"
#import "MovieGridCell.h"
#import "UIImageView+AFNetworking.h"

@interface GridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation GridViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self fetchMovies];
}

// MODIFIES: movies
// EFFECTS: Requests data from movie database. If successful, stores the movie data then reloads the table.
- (void)fetchMovies {
    
    // request data from movie database
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a1d98e6dbbd7806ea51d26fdad046f7e"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            // store movie data
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.movies = dataDictionary[@"results"];
            
            [self.collectionView reloadData];
        }
    }];
    
    [task resume];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

// EFFECTS: Returns the reusable MovieGridCell with the poster view for item at index path.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieGridCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.item];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    [cell.movieGridCellPoster setImageWithURL:posterURL];
    
    return cell;
}

@end

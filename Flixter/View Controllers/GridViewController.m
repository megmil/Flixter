//
//  GridViewController.m
//  Flixter
//
//  Created by Megan Miller on 6/15/22.
//

#import "GridViewController.h"
#import "MovieGridCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface GridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation GridViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.searchBar.delegate = self;
    
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
            self.filteredMovies = self.movies;
            
            [self.collectionView reloadData];
        }
    }];
    
    [task resume];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

// EFFECTS: Returns the reusable MovieGridCell with the poster view for item at index path.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieGridCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
    
    // configure fade in poster
    __weak MovieGridCell *weakSelf = cell;
    [cell.movieGridCellPoster
        setImageWithURLRequest:request
        placeholderImage:nil
        success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
            if (imageResponse) {
                // fade in image
                weakSelf.movieGridCellPoster.alpha = 0.0;
                weakSelf.movieGridCellPoster.image = image;
                [UIView animateWithDuration:0.5 animations:^{
                    weakSelf.movieGridCellPoster.alpha = 1.0;
                }];
            } else {
                weakSelf.movieGridCellPoster.image = image;
            }
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
            weakSelf.movieGridCellPoster.image = [UIImage imageNamed:@"reel_tabbar_icon"];
    }];
    
    return cell;
}

// MODIFIES: filteredMovies
// EFFECTS: Updates filteredMovies from movies according to the search bar data.
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            NSString *title = evaluatedObject[@"original_title"];
            return [title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredMovies = self.movies;
    }
    
    [self.collectionView reloadData];
}

// MODIFIES: filteredMovies, searchBar
// EFFECTS: Resets filtered movies array and search bar.
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    self.filteredMovies = self.movies;
    [self.collectionView reloadData];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

#pragma mark - Navigation

// MODIFIES: detailsDict
// EFFECTS: Passes movie data from sender (MovieCell) to DetailsViewController.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *myIndexPath = [self.collectionView indexPathForCell:sender];
    
    NSDictionary *dataToPass = self.movies[myIndexPath.row];
    DetailsViewController *detailVC = [segue destinationViewController];
    detailVC.detailsDict = dataToPass;
}

@end

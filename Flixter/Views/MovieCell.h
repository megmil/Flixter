//
//  MovieCell.h
//  Flixter
//
//  Created by Megan Miller on 6/15/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *movieCellPosterView;
@property (weak, nonatomic) IBOutlet UILabel *movieCellTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieCellOverview;

@end

NS_ASSUME_NONNULL_END

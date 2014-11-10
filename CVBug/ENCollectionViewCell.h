//
//  ENCollectionViewCell.h
//  CVBug
//
//  Created by Don Miller on 11/10/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView; // to dim when applying preset or uploading

- (void)markCellAsSelected:(BOOL)wasSelected;

@end

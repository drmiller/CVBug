//
//  ENCollectionViewCell.m
//  CVBug
//
//  Created by Don Miller on 11/10/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "ENCollectionViewCell.h"

@interface ENCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *checkBadge;
@end

@implementation ENCollectionViewCell

- (void)markCellAsSelected:(BOOL)wasSelected {
    self.checkBadge.hidden = !wasSelected;
}

@end

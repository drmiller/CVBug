//
//  Photo.h
//  CVBug
//
//  Created by Don Miller on 11/10/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * enhanced;
@property (nonatomic, retain) UIImage *image;

@end

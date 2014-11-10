//
//  Photo+Additions.m
//  CVBug
//
//  Created by Don Miller on 11/10/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "Photo+Additions.h"




@implementation Photo (Additions)

//+ (void)addImagesToCoreDataWithMOC:(NSManagedObjectContext *)moc {
//    [self populateCoreDataAndSaveWithImage:[UIImage imageNamed:@"ImageOne.png"] isEnhanced:NO usingMOC:moc];
//    
//    [self populateCoreDataAndSaveWithImage:[UIImage imageNamed:@"ImageTwo.png"] isEnhanced:NO usingMOC:moc];
//    
//    [self populateCoreDataAndSaveWithImage:[UIImage imageNamed:@"ImageThree.png"] isEnhanced:YES usingMOC:moc];
//}




+ (Photo *)populateCoreDataAndSaveWithImage:(UIImage *)theImage isEnhanced:(BOOL)enhanced usingMOC:(NSManagedObjectContext *)moc {
    
    NSError *error = nil;
    
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:moc];
    
    newPhoto.image = theImage;
    newPhoto.enhanced = @(enhanced);
    
    if (![moc save:&error]) {
        // Handle the error
        NSLog(@"populateAndSaveWithImage: %@", [error description]);
        abort();
    } else {
        NSLog(@"Image saved to Core Data");
    }
    return newPhoto;
}

@end

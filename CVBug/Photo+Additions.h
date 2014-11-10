//
//  Photo+Additions.h
//  CVBug
//
//  Created by Don Miller on 11/10/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "Photo.h"

@interface Photo (Additions)

+ (Photo *)populateCoreDataAndSaveWithImage:(UIImage *)theImage isEnhanced:(BOOL)enhanced usingMOC:(NSManagedObjectContext *)moc;

+ (void)deletePhotos:(NSArray *)photos withMOC:(NSManagedObjectContext *)moc;

//+ (void)addImagesToCoreDataWithMOC:(NSManagedObjectContext *)moc;

@end

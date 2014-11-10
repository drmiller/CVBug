//
//  ViewController.m
//  CVBug
//
//  Created by Don Miller on 11/10/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController () {

    // for quirks in NSFetchResultsController
    // with Collection Views
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark -
#pragma mark UICollectionView Datasource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger numberOfItems = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    
    NSLog(@"CV Datasource Section: %li  Items: %li",(long)section,(long)numberOfItems);
    
    return numberOfItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger numberOfSections = [[self.fetchedResultsController sections] count];
    
    NSLog(@"CV Datasource Number of Sections: %li",(long)numberOfSections);
    
    return numberOfSections;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"CV Datasource viewForSupplementaryElementOfKind for IndexPath: %li, %li",(long)indexPath.section, (long)indexPath.row);
    
    ENGalleryHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                     withReuseIdentifier:@"GalleryHeaderView"
                                                                            forIndexPath:indexPath];
    headerView.headerLabel.text = (indexPath.section == ORIGINAL_SECTION) ? @"Originals" : @"Enhanced";
    return headerView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ENGalleryCollectionViewCell *theCell = (ENGalleryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:GalleryCellIdentifier forIndexPath:indexPath];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [theCell setPhoto:photo forCollectionView:collectionView andIndexPath:indexPath];

    // tried using indexPathsForSelectedPhotos, but couldn't get it to work
    if ([self.selectedPhotos containsObject:photo]) {
        
        // this is for uploading and applying preset,
        // or anything where cells are selected
        [theCell markCellAsSelected:YES];
        
    } else {
        [theCell markCellAsSelected:NO];
    }

    NSLog(@"CV Datasource Cell for IndexPath: %li, %li",indexPath.section, indexPath.row);
    return theCell;
}


#pragma mark -
#pragma mark UICollectionView Delegate

#pragma mark - Manage selections

- (void)manageGallerySelectionCollectionView:(UICollectionView *)cv forIndexPath:(NSIndexPath *)indexPath didSelect:(BOOL)didSelect {
    
    ENGalleryCollectionViewCell *theCell = (ENGalleryCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [theCell markCellAsSelected:didSelect];

    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (didSelect) {
        
        [self.selectedPhotos addObject:photo];
        
    } else {

        [self.selectedPhotos removeObject:photo];
    }

}

- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.lastSelectedIndexPath = indexPath; // for scrolling through preview images???
    
    [self manageGallerySelectionCollectionView:cv forIndexPath:indexPath didSelect:YES];
}

- (void)collectionView:(UICollectionView *)cv didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self manageGallerySelectionCollectionView:cv forIndexPath:indexPath didSelect:NO];
}


#pragma mark -
#pragma mark NSFetchedResultsController

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:4];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorEnhanced = [[NSSortDescriptor alloc] initWithKey:@"enhanced" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptorEnhanced]];
    
    // iOS 7 -  if I specify a cache name with WAL activated the FRC does not work
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:AppDelegate.managedObjectContext
                                     sectionNameKeyPath:@"enhanced"
                                     cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved fetchedResultsController:performFetch error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSLog(@"Number of sections: %i", [[_fetchedResultsController sections] count]);
    
    return _fetchedResultsController;
}





- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch((NSUInteger)type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    NSLog(@"didChangeSection Section: %li Type: %@", sectionIndex, type == NSFetchedResultsChangeDelete ? @"Delete" : @"Insert");
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    NSLog(@"didChangeObject IndexPath: %li,%li Type: %@", indexPath.section,indexPath.row, type == NSFetchedResultsChangeDelete ? @"Delete" : @"Other");
    
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerDidChangeContent sectionChanges: %li", [_sectionChanges count]);
    
    if ([_sectionChanges count] > 0)
    {
        NSLog(@"BEFORE performBatchUpdates for Sections");
        
        @try {
            
            
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _sectionChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch ((NSUInteger)type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                NSLog(@"BEFORE deleteSections");
                                NSUInteger toDeleteSection = [obj unsignedIntegerValue];
                                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:toDeleteSection]];
                                NSLog(@"AFTER deleteSections");
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                        }
                    }];
                }
            } completion:^(BOOL finished){
                NSLog(@"completion finished");
            }];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Exception caught");
            //NSLog(@"Exception caught: %@", exception.description);
            //[self.collectionView reloadData];
        }
        
        NSLog(@"AFTER performBatchUpdates for Sections");
        
    }
    
    NSLog(@"controllerDidChangeContent objectChanges: %li sectionChanges: %li", [_objectChanges count], [_sectionChanges count]);
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
        //if ([_objectChanges count] > 0)
    {
        
        NSLog(@"[_objectChanges count] > 0 && [_sectionChanges count] == 0)");
        //if ([_sectionChanges count] == 0) {
        
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
            NSLog(@"CV reloadData");
            
        }
        
        // }
        
        
        else {
            
            NSLog(@"BEGIN performBatchUpdates for Objects");
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    NSLog(@"shouldReload: %@", shouldReload ? @"YES" : @"NO");
    
    return shouldReload;
}
@end

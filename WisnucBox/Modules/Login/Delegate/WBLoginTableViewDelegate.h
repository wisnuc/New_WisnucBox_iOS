//
//  WBLoginTableViewDelegate.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/11.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "WBLoginTableView.h"
//#import "WBLoginCardTableViewCell.h"
@class WBLoginTableView;
@class WBLoginCardTableViewCell;

@protocol WBLoginTableViewDelegate <NSObject>
@optional

// Display customization

- (void)tableView:(nonnull WBLoginTableView *)tableView willDisplayCell:(nonnull WBLoginCardTableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
- (void)tableView:(nullable WBLoginTableView *)tableView willDisplayHeaderView:(nullable UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
- (void)tableView:(nullable  WBLoginTableView *)tableView willDisplayFooterView:(nullable UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
- (void)tableView:(nullable WBLoginTableView *)tableView didEndDisplayingCell:(nullable WBLoginCardTableViewCell *)cell forRowAtIndexPath:(nullable NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);
- (void)tableView:(nullable WBLoginTableView *)tableView didEndDisplayingHeaderView:(nullable UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
- (void)tableView:(nullable WBLoginTableView *)tableView didEndDisplayingFooterView:(nullable UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);

// Variable height support

- (CGFloat)h_tableView:(nullable WBLoginTableView *)tableView heightForRowAtIndexPath:(nullable NSIndexPath *)indexPath;
- (CGFloat)tableView:(nullable WBLoginTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(nullable WBLoginTableView *)tableView heightForFooterInSection:(NSInteger)section;
/*
 // Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
 // If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
 - (CGFloat)tableView:(YHorizontalTableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0);
 - (CGFloat)tableView:(YHorizontalTableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0);
 - (CGFloat)tableView:(YHorizontalTableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0);
 
 // Section header & footer information. Views are preferred over title should you decide to provide both
 
 - (nullable UIView *)tableView:(YHorizontalTableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
 - (nullable UIView *)tableView:(YHorizontalTableView *)tableView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or specified footer height
 
 // Accessories (disclosures).
 
 - (UITableViewCellAccessoryType)tableView:(YHorizontalTableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0) __TVOS_PROHIBITED;
 - (void)tableView:(YHorizontalTableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
 
 // Selection
 
 // -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
 // Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
 - (BOOL)tableView:(YHorizontalTableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(YHorizontalTableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(YHorizontalTableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
 
 // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
 - (nullable NSIndexPath *)tableView:(YHorizontalTableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
 - (nullable NSIndexPath *)tableView:(YHorizontalTableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
 // Called after the user changes the selection.
 - (void)tableView:(YHorizontalTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
 - (void)tableView:(YHorizontalTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
 
 // Editing
 
 // Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
 - (UITableViewCellEditingStyle)tableView:(YHorizontalTableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
 - (nullable NSString *)tableView:(YHorizontalTableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED;
 - (nullable NSArray<UITableViewRowAction *> *)tableView:(YHorizontalTableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED; // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
 
 // Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
 - (BOOL)tableView:(YHorizontalTableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;
 
 // The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
 - (void)tableView:(YHorizontalTableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED;
 - (void)tableView:(YHorizontalTableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED;
 
 // Moving/reordering
 
 // Allows customization of the target row for a particular row as it is being moved/reordered
 - (NSIndexPath *)tableView:(YHorizontalTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
 
 // Indentation
 
 - (NSInteger)tableView:(YHorizontalTableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath; // return 'depth' of row for hierarchies
 
 // Copy/Paste.  All three methods must be implemented by the delegate.
 
 - (BOOL)tableView:(YHorizontalTableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0);
 - (BOOL)tableView:(YHorizontalTableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0);
 - (void)tableView:(YHorizontalTableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0);
 
 #ifndef SDK_HIDE_TIDE
 // Focus
 
 - (BOOL)tableView:(YHorizontalTableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0);
 - (BOOL)tableView:(YHorizontalTableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context NS_AVAILABLE_IOS(9_0);
 - (void)tableView:(YHorizontalTableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator NS_AVAILABLE_IOS(9_0);
 - (nullable NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(YHorizontalTableView *)tableView NS_AVAILABLE_IOS(9_0);
 #endif
 */
@end

@protocol WBLoginTableViewDataSource <NSObject>

@required

- (NSInteger)h_tableView:(nonnull WBLoginTableView *)tableView numberOfRowsInSection:(NSInteger)section;

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (nullable WBLoginCardTableViewCell *)h_tableView:(nonnull WBLoginTableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;

@optional

- (NSInteger)numberOfSectionsInTableView:(nullable WBLoginTableView *)tableView;              // Default is 1 if not implemented

- (nullable NSString *)tableView:(nullable WBLoginTableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
- (nullable NSString *)tableView:(nullable WBLoginTableView *)tableView titleForFooterInSection:(NSInteger)section;

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(nullable WBLoginTableView *)tableView canEditRowAtIndexPath:(nullable NSIndexPath *)indexPath;

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(nullable WBLoginTableView *)tableView canMoveRowAtIndexPath:(nullable NSIndexPath *)indexPath;

// Index

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(nullable WBLoginTableView *)tableView __TVOS_PROHIBITED;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSInteger)tableView:(nullable WBLoginTableView *)tableView sectionForSectionIndexTitle:(nullable NSString *)title atIndex:(NSInteger)index __TVOS_PROHIBITED;  // tell table which section corresponds to section title/index (e.g. "B",1))

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(nullable WBLoginTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nullable NSIndexPath *)indexPath;

// Data manipulation - reorder / moving support

- (void)tableView:(nullable WBLoginTableView *)tableView moveRowAtIndexPath:(nullable NSIndexPath *)sourceIndexPath toIndexPath:(nullable NSIndexPath *)destinationIndexPath;

@end

@interface WBLoginTableViewDelegate : NSObject

@end


/*
 * Qontacts Mobile Application
 * Qontacts is a mobile application that updates the address book contacts
 * to the new Qatari numbering scheme.
 * 
 * Copyright (C) 2010  Abdulrahman Saleh Alotaiba
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation version 3 of the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Using TDBadgedCell - Created by Tim Davies <http://github.com/tmdvs/TDBadgedCell>.
 */

#import <UIKit/UIKit.h>
#import "ContactsViewController.h"

@interface TDBadgeView : UIView {
	NSInteger width;
	NSInteger badgeNumber;
	
	CGSize numberSize;
	UIFont *font;
	NSString *countString;
	UITableViewCell *parent;
	
	UIColor *badgeColor;
	UIColor *badgeColorHighlighted;
	
}

@property (readonly) NSInteger width;
@property  NSInteger badgeNumber;
@property (nonatomic,retain) UITableViewCell *parent;
@property (nonatomic, retain) UIColor *badgeColor;
@property (nonatomic, retain) UIColor *badgeColorHighlighted;

@end

@interface ContactNameCell : UITableViewCell {
	BOOL checked;
	
	NSIndexPath *indexPath;
	NSUInteger contactID;
	UIButton *checkButton;
	
	NSInteger badgeNumber;
	TDBadgeView *badge;
	
	UIColor *badgeColor;
	UIColor *badgeColorHighlighted;
	
	ContactsViewController *rootClass;
}

@property (nonatomic, assign) BOOL checked;

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) NSUInteger contactID;
@property NSInteger badgeNumber;
@property (readonly, retain) TDBadgeView *badge;
@property (nonatomic, retain) UIColor *badgeColor;
@property (nonatomic, retain) UIColor *badgeColorHighlighted;
@property (nonatomic, retain) ContactsViewController *rootClass;

- (void)checkAction:(id)sender;

@end

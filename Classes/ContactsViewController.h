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
 */

#define kAlertViewError		1
#define kSelectStateNone	0
#define kSelectStateAll		1

#import <UIKit/UIKit.h>
#import "ContactsModel.h"

@class ProgressViewController;

@interface ContactsViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate> {
	ContactsModel			*contactsModel;
	ProgressViewController	*progressViewController;
	
	NSIndexPath				*personToRemoveIndexPath;
	ABRecordRef				thisContact;
	CFMutableArrayRef		contacts;
	NSMutableArray			*selectedContacts;
	
	//Outlets
	UIBarButtonItem			*updateSelectedButton;
	UIBarButtonItem			*selectButton;
}

@property (nonatomic, retain) ContactsModel *contactsModel;
@property (nonatomic, retain) ProgressViewController *progressViewController;
@property (nonatomic, retain) NSIndexPath *personToRemoveIndexPath;
@property (nonatomic) ABRecordRef thisContact;
@property (nonatomic) CFMutableArrayRef contacts;
@property (nonatomic, retain) NSMutableArray *selectedContacts;

//Outlets
@property (nonatomic, retain) IBOutlet UIBarButtonItem *updateSelectedButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *selectButton;

- (void)updateSelectionCount;
- (void)updateTable;
- (void)updateSelectedContactsAddressBook;
- (NSArray *)indexPathsForSelectedRows;
- (void)updateSelected:(NSUInteger)position selectedState:(BOOL)state;
- (void)setSelectButtonState:(int)selectState;
- (void)multiDeleteTableViewRows:(NSArray *)indexPaths;

//Actions
- (IBAction)convertSelectedContactsNumbers;
- (IBAction)selectContacts:(id)sender;

@end
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

#import <UIKit/UIKit.h>
#import "ContactsViewController.h"


@interface ContactDetailController : UITableViewController <UIActionSheetDelegate> {
	ContactsViewController *contactsViewController;
	ContactsModel *contactsModel;
	
	ABRecordRef thisContact;
	ABRecordID thisContactID;
	NSDictionary *contactNumbers;
	NSIndexPath *currentPersonIndexPath;
	
	//Outlets
	UILabel *contactNameLabel;
	UIImageView *contactImageImageView;
	UIButton *contactUpdateButton;
}


@property (nonatomic, retain) ContactsViewController *contactsViewController;
@property (nonatomic, retain) ContactsModel *contactsModel;
@property (nonatomic) ABRecordRef thisContact;
@property (nonatomic) ABRecordID thisContactID;
@property (nonatomic, retain) NSDictionary *contactNumbers;
@property (nonatomic, retain) NSIndexPath *currentPersonIndexPath;

//Outlets
@property (nonatomic, retain) IBOutlet UIImageView* contactImageImageView;
@property (nonatomic, retain) IBOutlet UILabel *contactNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *contactUpdateButton;

- (IBAction)updateContact;

@end

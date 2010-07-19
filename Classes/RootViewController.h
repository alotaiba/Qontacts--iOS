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

@class ContactsViewController;
@class InfoModalViewController;
@class ProgressViewController;
@class NoContactsViewController;

@interface RootViewController : UIViewController {
	ContactsViewController		*contactsViewController;
	InfoModalViewController		*infoModalViewController;
	ProgressViewController		*progressViewController;
	NoContactsViewController	*noContactsViewController;
	UIBarButtonItem				*analyzeContactsButton;
	UITextView					*mainTextView;
}

@property (nonatomic, retain) ContactsViewController *contactsViewController;
@property (nonatomic, retain) InfoModalViewController *infoModalViewController;
@property (nonatomic, retain) ProgressViewController *progressViewController;
@property (nonatomic, retain) NoContactsViewController *noContactsViewController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *analyzeContactsButton;
@property (nonatomic, retain) IBOutlet UITextView *mainTextView;

- (void)loadContacts;
- (void)showNextScreen;

- (IBAction)analyzeContacts;
- (IBAction)showInfoPage;

@end

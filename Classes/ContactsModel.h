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

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ContactsModel : NSObject {
	ABAddressBookRef addressBook;
	CFMutableArrayRef people;
	CFMutableArrayRef contacts;
}

@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic) CFMutableArrayRef people;
@property (nonatomic) CFMutableArrayRef contacts;

//Initializers
- (id)initWithPeople:(BOOL)copyPeople;

//Manipulating contact's details
- (BOOL)checkContact:(ABRecordRef)thisContact;
- (BOOL)convertContactNumbers:(ABRecordRef)thisContact;
- (BOOL)saveAddressBook;

//Gathering contact's details
- (UIImage *)contactPicture:(ABRecordRef)thisContact;
- (NSString *)contactName:(ABRecordRef)thisContact;
- (NSDictionary *)updateableContactNumbers:(ABRecordRef)thisContact;

//Misc.
- (NSString *)cleanNumber:(NSString *)number;
//Private
- (NSString *)_updateableNumber:(NSString *)number;

@end